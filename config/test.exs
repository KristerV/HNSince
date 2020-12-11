use Mix.Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :hnsince, HNSince.Repo,
  username: "postgres",
  password: "postgres",
  database: "hnsince_test#{System.get_env("MIX_TEST_PARTITION")}",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :hnsince, HNSinceWeb.Endpoint,
  http: [port: 4002],
  server: false

config :hnsince, HNSince.PageView,
  stories_visible: 30,
  past_buffer_hours: 3,
  refresh_all_time_cache_hours: 1

# Print only warnings and errors during test
config :logger, level: :warn
