defmodule Hnvisit.StoryTest do
  use ExUnit.Case
  import Hnvisit.TestHelper

  setup :db_connection

  test "Upsert story" do
    {:ok, story} = Hnvisit.Story.get_and_upsert(8863)

    assert %Hnvisit.Story{
             by: "dhouston",
             descendants: 71,
             hn_id: 8863,
             score: 104,
             time: 1_175_714_200,
             title: "My YC app: Dropbox - Throw away your USB drive",
             url: "http://www.getdropbox.com/u/2/screencast.html"
           } = story
  end

  test "Upsert fails with non-story" do
    story = Hnvisit.Story.get_and_upsert(8862)

    assert {:error, :wront_type} == story
  end
end
