defmodule MessageHandling.ChargePoint do
  @moduledoc """
  This process handles responding to requests from the central system.
  """
  use GenServer

  alias MessageParsing.OCPPMessage.RequestResponse
  alias MessageStream.EventBus

  # TODO: actually handle messages
  # TODO: store state here or in other process?

  # Client

  def start_link(_args) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  # Server

  @impl true
  def init(state) do
    EventBus.listen_for(:from_cs)
    {:ok, state}
  end

  @impl true
  def handle_info({:broadcasted_message, :from_cs, data}, state) do
    case data do
      msg = %RequestResponse{} when msg.type_id == 2 -> handle_cs_call(msg.action, msg)
      msg -> handle_unexpected_message(msg)
    end

    {:noreply, state}
  end

  # Message Handling

  def handle_cs_call("RemoteStartTransaction", msg = %RequestResponse{}) do
    # 1. send remote start conf
    # 2. start transaction flow
  end

  def handle_cs_call("TriggerMessage", msg = %RequestResponse{}) do
    # 1. send connector status
  end

  def handle_cs_call("GetConfiguration", msg = %RequestResponse{}) do
    # 1. send configuration
  end

  def handle_cs_call(_action, msg) do
    {:error, :unknown_call_from_cs, msg}
  end

  def handle_unexpected_message(msg) do
    {:error, :unknown_message_from_cs, msg}
  end
end
