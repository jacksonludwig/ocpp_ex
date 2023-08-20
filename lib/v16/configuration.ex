defmodule V16.ConfigurationState do
  @moduledoc """
  Struct containing charging station state
  """
  use TypedStruct

  typedstruct enforce: true do
    field(:charge_point_vendor, String.t())
    field(:charge_point_model, String.t())
  end
end

defmodule V16.Configuration do
  @moduledoc """
  This process contains the state of the charging station.
  """
  use GenServer

  # Client

  def start_link(configuration = %V16.ConfigurationState{}) do
    GenServer.start_link(__MODULE__, configuration, name: __MODULE__)
  end

  @doc """
  Get the current state of the charging station.
  """
  @spec get_state() :: V16.ConfigurationState.t()
  def get_state() do
    GenServer.call(__MODULE__, :get_state)
  end

  # Server

  @impl true
  def init(state) do
    {:ok, state}
  end

  @impl true
  def handle_call(:get_state, _from, state) do
    {:reply, state, state}
  end
end
