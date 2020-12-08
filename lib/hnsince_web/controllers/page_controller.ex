import Ecto.Query
alias HNSince.Repo, as: Repo
alias HNSince.Story, as: Story

defmodule HNSinceWeb.PageController do
  @conf Application.get_env(:hnsince, HNSince.PageView)
  use HNSinceWeb, :controller

  def index(conn, params) do
    if @conf[:analytics_hook] do
      HTTPoison.post(
        @conf[:analytics_hook],
        "{\"visit\": 1}",
        [{"Content-Type", "application/json"}]
      )
    end

    last_visit = get_session(conn, :last_visit)

    conn = put_session(conn, :last_visit, DateTime.utc_now())

    buffered_time =
      if !is_nil(last_visit) do
        last_visit
        |> DateTime.add(-60 * @conf[:past_buffer_minutes], :second)
        |> DateTime.to_unix()
      else
        0
      end

    stories =
      from(s in Story,
        where: s.time > ^buffered_time,
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

    render(conn, "index.html", last_visit: last_visit, stories: stories)
  end
end
