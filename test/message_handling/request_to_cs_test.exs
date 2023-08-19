defmodule MessageHandling.RequestToCsTest do
  use ExUnit.Case

  alias MessageHandling.{ResponseQueue, RequestToCs}
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
      },
      response_2: %OCPPMessage.RequestResponse{
        action: "RemoteStartTransaction",
        type_id: 3,
        payload: %{},
        message_id: "1234"
      }
    }
  end

  @tag capture_log: true
  test "should receive response to message", %{request: request, response: response} do
    request_task = RequestToCs.request(request)

    ResponseQueue.enqueue(response)
    request_task_result = Task.await(request_task)

    assert request_task_result == response
  end

  @tag capture_log: true
  test "should timeout while waiting for response", %{request: request} do
    request_task =
      RequestToCs.request(request, %RequestToCs{
        response_poll_timeout: 0
      })

    assert nil == Task.await(request_task)
  end

  @tag capture_log: true
  test "should timeout while ignoring wrong response", %{request: request, response_2: response} do
    ResponseQueue.enqueue(response)

    request_task =
      RequestToCs.request(request, %RequestToCs{
        response_poll_timeout: 0
      })

    assert nil == Task.await(request_task)
  end
end
