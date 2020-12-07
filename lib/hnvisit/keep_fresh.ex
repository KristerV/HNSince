require Logger
alias Hnvisit.Repo, as: Repo
alias Hnvisit.HNAPI, as: HNAPI
alias Hnvisit.Story, as: Story

defmodule Hnvisit.KeepFresh do
  def new do
    last_db =
      Story.get_last()
      |> case do
        nil -> 1
        %{hn_id: hn_id} -> hn_id
      end

    last_hn_real =
      HNAPI.get_last_item()
      |> case do
        {:ok, last} -> last
        {:error, err} -> Logger.error("Getting last item failed", err)
      end

    last_hn =
      min(last_hn_real, last_db + Application.get_env(:hnvisit, Hnvisit.KeepFresh)[:batch_size])

    stories =
      for hn_id <- last_db..last_hn do
        HNAPI.get_item(hn_id)
        |> case do
          {:error, err} -> Logger.error("Getting story error", err: err)
          {:ok, %{"type" => "story"} = item} -> Story.from_item(item, false)
          {:ok, %{"type" => _type}} -> nil
        end
      end
      |> Enum.filter(fn x -> is_map(x) end)

    {inserts, _errors} = Repo.insert_all(Story, stories, on_conflict: :nothing)

    Logger.info(
      "Inserted new stories: #{inserts}. Progress: #{List.last(stories).hn_id} / #{last_hn_real}"
    )

    if inserts > 0 do
      new()
    end

    # TODO: make parallel
  end

  def updates do
    # get updates from HN
    # fetch all
    # upsert
  end
end
