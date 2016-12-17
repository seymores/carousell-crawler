defmodule CarousellCrawler do
  require Logger
  alias CarousellCrawler.Parser

  def get_twitter(url) do
    Parser.load_body(url) |> Parser.twitter
  end

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

    Map.merge(basic_info, %{"category" => category_name, "image" => image,
                            "longitude" => longitude, "latitude" => latitude,
                            "country" => country, "country_code" => country_code})
  end

  def find_home_productids(url) do
    Parser.load_body(url)
    |> Parser.parse_homepage_script
    |> Parser.parse_product_ids
  end

  def find_category_productids(url) do
    Parser.load_body(url)
    |> Parser.parse_homepage_script
    |> Parser.parse_category_script
  end

end
