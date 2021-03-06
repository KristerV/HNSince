defmodule HNSince.Repo.Migrations.CreateStories do
  use Ecto.Migration

  def change do
    create table(:stories) do
      add :hn_id, :integer
      add :by, :string
      add :descendants, :integer
      add :score, :integer
      add :time, :integer
      add :title, :text
      add :url, :text
    end

    create unique_index(:stories, [:hn_id])
    create index(:stories, [:time, :score])
  end
end
