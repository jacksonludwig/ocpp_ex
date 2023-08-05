defmodule MessageHandling.ResponseQueueTest do
  use ExUnit.Case, async: true

  alias MessageHandling.ResponseQueue
  alias MessageParsing.OCPPMessage

  setup do
    ResponseQueue.reset_queue()

    %{
      request: %OCPPMessage.RequestResponse{
        action: "RemoteStartTransaction",
        type_id: 2,
        payload: %{},
        message_id: "123"
      },
      response: %OCPPMessage.RequestResponse{
        action: "RemoteStartTransaction",
        type_id: 3,
        payload: %{},
        message_id: "123"
      }
    }
  end

  test "should queue correct message", %{request: message} do
    ResponseQueue.enqueue(message)
    assert [^message] = ResponseQueue.get_queue()
  end

  test "should queue multiple messages", %{request: req_message, response: res_message} do
    ResponseQueue.enqueue(req_message)
    ResponseQueue.enqueue(res_message)
    assert [^res_message, ^req_message] = ResponseQueue.get_queue()
  end

  test "should dequeue correct message", %{request: req_message, response: res_message} do
    ResponseQueue.enqueue(req_message)
    ResponseQueue.enqueue(res_message)
    assert req_message == ResponseQueue.dequeue()
  end
end
