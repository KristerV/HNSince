require Logger
alias Hnvisit.Story, as: Story

defmodule Hnvisit.HNAPI do
  def get_item(item_id) do
    "https://hacker-news.firebaseio.com/v0/item/#{item_id}.json"
    |> make_request()
  end

  def get_last_item do
    "https://hacker-news.firebaseio.com/v0/maxitem.json"
    |> make_request()
  end

  def get_updates do
    "https://hacker-news.firebaseio.com/v0/updates.json"
    |> make_request()
  end

  defp make_request(url) do
    url
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

  def get_items(numbers) do
    for hn_id <- numbers do
      Task.async(fn ->
        get_item(hn_id)
        |> case do
          {:error, err} -> err |> inspect |> Logger.error()
          {:ok, %{"type" => "story"} = item} -> Story.from_item(item, false)
          {:ok, %{"type" => _type}} -> nil
          {:ok, nil} -> nil
        end
      end)
    end
    |> Task.await_many(60 * 1000)
    |> Enum.filter(fn x -> is_map(x) end)
  end
end
