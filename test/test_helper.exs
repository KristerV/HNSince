alias HNSince.Repo, as: Repo
ExUnit.start()
Ecto.Adapters.SQL.Sandbox.mode(Repo, :manual)

defmodule HNSince.TestHelper do
  def db_connection(_context \\ nil) do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Repo)
    Ecto.Adapters.SQL.Sandbox.mode(Repo, {:shared, self()})
  end
end
