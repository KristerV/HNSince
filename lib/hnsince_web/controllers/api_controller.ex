defmodule HNSinceWeb.APIController do
  use HNSinceWeb, :controller

  def submit_email(conn, %{"email" => email}) do
    conn = fetch_session(conn)

    session_id =
      get_session(conn, "session_id")
      |> IO.inspect(label: "session_id")

    HNSince.Email.insert(email, session_id)
    text(conn, "Email registered")
  end
end
