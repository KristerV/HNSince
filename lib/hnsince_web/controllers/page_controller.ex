alias HNSince.Story, as: Story

defmodule HNSinceWeb.PageController do
  alias HNSince.LastVisit, as: LastVisit
  @conf Application.get_env(:hnsince, HNSince.PageView)
  use HNSinceWeb, :controller

  def index(conn, %{"lock" => lock}) when lock == "false" do
    IO.puts("delete_session")

    conn
    |> delete_session(:lock)
    |> index(%{})
  end

  def index(conn, %{"lock" => lock}) do
    IO.puts("lock")

    conn
    |> put_session(:lock, String.to_integer(lock))
    |> index(%{})
  end

  def index(conn, params) do
    lock = get_session(conn, :lock)
    forced_visit = params["visit"]

    session_visits =
      get_session(conn, :last_visits) ||
        Enum.map(2..@conf[:visits_memory_size], fn _ -> nil end) ++
          [get_session(conn, :last_visit)]

    session_last =
      {forced_visit, lock}
      |> IO.inspect(label: "SESSION_LAST")
      |> case do
        {nil, nil} -> session_visits |> List.last()
        {unix, nil} -> unix |> String.to_integer() |> DateTime.from_unix!()
        {_, lock} -> lock |> DateTime.from_unix!()
      end

    last_visit = LastVisit.from_datetime(session_last, @conf[:past_buffer_hours])

    previous_visits = LastVisit.format_previous_visits(session_visits)

    conn =
      if is_nil(forced_visit) and is_nil(lock) do
        session_visits
        |> Enum.concat([DateTime.utc_now()])
        |> (&Enum.drop(&1, length(&1) - @conf[:visits_memory_size])).()
        |> (&put_session(conn, :last_visits, &1)).()
      else
        conn
      end

    stories =
      case last_visit.buffered do
        0 -> HNSince.AllTimeStoriesCache.get()
        buffered -> Story.get_since(buffered, @conf[:stories_visible])
      end
      |> Enum.map(fn s ->
        domain =
          case s.url do
            nil -> nil
            url -> URI.parse(url).authority
          end

        past =
          with {:ok, t} = DateTime.from_unix(s.time) do
            Timex.from_now(t)
          end

        Map.merge(s, %{
          domain: domain,
          past: past
        })
      end)

    render(conn, "index.html",
      last_visit: last_visit.human,
      min_hours: last_visit.min_hours,
      current_visit_utc: DateTime.to_unix(last_visit.session),
      stories: stories,
      previous_visits: previous_visits,
      forced_visit: forced_visit,
      lock: lock
    )
  end
end
