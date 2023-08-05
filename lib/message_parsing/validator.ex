defmodule MessageParsing.Validator do
  @moduledoc """
  Validates OCPP messages.
  """
  alias MessageParsing.{SchemaReader, SchemaValidation, JSONParser, OCPPMessage}
  alias OCPPMessage.{RequestResponse, ErrorResponse}

  import OCPPMessage, only: [is_OCPP_message: 1]

  @doc """
  Parse a string into an OCPP message struct.
  """
  @spec parse(String.t(), String.t()) ::
          {:ok, OCPPMessage.any_OCPP_message()} | Utils.error_tuple()
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
  Convert an OCPP message struct to a JSON string.
  """
  @spec unparse(String.t(), struct()) :: {:ok, String.t()} | Utils.error_tuple()
  def unparse(protocol, input) when is_OCPP_message(input) do
    with :ok <- validate_message_protocol(protocol),
         :ok <- validate_message_action(protocol, input),
         :ok <- validate_payload(protocol, input) do
      unparse_struct(input)
    end
  end

  defp unparse_struct(input = %RequestResponse{}) do
    JSONParser.encode([input.type_id, input.message_id, input.action, input.payload])
  end

  defp unparse_struct(input = %ErrorResponse{}) do
    JSONParser.encode([
      input.type_id,
      input.message_id,
      input.error_code,
      input.error_description,
      input.error_details
    ])
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
  Validate the message format
  """
  @spec validate_message_structure(list()) :: :ok | Utils.error_tuple()
  def validate_message_structure(input) do
    with {:ok, schema} <- SchemaReader.get_meta_schema(:message) do
      SchemaValidation.validate(schema, input)
    end
  end

  @doc """
  Validate the message action
  """
  @spec validate_message_action(String.t(), OCPPMessage.any_OCPP_message()) ::
          :ok | Utils.error_tuple()
  def validate_message_action(protocol, message = %RequestResponse{}) do
    with {:ok, schema} <- SchemaReader.get_action_schema(protocol) do
      SchemaValidation.validate(schema, message.action)
    end
  end

  def validate_message_action(_protocol, _ = %ErrorResponse{}) do
    :ok
  end

  @doc """
  Validate an OCPP message struct's payload.
  """
  @spec validate_payload(String.t(), struct()) :: :ok | Utils.error_tuple()
  def validate_payload(protocol, input = %RequestResponse{}) do
    with {:ok, schema} <- SchemaReader.get_payload_schema(protocol, input.action, input.type_id) do
      SchemaValidation.validate(schema, input.payload)
    end
  end

  def validate_payload(_, _ = %ErrorResponse{}) do
    :ok
  end

  @doc """
  Convert previously validated list to an OCPP message struct
  """
  @spec validated_message_to_struct(term()) :: struct()
  def validated_message_to_struct([4, message_id, code, description, details]) do
    %ErrorResponse{
      error_code: code,
      error_description: description,
      error_details: details,
      type_id: 4,
      message_id: message_id
    }
  end

  def validated_message_to_struct([type_id, message_id, action, payload])
      when type_id == 3 or type_id == 2 do
    %RequestResponse{
      type_id: type_id,
      message_id: message_id,
      action: action,
      payload: payload
    }
  end

  def validated_message_to_struct(_value) do
    {:error, :unknown_structure,
     "ocpp message was validated but could not be serialized into a struct"}
  end
end
