defmodule MessageParsing.Validator do
  @moduledoc """
  Validates OCPP messages.
  """
  alias MessageParsing.{OCPPErrorMessage, OCPPMessage, SchemaReader, SchemaValidation, JSONParser}

  @type any_ocpp_message :: OCPPMessage.t() | OCPPErrorMessage.t()
  @type error_tuple :: :ok | {:error, atom(), term()}

  @doc """
  Parse a string into an OCPP message struct.
  """
  @spec parse(String.t(), String.t()) :: any_ocpp_message | {:error, atom(), term()}
  def parse(protocol, input) do
    with {:ok, decoded_input} <- JSONParser.decode(input),
         :ok <- validate_message_structure(protocol, decoded_input),
         ocpp_message when is_struct(ocpp_message) <- validated_message_to_struct(input),
         :ok <- validate_payload(protocol, ocpp_message) do
      ocpp_message
    end
  end

  @doc """
  Validate the message format
  """
  @spec validate_message_structure(String.t(), list()) :: :ok | error_tuple
  def validate_message_structure(protocol, input) do
    with {:ok, schema} <- SchemaReader.get_message_schema(protocol) do
      SchemaValidation.validate(schema, input)
    end
  end

  @doc """
  Validate an OCPP message struct's payload.
  """
  @spec validate_payload(String.t(), struct()) :: :ok | error_tuple
  def validate_payload(protocol, input = %OCPPMessage{}) do
    with {:ok, schema} <- SchemaReader.get_payload_schema(protocol, input.action, input.type_id) do
      SchemaValidation.validate(schema, input.payload)
    end
  end

  def validate_payload(_, _ = %OCPPErrorMessage{}) do
    :ok
  end

  defp validated_message_to_struct([4, message_id, code, description, details]) do
    %OCPPErrorMessage{
      error_code: code,
      error_description: description,
      error_details: details,
      type_id: 4,
      message_id: message_id
    }
  end

  defp validated_message_to_struct([type_id, message_id, action, payload])
       when type_id == 3 or type_id == 2 do
    %OCPPMessage{
      type_id: type_id,
      message_id: message_id,
      action: action,
      payload: payload
    }
  end

  defp validated_message_to_struct(_value) do
    {:error, :unknown_structure,
     "ocpp message was validated but could not be serialized into a struct"}
  end
end
