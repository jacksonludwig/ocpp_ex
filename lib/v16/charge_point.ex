defmodule V16.ChargePoint do
  @moduledoc """
  This process handles responding to requests from the central system.
  """
  use GenServer

  alias MessageHandling.MessageToCs
  alias MessageParsing.OCPPMessage.RequestResponse
  alias MessageStream.EventBus
  alias V16.Configuration

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

  def handle_cs_call("GetConfiguration", msg = %RequestResponse{}) do
    station_state = Configuration.get_state()

    MessageToCs.response(%RequestResponse{
      type_id: 3,
      action: msg.action,
      payload: %{
        chargePointVendor: station_state.charge_point_vendor,
        chargePointModel: station_state.charge_point_model
      },
      message_id: msg.message_id
    })
  end

  def handle_cs_call(_action, msg) do
    {:error, :unknown_call_from_cs, msg}
  end

  def handle_unexpected_message(msg) do
    {:error, :unknown_message_from_cs, msg}
  end
end
