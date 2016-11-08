# CarousellCrawler

Experimental Carousell crawler, because there is no API to get their data.

## Installation

  1. Add `carousell_crawler` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:carousell_crawler, "https://github.com/seymores/carousell-crawler"}]
    end
    ```

  2. Ensure `carousell_crawler` is started before your application:

    ```elixir
    def application do
      [applications: [:carousell_crawler]]
    end
    ```

