defmodule Hnvisit.Repo do
  use Ecto.Repo,
    otp_app: :hnvisit,
    adapter: Ecto.Adapters.Postgres
end
