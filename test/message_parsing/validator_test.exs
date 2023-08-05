defmodule MessageParsing.ValidatorTest do
  use ExUnit.Case, async: true

  doctest MessageParsing.Validator

  test "should validate request" do
    assert {:ok,
            %MessageParsing.OCPPMessage{
              type_id: 2,
              message_id: "123",
              action: "Authorize",
              payload: %{"idTag" => "abc"}
            }} =
             MessageParsing.Validator.parse(
               "v16",
               ~s([2, "123", "Authorize", { "idTag": "abc" }])
             )
  end

  test "should validate response" do
    assert {:ok,
            %MessageParsing.OCPPMessage{
              type_id: 3,
              message_id: "123",
              action: "Authorize",
              payload: %{"idTagInfo" => %{"status" => "Accepted"}}
            }} =
             MessageParsing.Validator.parse(
               "v16",
               ~s([3, "123", "Authorize", { "idTagInfo": {"status": "Accepted"} }])
             )
  end

  test "should validate error response" do
    assert {:ok,
            %MessageParsing.OCPPErrorMessage{
              error_code: "UnknownMessageType",
              error_description: "Message type wrong",
              error_details: %{},
              type_id: 4,
              message_id: "123"
            }} =
             MessageParsing.Validator.parse(
               "v16",
               ~s([4, "123", "UnknownMessageType", "Message type wrong", {}])
             )
  end

  test "should return error on unknown protocol" do
    assert {:error, :validation_failed, _} =
             MessageParsing.Validator.parse(
               "vfake",
               ~s([4, "123", "UnknownMessageType", "Message type wrong", {}])
             )
  end

  test "should return error on unknown action" do
    assert {:error, :validation_failed, _} =
             MessageParsing.Validator.parse(
               "v16",
               ~s([2, "123", "../../../", {}])
             )
  end
end
