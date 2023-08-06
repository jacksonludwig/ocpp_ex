defmodule MessageStream.EventBus do
  @moduledoc """
  Broker for events. Contains functions for listening for events and for broadcasting
  events to all listeners.
  """
  alias MessageParsing.OCPPMessage
  use GenServer

  @registry_process_name :"#{__MODULE__}Registry"
  @type listener_key :: :from_cs | :to_cs
  @topics [:from_cs, :to_cs]

  # Client

  def start_link(_args) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  @doc """
  Returns all of the topics in the event bus
  """
  @spec get_keys() :: list(listener_key())
  def get_keys() do
    @topics
  end

  @doc """
  Subscribe the calling `GenServer` process to the topic in the parameter. 

  Whenever a new message enters the topic, it will be broadcasted to the `handle_info` function
  in the calling process.
  """
  @spec listen_for(listener_key()) :: :ok
  def listen_for(key) do
    {:ok, _pid} = Registry.register(@registry_process_name, key, [])
    :ok
  end

  @doc """
  Broadcast a message to all listeners of the given key.
  """
  @spec broadcast(listener_key(), OCPPMessage.any_OCPP_message()) :: :ok
  def broadcast(key, message) do
    true = Enum.member?(@topics, key)
    GenServer.call(__MODULE__, {:broadcast_message, key, message})
  end

  # Server

  @impl true
  def init(arg) do
    {:ok, _pid} = Registry.start_link(keys: :duplicate, name: @registry_process_name)
    {:ok, arg}
  end

  @impl true
  def handle_call({:broadcast_message, key, data}, _from, state) do
    Registry.dispatch(@registry_process_name, key, fn entries ->
      for {pid, _} <- entries, do: send(pid, {:broadcasted_message, key, data})
    end)

    {:reply, :ok, state}
  end
end
