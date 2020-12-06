defmodule Hnvisit.HNAPI do
  def get_item(item_id) do
    url = "https://hacker-news.firebaseio.com/v0/item/#{item_id}.json"

    case HTTPoison.get(url) do
      {:ok, %{status_code: 200, body: body}} ->
        Poison.decode(body)

      {:ok, %{status_code: 404}} ->
        {:error, :not_found}

      {:error, err} ->
        {:error, err}
    end
  end
end
