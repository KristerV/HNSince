alias HNSince.Story, as: Story

defmodule HNSince.AllTimeStoriesCache do
  use GenServer
  @conf Application.get_env(:hnsince, HNSince.PageView)

  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: MyAllTimeStoriesCache)
  end

  @impl true
  def init(state) do
    Process.send_after(self(), :work, 1000)

    {:ok, state}
  end

  @impl true
  def handle_info(:work, _state) do
    Process.send_after(self(), :work, @conf[:refresh_all_time_cache_hours] * 3_600_000)

    {:noreply, Story.get_since(0)}
  end

  def get() do
    GenServer.call(MyAllTimeStoriesCache, :get)
  end

  @impl true
  def handle_call(:get, _from, state) do
    {:reply, state, state}
  end
end
