defmodule MessageParsing.Validator do
  @moduledoc """
  Validates OCPP messages.
  """
  alias MessageParsing.{OCPPErrorMessage, OCPPmessage, SchemaReader, SchemaValidation}

  @doc """
  Validate an OCPP message struct.
  """
  @spec validate_payload(String.t(), struct()) :: :ok | {:error, [term()]}
  def validate_payload(protocol, input = %OCPPmessage{}) do
    protocol
    |> SchemaReader.get_schema(input.action, input.type_id)
    |> SchemaValidation.validate_schema(input.payload)
  end

  def validate_payload(protocol, input = %OCPPErrorMessage{}) do
    protocol
    |> SchemaReader.get_schema("_Error", 4)
    |> SchemaValidation.validate_schema(input.error_details)
  end
end
