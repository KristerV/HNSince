defmodule HnvisitWeb.HNAPITest do
  use ExUnit.Case

  test "Simple item query" do
    {:ok, item} = Hnvisit.HNAPI.get_item(8863)

    assert %{
             "by" => "dhouston",
             "descendants" => 71,
             "id" => 8863,
             "score" => 104,
             "time" => 1_175_714_200,
             "title" => "My YC app: Dropbox - Throw away your USB drive",
             "type" => "story",
             "url" => "http://www.getdropbox.com/u/2/screencast.html"
           } == Map.drop(item, ["kids"])
  end
end
