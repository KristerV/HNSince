defmodule HNSince.Visit do
  alias HNSince.Visit
  use Ecto.Schema
  import Ecto.Query
  alias HNSince.Repo
  import Ecto.Changeset

  schema "visits" do
    field :session_id, Ecto.UUID
    field :last_story, :utc_datetime
    field :lock, :utc_datetime
    field :forced, :utc_datetime
    field :bookmark, :utc_datetime

    timestamps(updated_at: false, type: :utc_datetime)
  end

  @doc false
  def changeset(visit, attrs) do
    visit
    |> cast(attrs, [:session_id, :last_story, :lock, :forced, :bookmark])
    |> validate_required([:session_id, :last_story, :bookmark])
  end

  def get_last(session_id, lock \\ nil)

  def get_last(session_id, %DateTime{} = lock) do
    from(v in Visit,
      where: v.session_id == ^session_id and v.inserted_at == ^lock
    )
    |> last()
    |> Repo.one()
  end

  def get_last(session_id, nil) do
    from(v in Visit,
      where: v.session_id == ^session_id
    )
    |> last()
    |> Repo.one()
  end

  def get_visits_tail(session_id, amount \\ 10) do
    from(v in Visit,
      where: v.session_id == ^session_id and is_nil(v.forced) and is_nil(v.lock),
      limit: ^amount,
      order_by: [desc: v.inserted_at]
    )
    |> Repo.all()
  end

  def get(session_id, %DateTime{} = inserted_at) do
    from(v in Visit,
      where: v.inserted_at == ^inserted_at and v.session_id == ^session_id,
      limit: 1
    )
  end

  def insert(session_id, last_story_dt, lock, forced, bookmark) do
    %Visit{}
    |> changeset(%{
      session_id: session_id,
      last_story: last_story_dt,
      lock: lock,
      forced: forced,
      bookmark: bookmark
    })
    |> Repo.insert()
  end

  def put_extra_fields(visit) do
    Map.merge(visit, %{
      human: Timex.from_now(visit.inserted_at),
      unix: DateTime.to_unix(visit.inserted_at)
    })
  end

  def get_bookmark(visit) do
    visit.inserted_at
    |> DateTime.add(-48 * 60 * 60)
    |> max(visit.last_story)
  end

  def remove_duplicate_dates(visits) do
    Enum.reduce(visits, [], fn x, acc ->
      h = x.human

      case List.last(acc) do
        nil -> [x]
        %{:human => ^h} -> acc
        _ -> acc ++ [x]
      end
    end)
  end
end
