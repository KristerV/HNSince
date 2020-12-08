# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :hnsince,
  ecto_repos: [HNSince.Repo]

# Configures the endpoint
config :hnsince, HNSinceWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "B4dAOeknfX4KxXWrVw/eQbfAA2UOC3m1b3sjOpNC4xJtzY8AU43wTRqvKEhOG5VN",
  render_errors: [view: HNSinceWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: HNSince.PubSub,
  live_view: [signing_salt: "uEOVYSBh"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
