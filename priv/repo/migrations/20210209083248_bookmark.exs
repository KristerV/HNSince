defmodule HNSince.Repo.Migrations.Bookmark do
  use Ecto.Migration
  alias HNSince.Visit
  import Ecto.Query

  def change do
    alter table("visits") do
      add :bookmark, :utc_datetime
    end
    flush()
    from(v in Visit, update: [set: [bookmark: v.inserted_at]])
    |> HNSince.Repo.update_all([])
  end
end
