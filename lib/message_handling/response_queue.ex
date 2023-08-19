defmodule MessageHandling.ResponseQueue do
  @moduledoc """
  Maintains a queue of responses from the Central System to the Charge Point.
  """
  use GenServer

  alias MessageParsing.OCPPMessage

  import OCPPMessage, only: [is_OCPP_message: 1]

  # Client

  def start_link(_args) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  @doc """
  Add a message to the queue.
  """
  @spec enqueue(OCPPMessage.any_OCPP_message()) :: no_return()
  def enqueue(message) when is_OCPP_message(message) do
    GenServer.call(__MODULE__, {:enqueue, message})
  end

  @doc """
  Get the message at the front of the queue.
  """
  @spec dequeue() :: OCPPMessage.any_OCPP_message() | nil
  def dequeue() do
    GenServer.call(__MODULE__, :dequeue)
  end

  @doc """
  Return the entire queue as a list. Intended for testing only.
  """
  @spec get_queue() :: list()
  def get_queue() do
    GenServer.call(__MODULE__, :get_queue)
  end

  @doc """
  Reset the queue to an empty list. Intended for testing only.
  """
  @spec reset_queue() :: no_return()
  def reset_queue() do
    GenServer.call(__MODULE__, :reset)
  end

  # Server

  @impl true
  def init(list) do
    {:ok, list}
  end

  @impl true
  def handle_call({:enqueue, message}, _from, state) do
    {:reply, :ok, [message | state]}
  end

  @impl true
  def handle_call(:dequeue, _from, state) do
    {last, rest} = List.pop_at(state, -1)
    {:reply, last, rest}
  end

  @impl true
  def handle_call(:get_queue, _from, state) do
    {:reply, state, state}
  end

  @impl true
  def handle_call(:reset, _from, _state) do
    {:reply, [], []}
  end
end
