defmodule MessageStream.EventLogger do
  @moduledoc """
  Logs events that enter the event bus
  """
  use GenServer

  alias MessageStream.EventBus

  require Logger

  # Client

  def start_link(_args) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  # Server

  @impl true
  def init(state) do
    EventBus.get_keys() |> Enum.each(&EventBus.listen_for/1)
    {:ok, state}
  end

  @impl true
  def handle_info({:broadcasted_message, key, data}, state) do
    Logger.info(decription: "message received", topic: key, data: data)
    {:noreply, state}
  end
end
