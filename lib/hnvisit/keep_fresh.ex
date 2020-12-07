require Logger
alias Hnvisit.Repo, as: Repo
alias Hnvisit.HNAPI, as: HNAPI
alias Hnvisit.Story, as: Story

defmodule Hnvisit.KeepFresh do
  @conf Application.get_env(:hnvisit, Hnvisit.KeepFresh)
  def new do
    last_db =
      Story.get_last()
      |> case do
        nil -> @conf[:starting_id]
        %{hn_id: hn_id} -> hn_id
      end

    last_hn_real =
      HNAPI.get_last_item()
      |> case do
        {:ok, last} -> last
        {:error, err} -> Logger.error("Getting last item failed", err)
      end

    last_hn = min(last_hn_real, last_db + @conf[:batch_size])

    stories =
      for hn_id <- last_db..last_hn do
        Task.async(fn ->
          HNAPI.get_item(hn_id)
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

    {inserts, _errors} =
      Repo.insert_all(Story, stories,
        on_conflict: :nothing,
        conflict_target: :hn_id
      )

    Logger.info(
      "Inserted new stories: #{inserts}. Progress: #{List.last(stories).hn_id} / #{last_hn_real}"
    )

    if inserts > 0 do
      new()
    end
  end

  def updates do
    # get updates from HN
    # fetch all
    # upsert
  end
end
