defmodule CarousellCrawler do
  require Logger

  def get_twitter(url) do
    load_body(url) |> twitter
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

  def load_body(url) do
    headers = ["User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/51.0.2704.103 Safari/537.36"]
    HTTPotion.get(url, [headers: headers, follow_redirects: true]) |> Map.get(:body) |> Floki.parse
  end

  defp attribute_content(body, target) do
    Floki.find(body, target) |> Floki.attribute("content") |> List.first
  end

end
