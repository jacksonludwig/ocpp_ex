defmodule MessageHandling.RequestToCsOptions do
  @moduledoc """
  Struct containing options for sending calls to the central system.
  """
  use TypedStruct

  typedstruct enforce: true do
    field(:resend_interval, integer(), default: 30000)
    field(:max_send_attempts, integer(), default: 5)
    field(:response_poll_interval, integer(), default: 50)
    field(:response_poll_timeout, integer(), default: 140_000)
  end
end

defmodule MessageHandling.RequestToCs do
  @moduledoc """
  Handles requests initiated by the charge point to the central system.
  The behavior emulates a synchronous request-response flow; the charge point waits for
  a response to the request and times out otherwise.

  The charge point MUST NOT send additional requests until the current one is resolved.
  """
  alias MessageHandling.ResponseQueue
  alias MessageStream.EventBus
  alias MessageParsing.OCPPMessage

  @doc """
  Create an async task that makes a request to the central system and awaits for a response.
  When the response is received, `on_response` is executed.

  The awaited response will be either `nil` or an `OCPPMessage`.
  """
  @spec request(OCPPMessage.any_OCPP_message(), MessageHandling.RequestToCsOptions.t()) ::
          Task.t()
  def request(message, opts \\ %MessageHandling.RequestToCsOptions{}) do
    Task.async(fn ->
      poll_response_task = Task.async(fn -> poll_for_response(message.message_id, opts, 0) end)
      send_message_task = Task.async(fn -> send_message(message, 1, opts) end)

      # use infinity for timeout since the timeout is set using `opts.response_poll_timeout`
      poll_result = Task.await(poll_response_task, :infinity)

      # we can immediately stop re-sending the message if we receive a response
      Task.shutdown(send_message_task, :brutal_kill)

      poll_result
    end)
  end

  defp poll_for_response(message_id, opts, current_poll_time)
       when current_poll_time < opts.response_poll_timeout do
    Process.sleep(opts.response_poll_interval)

    case ResponseQueue.dequeue() do
      message when message.message_id == message_id -> message
      _ -> poll_for_response(message_id, opts, current_poll_time + opts.response_poll_interval)
    end
  end

  defp poll_for_response(_message_id, _opts, _current_poll_time) do
    nil
  end

  defp send_message(message, attempt_count, opts) when attempt_count < opts.max_send_attempts do
    EventBus.broadcast(:to_cs, message)

    Process.sleep(attempt_count * opts.resend_interval)

    send_message(message, opts.max_send_attempts + 1, opts)
  end

  defp send_message(_message, _attempt_count, _opts) do
    nil
  end
end
