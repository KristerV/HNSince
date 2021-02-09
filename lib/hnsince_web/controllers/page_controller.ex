defmodule HNSinceWeb.PageController do
  alias HNSince.Visit
  alias HNSince.Story
  alias HNSinceWeb.RouterHelpers
  use HNSinceWeb, :controller
  @conf Application.get_env(:hnsince, HNSince.PageView)

  def index(conn, %{"session_id" => "reset"}) do
    conn
    |> delete_session(:session_id)
    |> index(%{})
  end

  def index(conn, params) do
    session_id = params["session_id"] || get_session(conn, "session_id") || Ecto.UUID.generate()
    conn = RouterHelpers.handle_legacy_sessions(conn, session_id)
    conn = put_session(conn, "session_id", session_id)

    lock = RouterHelpers.parse_lock(params["lock"], session_id)
    forced = RouterHelpers.parse_forced(params["visit"])

    bookmark =
      case Visit.get_last(session_id, lock) do
        nil -> DateTime.from_unix!(0)
        visit -> Visit.get_bookmark(visit)
      end

    stories =
      (forced || bookmark)
      |> Story.get_since()
      |> Enum.map(&Story.put_extra_fields/1)

    last_story_current = Story.find_last_story(stories, bookmark)

    previous_visits =
      Visit.get_visits_tail(session_id, @conf[:show_previous_visits])
      |> Enum.map(&Visit.put_extra_fields/1)
      |> Visit.remove_duplicate_dates()

    Visit.insert(session_id, last_story_current, lock, forced)

    launch_seen = get_session(conn, "launch_seen")
    conn = put_session(conn, "launch_seen", true)

    render(conn, "index.html",
      lock: lock,
      forced: forced,
      previous_visits: previous_visits,
      stories: stories,
      session_id: session_id,
      launch_seen: launch_seen
    )
  end
end
