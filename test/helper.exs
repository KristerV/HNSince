defmodule Hnvisit.Helper do
  def db_connection(_context \\ nil) do
    Ecto.Adapters.SQL.Sandbox.checkout(Repo)
    Ecto.Adapters.SQL.Sandbox.mode(Repo, {:shared, self()})
  end
end
