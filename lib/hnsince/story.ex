defmodule HNSince.Story do
  require Logger
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query
  alias HNSince.Repo
  alias HNSince.Story

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
    |> validate_required([:hn_id, :score, :time, :title])
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

  def get_since(datetime, stories_visible \\ 30)

  def get_since(nil, _stories_visible) do
    HNSince.AllTimeStoriesCache.get()
  end

  def get_since(%DateTime{} = dt, stories_visible) do
    dt
    |> DateTime.to_unix()
    |> get_since(stories_visible)
  end

  def get_since(datetime, stories_visible) when is_integer(datetime) do
    from(s in Story,
      where: s.time > ^datetime and not is_nil(s.score),
      order_by: [desc: s.score, asc: s.time],
      limit: ^stories_visible
    )
    |> Repo.all()
  end

  def put_extra_fields(story) do
    domain =
      case story.url do
        nil -> nil
        url -> URI.parse(url).authority
      end

    past =
      with {:ok, t} = DateTime.from_unix(story.time) do
        Timex.from_now(t)
      end

    Map.merge(story, %{
      domain: domain,
      past: past
    })
  end

  def find_last_story([], prev_last_story) do
    prev_last_story
  end

  def find_last_story(stories, _prev_last_story) when is_list(stories) do
    Enum.reduce(stories, 0, fn s, acc ->
      max(s.time, acc)
    end)
    |> DateTime.from_unix!()
  end
end
