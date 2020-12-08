defmodule HNSince.Repo do
  use Ecto.Repo,
    otp_app: :hnsince,
    adapter: Ecto.Adapters.Postgres
end
