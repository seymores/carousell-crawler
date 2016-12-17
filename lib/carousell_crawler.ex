defmodule CarousellCrawler do
  require Logger
  alias CarousellCrawler.Parser

  def get_twitter(url) do
    Parser.load_body(url) |> Parser.twitter
  end

  # def load_body(url) do
  #   headers = ["User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/51.0.2704.103 Safari/537.36"]
  #   HTTPotion.get(url, [headers: headers, follow_redirects: true]) |> Map.get(:body) |> Floki.parse
  # end

  def product_data(url) do
    data = Parser.parse_for_script_data(url) |> Parser.parse_product_store
    Logger.debug inspect(data)
    basic_info = Map.take data, ["id", "timeCreated", "lastModified", "description",
                                  "currency", "price", "sellerUsername", "collectionId",
                                  "currency", "currencyCode", "currencySymbol", "likesCount"]
    category_name = get_in(data, ["category", "displayName"])

    image = List.first(data["photos"]) |> Map.get("imageUrl")

    latitude = get_in(data, ["marketplace", "location", "latitude"])
    longitude = get_in(data, ["marketplace", "location", "longitude"])
    country = get_in(data, ["marketplace", "country", "name"])
    country_code  = get_in(data, ["marketplace", "country", "code"])

    # Logger.warn inspect(marketplace)

    # r = Map.put(basic_info, "category", category_name)
    # Map.put(r, "imageUrl", image)
    Map.merge(basic_info, %{"category" => category_name, "image" => image,
                            "longitude" => longitude, "latitude" => latitude,
                            "country" => country, "country_code" => country_code})
  end

  def parse_home_page(url) do
    Parser.load_body(url)
    |> Parser.parse_homepage_script
    |> Parser.parse_context_data
  end

end
