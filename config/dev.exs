use Mix.Config

# Configure your database
config :hnsince, HNSince.Repo,
  username: "postgres",
  password: "postgres",
  database: "hnsince_dev",
  hostname: "localhost",
  show_sensitive_data_on_connection_error: true,
  pool_size: 10

# For development, we disable any cache and enable
# debugging and code reloading.
#
# The watchers configuration can be used to run external
# watchers to your application. For example, we use it
# with webpack to recompile .js and .css sources.
config :hnsince, HNSinceWeb.Endpoint,
  http: [port: 4000],
  debug_errors: true,
  code_reloader: true,
  check_origin: false,
  watchers: [
    node: [
      "node_modules/webpack/bin/webpack.js",
      "--mode",
      "development",
      "--watch-stdin",
      cd: Path.expand("../assets", __DIR__)
    ]
  ]

# ## SSL Support
#
# In order to use HTTPS in development, a self-signed
# certificate can be generated by running the following
# Mix task:
#
#     mix phx.gen.cert
#
# Note that this task requires Erlang/OTP 20 or later.
# Run `mix help phx.gen.cert` for more information.
#
# The `http:` config above can be replaced with:
#
#     https: [
#       port: 4001,
#       cipher_suite: :strong,
#       keyfile: "priv/cert/selfsigned_key.pem",
#       certfile: "priv/cert/selfsigned.pem"
#     ],
#
# If desired, both `http:` and `https:` keys can be
# configured to run both http and https servers on
# different ports.

# Watch static and templates for browser reloading.
config :hnsince, HNSinceWeb.Endpoint,
  live_reload: [
    patterns: [
      ~r"priv/static/.*(js|css|png|jpeg|jpg|gif|svg)$",
      ~r"priv/gettext/.*(po)$",
      ~r"lib/hnsince_web/(live|views)/.*(ex)$",
      ~r"lib/hnsince_web/templates/.*(eex)$"
    ]
  ]

config :hnsince, HNSince.Scheduler,
  schedule: {:extended, "*/30 * * * * *"},
  overlap: false,
  jobs: [
    new: [
      task: {HNSince.KeepFresh, :new, []}
    ],
    updates: [
      task: {HNSince.KeepFresh, :updates, []}
    ]
  ]

config :hnsince, HNSince.KeepFresh,
  batch_size: 1000,
  starting_id: 26046000

config :hnsince, HNSince.PageView,
  stories_visible: 60,
  past_buffer_hours: 1,
  refresh_all_time_cache_hours: 1,
  show_previous_visits: 6

# Do not include metadata nor timestamps in development logs
config :logger, :console,
  level: :info,
  format: "[$level] $message\n"

# Set a higher stacktrace during development. Avoid configuring such
# in production as building large stacktraces may be expensive.
config :phoenix, :stacktrace_depth, 20

# Initialize plugs at runtime for faster development compilation
config :phoenix, :plug_init_mode, :runtime
