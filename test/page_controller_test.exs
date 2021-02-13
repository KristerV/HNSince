defmodule HNSinceWeb.PageControllerTest do
  use ExUnit.Case
  alias HNSince.Repo
  alias HNSince.Story
  import HNSince.TestHelper

  import Plug.Conn
  import Phoenix.ConnTest

  @endpoint HNSinceWeb.Endpoint

  setup :db_connection

  setup do
    timestamp_now = DateTime.utc_now() |> DateTime.to_unix()

    stories =
      for no <- 0..1000 do
        %{
          by: "string",
          title: "string",
          url: "string",
          descendants: 0,
          hn_id: no,
          score: no,
          time: timestamp_now - no * 3600
        }
      end

    Repo.insert_all(Story, stories)
    {:ok, conn: Phoenix.ConnTest.build_conn()}
  end

  describe "GET / - anonymous user" do
    test "Visit 3 times", %{conn: conn} do
      conn = get(conn, "/")
      html = html_response(conn, 200)
      assert html =~ "1000 points"
      assert !String.contains?(html, "100 points")

      conn = get(conn, "/")
      html = html_response(conn, 200)
      assert html =~ "47 points"
      assert !String.contains?(html, "50 points")

      conn = get(conn, "/")
      html = html_response(conn, 200)
      assert html =~ "17 points"
      assert !String.contains?(html, "18 points")

      conn = get(conn, "/")
      html = html_response(conn, 200)
      assert !String.contains?(html, "point</span>")
      assert !String.contains?(html, "points</span>")
    end
  end
end
