defmodule Hnsince.Repo.Migrations.CreateEmails do
  use Ecto.Migration

  def change do
    create table(:emails) do
      add :session_id, :uuid
      add :email, :string

      timestamps()
    end

  end
end
