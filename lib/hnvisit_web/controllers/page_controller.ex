import Ecto.Query
alias Hnvisit.Repo, as: Repo
alias Hnvisit.Story, as: Story

defmodule HnvisitWeb.PageController do
  @conf Application.get_env(:hnvisit, Hnvisit.PageView)
  use HnvisitWeb, :controller

  def index(conn, params) do
    last_visit = get_session(conn, :last_visit)

    conn = put_session(conn, :last_visit, DateTime.utc_now())

    buffered_time =
      last_visit
      |> DateTime.add(-60 * @conf[:past_buffer_minutes], :second)
      |> DateTime.to_unix()

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
