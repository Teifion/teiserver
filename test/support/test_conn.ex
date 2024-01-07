defmodule Teiserver.TestSupport.TestConn do
  @moduledoc """
  A genserver used to allow faking of connections and processes. Can also be used to listen for messages.

    ## Examples
    ```
    # Create
    conn1 = TestConn.new()
    conn2 = TestConn.new(["channel1", "channel2"])

    # Check mailbox
    messages = TestConn.get(conn1)
    messages = TestConn.get(conn2)

    # Run code
    TestConn.run(conn1, fn ->
      Connections.connect_user(user_id)
    end)

    # Terminate the process
    TestConn.stop(conn1)
    ```
  """

  use GenServer
  alias Phoenix.PubSub

  @spec new(list) :: pid
  def new(topics \\ []) do
    {:ok, pid} = start_link(topics)
    pid
  end

  @spec get(pid) :: list
  def get(pid) do
    GenServer.call(pid, :get)
  end

  @spec subscribe(pid, String.t() | [String.t()]) :: :ok
  def subscribe(pid, items) do
    GenServer.cast(pid, {:subscribe, items})
  end

  @spec unsubscribe(pid, String.t() | [String.t()]) :: :ok
  def unsubscribe(pid, items) do
    GenServer.cast(pid, {:unsubscribe, items})
  end

  @spec run(pid, function) :: any
  def run(pid, fun) do
    GenServer.call(pid, {:run, fun})
  end

  @spec stop(pid, boolean) :: any
  def stop(pid, sleep \\ true) do
    GenServer.cast(pid, :stop)
    if sleep, do: :timer.sleep(20)
  end

  def start_link(topics) do
    GenServer.start_link(__MODULE__, topics, [])
  end

  # GenServer callbacks
  def handle_cast({:subscribe, items}, state) do
    subscribe_to_items(items)
    {:noreply, state}
  end

  def handle_cast({:unsubscribe, items}, state) do
    unsubscribe_from_items(items)
    {:noreply, state}
  end

  def handle_cast(:stop, state) do
    {:stop, :normal, state}
  end

  def handle_info(item, state) do
    {:noreply, [item | state]}
  end

  def handle_call({:run, fun}, _from, state) do
    result = fun.()
    {:reply, result, state}
  end

  def handle_call(:get, _from, state) do
    {:reply, state, []}
  end

  # Internal
  defp subscribe_to_items(items) do
    items
    |> List.wrap()
    |> Enum.each(fn item ->
      PubSub.subscribe(Teiserver.PubSub, item)
    end)
  end

  defp unsubscribe_from_items(items) do
    items
    |> List.wrap()
    |> Enum.each(fn item ->
      PubSub.unsubscribe(Teiserver.PubSub, item)
    end)
  end

  def init(topics) do
    subscribe_to_items(topics)
    {:ok, []}
  end
end
