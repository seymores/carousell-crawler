defmodule CarousellCrawler.Parser do
  require Logger

  def load_body(url) do
    headers = ["User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/51.0.2704.103 Safari/537.36"]
    HTTPotion.get(url, [headers: headers, follow_redirects: true]) |> Map.get(:body) |> Floki.parse
  end

  def twitter(body) do
    Logger.info inspect(body)

    %{"card" => "meta[name='twitter:card']",
      "site" => "meta[name='twitter:site']",
      "creator" => "meta[name='twitter:creator']",
      "title" => "meta[name='twitter:title']",
      "description" => "meta[name='twitter:description']",
      "image" => "meta[name='twitter:image']",
      "label1" => "meta[name='twitter:label1']",
      "data1" => "meta[name='twitter:data1']",
      "label2" => "meta[name='twitter:label2']",
      "data2" => "meta[name='twitter:data2']"
      }
      |> Stream.map(fn {k, v} -> {k, attribute_content(body, v)} end)
      |> Enum.into(%{})
  end

  @doc """
  Parse Carousell item page using embeded script data used by the page react.js.

  ## Example

      iex> CarousellCrawler.parse_for_script_data "https://carousell.com/p/62538322"

  """
  def parse_for_script_data(url) do
    load_body(url)
    |> parse_script
    |> parse_context_data
  end

  defp attribute_content(body, target) do
    Floki.find(body, target) |> Floki.attribute("content") |> List.first
  end

  @doc """
  Get the product map data from the parse script data.

   ## Example

    iex> data = CarousellCrawler.parse_for_script_data "https://carousell.com/p/62538322"
    iex> CarousellCrawler.parse_product_store(data)

  """
  def parse_product_store(data) do
    product_id = get_in(data, ["context", "dispatcher", "stores", "ImmutableProductStore", "productListsMap", "PRODUCT"]) |> List.first
    product_data = get_in(data, ["context", "dispatcher", "stores", "ImmutableProductStore", "productsMap", "#{product_id}"])
    category_id = product_data["collectionId"]
    category_data = get_in(data, ["context", "dispatcher", "stores", "CollectionStore", "collectionsMap", "#{category_id}"])
    Logger.info inspect(category_data)
    category_name = Map.take(category_data, ["id", "displayName", "subcategories"])
    Map.put(product_data, "category", category_name)
  end

  defp parse_script(body) do
    Floki.find(body, "script")
    |> Enum.at(2)
    |> elem(2)
    |> List.first
  end

  def parse_homepage_script(body) do
    Floki.find(body, "script")
    |> Enum.at(1)
    |> elem(2)
    |> List.first
  end

  def parse_context_data(script) do
    Regex.scan(~r/window.App=(.*);/, script)
    |> List.first
    |> List.last
    |> Poison.decode!
  end

  defp filter_product_ids([""]), do: []
  defp filter_product_ids(list), do: list

  def parse_product_ids(script) do
     dat = Regex.scan(~r/"productIds":\[(.*?)\]/, script, capture: :all_but_first)
     result =
     for l<-dat do
       filter_product_ids(l)
     end
     List.flatten(result)
  end

  def parse_category_script(script) do
    data = Regex.scan(~r/{"PRODUCTS_CATEGORY":\[(.*?)\]}/, script, capture: :all_but_first) |> List.flatten |> List.first
    Regex.scan(~r/\d+/, data, capture: :first) |> List.flatten
  end

end
