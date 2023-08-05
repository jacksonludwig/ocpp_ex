defmodule MessageParsing.Validator do
  @moduledoc """
  Validates OCPP messages.
  """
  alias MessageParsing.{OCPPErrorMessage, OCPPMessage, SchemaReader, SchemaValidation, JSONParser}

  @doc """
  Parse a string into an OCPP message struct.
  """
  @spec parse(String.t(), String.t()) :: {:ok, Utils.any_OCPP_message()} | Utils.error_tuple()
  def parse(protocol, input) do
    with :ok <- validate_message_protocol(protocol),
         {:ok, decoded_input} <- JSONParser.decode(input),
         :ok <- validate_message_structure(decoded_input),
         ocpp_message when is_struct(ocpp_message) <- validated_message_to_struct(decoded_input),
         :ok <- validate_message_action(protocol, ocpp_message),
         :ok <- validate_payload(protocol, ocpp_message) do
      {:ok, ocpp_message}
    end
  end

  @doc """
  Validate the message action
  """
  @spec validate_message_action(String.t(), Utils.any_OCPP_message()) :: :ok | Utils.error_tuple()
  def validate_message_action(protocol, message = %OCPPMessage{}) do
    with {:ok, schema} <- SchemaReader.get_action_schema(protocol) do
      SchemaValidation.validate(schema, message.action)
    end
  end

  def validate_message_action(_protocol, _ = %OCPPErrorMessage{}) do
    :ok
  end

  @doc """
  Validate the message format
  """
  @spec validate_message_structure(list()) :: :ok | Utils.error_tuple()
  def validate_message_structure(input) do
    with {:ok, schema} <- SchemaReader.get_meta_schema(:message) do
      SchemaValidation.validate(schema, input)
    end
  end

  @doc """
  Validate the given message protocol
  """
  @spec validate_message_protocol(term()) :: :ok | Utils.error_tuple()
  def validate_message_protocol(proto) do
    with {:ok, schema} <- SchemaReader.get_meta_schema(:protocol_type) do
      SchemaValidation.validate(schema, proto)
    end
  end

  @doc """
  Validate an OCPP message struct's payload.
  """
  @spec validate_payload(String.t(), struct()) :: :ok | Utils.error_tuple()
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
