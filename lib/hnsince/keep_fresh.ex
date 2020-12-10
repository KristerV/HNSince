require Logger
import Ecto.Query
alias HNSince.Repo, as: Repo
alias HNSince.HNAPI, as: HNAPI
alias HNSince.Story, as: Story

defmodule HNSince.KeepFresh do
  @conf Application.get_env(:hnsince, HNSince.KeepFresh)

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
      "Inserted new stories: #{inserts}. Progress: #{List.last(stories).hn_id} out of #{
        last_hn_real
      } (#{last_hn_real - List.last(stories).hn_id} left)"
    )

    if inserts > 0 do
      new()
    end
  end

  def updates do
    {:ok, %{"items" => items}} = HNAPI.get_updates()

    # Only update existing posts
    existing =
      from(s in Story,
        where: s.hn_id in ^items
      )
      |> Repo.all()

    # Fetch data of existing posts
    %{nil: stories, true: deleted} =
      existing
      |> Enum.map(fn x -> x.hn_id end)
      |> HNAPI.get_items(true)
      |> Enum.group_by(fn x -> x["deleted"] end)
      |> Map.put_new(nil, [])
      |> Map.put_new(true, [])

    # Delete "deleted" posts
    if length(deleted) > 0 do
      deleted
      |> Enum.map(fn d -> d.hn_id end)
      |> (&from(s in Story, where: s.hn_id in ^&1)).()
      |> Repo.delete_all()

      Logger.info("Deleted stories: #{length(deleted)}")
    end

    # Update posts
    update_count =
      if length(stories) > 0 do
        for {db_story, hn_story} <- Enum.zip(existing, stories),
            db_story.hn_id == hn_story.hn_id do
          Story.changeset(db_story, hn_story)
          |> Repo.update()
          |> case do
            {:ok, struct} -> :ok
            err -> err
          end
        end
        |> Enum.count(fn x -> x == :ok end)
      else
        0
      end

    Logger.info("Updated stories: #{update_count}")
  end
end
