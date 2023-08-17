defmodule MessageHandling.ChargePoint do
  @moduledoc """
  This process handles responding to requests from the central system.
  """
  use GenServer

  alias MessageParsing.OCPPMessage.{RequestResponse, ErrorResponse}
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
    handle_cs_call(data)

    {:noreply, state}
  end

  # Message Handling

  def handle_cs_call(msg = %RequestResponse{}) when msg.type_id == 3 do
    # ignore responses
  end

  def handle_cs_call(_msg = %ErrorResponse{}) do
    # ignore error responses
  end

  def handle_cs_call(msg = %RequestResponse{}) when msg.action == "RemoteStartTransaction" do
    # 1. send remote start conf
    # 2. start transaction flow
  end

  def handle_cs_call(msg = %RequestResponse{}) when msg.action == "TriggerMessage" do
    # 1. send connector status
  end

  def handle_cs_call(msg = %RequestResponse{}) when msg.action == "GetConfiguration" do
    # 1. send configuration
  end

  def handle_cs_call(msg = %RequestResponse{}) do
    {:error, :unknown_call_from_cs, msg.action}
  end
end
