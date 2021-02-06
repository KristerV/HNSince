defmodule Hnsince.Repo.Migrations.CreateVisits do
  use Ecto.Migration

  def change do
    create table(:visits) do
      add :session_id, :uuid, primary_key: true
      add :last_story, :utc_datetime, null: false
      add :lock, :utc_datetime
      add :forced, :utc_datetime

      timestamps(updated_at: false, type: :timestamptz)
    end
  end
end
