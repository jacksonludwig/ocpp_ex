defmodule MessageStream.EventBus do
  @moduledoc """
  Broker for events. Contains functions for listening for events and for broadcasting
  events to all listeners.
  """
  use GenServer

  alias MessageParsing.OCPPMessage

  @registry_process_name :"#{__MODULE__}Registry"
  @type listener_topic :: :from_cs | :to_cs
  @topics [:from_cs, :to_cs]

  # Client

  def start_link(_args) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  @doc """
  Returns all of the topics in the event bus
  """
  @spec get_topics() :: list(listener_topic())
  def get_topics() do
    @topics
  end

  @doc """
  Subscribe the calling `GenServer` process to the topic in the parameter. 

  Whenever a new message enters the topic, it will be broadcasted to the `handle_info` function
  in the calling process.
  """
  @spec listen_for(listener_topic()) :: :ok
  def listen_for(topic) do
    {:ok, _pid} = Registry.register(@registry_process_name, topic, [])
    :ok
  end

  @doc """
  Broadcast a message to all listeners of the given topic.
  """
  @spec broadcast(listener_topic(), OCPPMessage.any_OCPP_message()) :: :ok
  def broadcast(topic, message) do
    true = Enum.member?(@topics, topic)
    GenServer.call(__MODULE__, {:broadcast_message, topic, message})
  end

  # Server

  @impl true
  def init(arg) do
    {:ok, _pid} = Registry.start_link(keys: :duplicate, name: @registry_process_name)
    {:ok, arg}
  end

  @impl true
  def handle_call({:broadcast_message, topic, data}, _from, state) do
    Registry.dispatch(@registry_process_name, topic, fn entries ->
      for {pid, _} <- entries, do: send(pid, {:broadcasted_message, topic, data})
    end)

    {:reply, :ok, state}
  end
end
