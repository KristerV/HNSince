defmodule HNSinceWeb.RouterHelpers do
  alias HNSince.Visit
  alias HNSince.Repo
  use HNSinceWeb, :controller

  @spec parse_lock(nil | String.t(), String.t()) :: nil | DateTime.t()
  def parse_lock("false", _session_id) do
    nil
  end

  def parse_lock(nil, session_id) do
    case Visit.get_last(session_id) do
      nil -> nil
      %{lock: lock} -> lock
    end
  end

  def parse_lock(lock, _session_id) when is_bitstring(lock) do
    lock
    |> String.to_integer()
    |> DateTime.from_unix!()
  end

  @spec parse_forced(nil | String.t()) :: nil | DateTime.t()
  def parse_forced(nil) do
    nil
  end

  def parse_forced(forced) when is_bitstring(forced) do
    forced
    |> String.to_integer()
    |> DateTime.from_unix!()
  end

  def handle_legacy_sessions(
        %{private: %{plug_session: %{"session_id" => _sid}}} = conn,
        _session_id
      ) do
    # Already migrated to new session mechanic
    conn
  end

  def handle_legacy_sessions(%{private: %{plug_session: plug_session}} = conn, session_id) do
    # v1 || v0 of session implementation
    v1_visits =
      (plug_session["last_visits"] || [plug_session["last_visit"]])
      |> Enum.filter(fn v -> !is_nil(v) end)
      |> Enum.map(fn v -> DateTime.truncate(v, :second) end)

    new_visits =
      for visit <- v1_visits do
        %{
          session_id: session_id,
          last_story: visit,
          lock: nil,
          forced: nil,
          inserted_at: visit
        }
      end

    new_visits =
      if plug_session["lock"] do
        last = List.last(new_visits)
        new_visits ++ [Map.put(last, :lock, last.inserted_at)]
      else
        new_visits
      end

    Repo.insert_all(Visit, new_visits)

    conn
    |> delete_session(:last_visit)
    |> delete_session(:last_visits)
    |> delete_session(:lock)
  end
end
