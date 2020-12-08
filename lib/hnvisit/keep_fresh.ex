require Logger
import Ecto.Query
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

    stories = HNAPI.get_items(last_db..last_hn)

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
    {:ok, %{"items" => items}} = HNAPI.get_updates()

    existing =
      from(s in Story,
        where: s.hn_id in ^items
      )
      |> Repo.all()

    stories =
      existing
      |> Enum.map(fn x -> x.hn_id end)
      |> HNAPI.get_items()

    for {db_story, hn_story} <- Enum.zip(existing, stories),
        db_story.hn_id == hn_story.hn_id do
      Story.changeset(db_story, hn_story)
      |> Repo.update()
      |> case do
        {:ok, struct} -> :ok
        err -> err
      end
    end
  end
end
