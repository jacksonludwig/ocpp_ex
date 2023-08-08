defmodule OCPPMessageTest do
  use ExUnit.Case

  alias MessageParsing.OCPPMessage

  setup do
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
      error: %OCPPMessage.ErrorResponse{
        message_id: "123",
        type_id: 4,
        error_description: "blah",
        error_code: "RemoteStartTransaction",
        error_details: %{},
      }
    }
  end

  test "should return message is req/response", %{request: req_message, response: res_message} do
    assert OCPPMessage.is_request_response?(req_message) == true
    assert OCPPMessage.is_request_response?(res_message) == true
  end

  test "should return message isn't req/response", %{error: error_message} do
    assert OCPPMessage.is_request_response?(error_message) == false
  end
end
