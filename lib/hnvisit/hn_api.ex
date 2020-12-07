defmodule Hnvisit.HNAPI do
  def get_item(item_id) do
    "https://hacker-news.firebaseio.com/v0/item/#{item_id}.json"
    |> HTTPoison.get([], recv_timeout: 30000, timeout: 30000)
    |> case do
      {:ok, %{status_code: 200, body: body}} ->
        Poison.decode(body)

      {:ok, %{status_code: 404}} ->
        {:error, :not_found}

      {:error, err} ->
        {:error, err}
    end
  end

  def get_last_item do
    "https://hacker-news.firebaseio.com/v0/maxitem.json"
    |> HTTPoison.get([], recv_timeout: 30000, timeout: 30000)
    |> case do
      {:ok, %{status_code: 200, body: body}} ->
        Poison.decode(body)

      {:ok, %{status_code: 404}} ->
        {:error, :not_found}

      {:error, err} ->
        {:error, err}
    end
  end
end
