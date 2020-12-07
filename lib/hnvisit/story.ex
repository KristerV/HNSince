defmodule Hnvisit.Story do
  require Logger
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query
  alias Hnvisit.Repo, as: Repo
  alias Hnvisit.Story, as: Story

  schema "stories" do
    field :by, :string
    field :descendants, :integer
    field :hn_id, :integer
    field :score, :integer
    field :time, :integer
    field :title, :string
    field :url, :string
  end

  def changeset(story, attrs) do
    story
    |> cast(attrs, [:hn_id, :by, :descendants, :score, :time, :title, :url])
    |> validate_required([:hn_id, :by, :descendants, :score, :time, :title, :url])
  end

  def get_and_upsert(hn_id) do
    Hnvisit.HNAPI.get_item(hn_id)
    |> case do
      {:error, err} ->
        Logger.warning("Fetching HN item error", err)
        {:error, err}

      {:ok, %{"type" => "story"} = item} ->
        item
        |> from_item()
        |> upsert()

      {:ok, %{"type" => _}} ->
        {:error, :wront_type}
    end
  end

  def upsert(%Story{hn_id: hn_id} = story) do
    case Repo.get_by(Story, hn_id: hn_id) do
      nil -> %Story{}
      existing_story -> existing_story
    end
    |> Story.changeset(Map.from_struct(story))
    |> Repo.insert_or_update()
  end

  def from_item(item, to_struct \\ true) do
    map = %{
      hn_id: item["id"],
      by: item["by"],
      descendants: item["descendants"],
      score: item["score"],
      time: item["time"],
      title: item["title"],
      url: item["url"]
    }

    if to_struct do
      struct(Story, map)
    else
      map
    end
  end

  def get_last do
    Story
    |> last
    |> Repo.one()
  end
end
