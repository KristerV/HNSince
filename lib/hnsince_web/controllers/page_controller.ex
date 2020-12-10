import Ecto.Query
alias HNSince.Repo, as: Repo
alias HNSince.Story, as: Story

defmodule HNSinceWeb.PageController do
  @conf Application.get_env(:hnsince, HNSince.PageView)
  use HNSinceWeb, :controller

  def index(conn, _params) do
    Task.start(fn ->
      if @conf[:analytics_hook] do
        HTTPoison.post(
          @conf[:analytics_hook],
          "{\"visit\": 1}",
          [{"Content-Type", "application/json"}]
        )
      end
    end)

    last_visit =
      get_session(conn, :last_visit)
      |> case do
        nil ->
          %{session: nil, buffered: 0, human: nil, min_hours: nil}

        %DateTime{} = dt ->
          %{
            session: dt,
            buffered:
              DateTime.add(dt, -60 * 60 * @conf[:past_buffer_hours], :second)
              |> DateTime.to_unix(),
            human: Timex.from_now(dt),
            min_hours:
              if Timex.diff(DateTime.utc_now(), dt, :hours) < @conf[:past_buffer_hours] do
                @conf[:past_buffer_hours]
              else
                nil
              end
          }
      end

    conn = put_session(conn, :last_visit, DateTime.utc_now())

    stories =
      from(s in Story,
        where: s.time > ^last_visit.buffered and not is_nil(s.score),
        order_by: [desc: s.score, desc: s.time],
        limit: ^@conf[:stories_visible]
      )
      |> Repo.all()
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
      stories: stories
    )
  end
end
