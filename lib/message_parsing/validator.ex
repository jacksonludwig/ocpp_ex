defmodule MessageParsing.Validator do
  @moduledoc """
  Validates OCPP messages.
  """
  alias MessageParsing.{OCPPErrorMessage, OCPPmessage, SchemaReader, SchemaValidation}

  defguard is_OCCP_message(val)
           when is_struct(val, OCPPmessage) or is_struct(val, OCPPErrorMessage)

  @doc """
  Validate an OCPP message struct.
  """
  @spec validate(String.t(), struct()) :: :ok | {:error, [term()]}
  def validate(protocol, input = %OCPPmessage{}) do
    {protocol, input.action, input.type_id}
    |> SchemaReader.get_schema()
    |> SchemaValidation.validate_schema(input.payload)
  end

  def validate(protocol, input = %OCPPErrorMessage{}) do
    {protocol, "_Error", 4}
    |> SchemaReader.get_schema()
    |> SchemaValidation.validate_schema(input.error_details)
  end
end
