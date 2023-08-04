defmodule MessageParsing.SchemaStoreServer do
  @moduledoc """
  Maintains a map of an OCPP action to its schema.
  """
  use GenServer

  # Client

  def start_link(_args) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  @doc """
  Map an action to a schema object.

  ex: {"BootNotification, 2"} -> schema for boot request
  ex: {"BootNotification, 3"} -> schema for boot response
  """
  @spec set({String.t(), 2 | 3 | 4}, term()) :: term
  def set({action, message_type}, schema) do
    GenServer.call(__MODULE__, {:set, {action, message_type}, schema})
  end

  @doc """
  Get a schema object using the given action.
  """
  @spec get({String.t(), 2 | 3 | 4}) :: term
  def get({action, message_type}) do
    GenServer.call(__MODULE__, {:get, {action, message_type}})
  end

  # Server

  @impl true
  def init(map) do
    {:ok, map}
  end

  @impl true
  def handle_call({:set, {action, message_type}, schema}, _from, state) do
    {:reply, :ok, Map.put(state, {action, message_type}, schema)}
  end

  @impl true
  def handle_call({:get, {action, message_type}}, _from, state) do
    {:reply, Map.get(state, {action, message_type}), state}
  end
end
