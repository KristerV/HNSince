defmodule HNSince.LastVisit do
  alias HNSince.LastVisit, as: LastVisit
  defstruct [:session, :buffered, :human, :min_hours]

  def from_datetime(datetime, past_buffer_hours) do
    case datetime do
      nil ->
        %LastVisit{session: nil, buffered: 0, human: nil, min_hours: nil}

      %DateTime{} = dt ->
        %LastVisit{
          session: dt,
          buffered:
            DateTime.add(dt, -60 * 60 * past_buffer_hours, :second)
            |> DateTime.to_unix(),
          human: Timex.from_now(dt),
          min_hours:
            if Timex.diff(DateTime.utc_now(), dt, :hours) < past_buffer_hours do
              past_buffer_hours
            else
              nil
            end
        }
    end
  end

  def format_previous_visits(visits) do
    for visit <- visits, !is_nil(visit) do
      %{
        human: Timex.from_now(visit),
        unix_utc: DateTime.to_unix(visit)
      }
    end
    |> Enum.reverse()
    |> Enum.reduce([], fn x, acc ->
      h = x.human

      case List.last(acc) do
        nil -> [x]
        %{:human => ^h} -> acc
        _ -> acc ++ [x]
      end
    end)
    |> Enum.drop(1)
  end
end
