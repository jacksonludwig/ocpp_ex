defmodule MessageParsing.OCPPMessage do
  @moduledoc """
  OCPP message structs and types.
  """

  @typedoc """
  Matches any type of OCPP message struct.
  """
  @type any_OCPP_message :: __MODULE__.RequestResponse.t() | __MODULE__.ErrorResponse.t()

  @doc """
  Matches any ocpp message struct.
  """
  defguard is_OCPP_message(val)
           when is_struct(val, __MODULE__.RequestResponse) or
                  is_struct(val, __MODULE__.ErrorResponse)

  @doc """
  Returns true if the OCPP message is a request or a response.
  Returns false if the message is an error response.
  """
  @spec is_request_response?(any_OCPP_message()) :: boolean()
  def is_request_response?(val) do
    val.type_id != 4
  end

  defmodule RequestResponse do
    @moduledoc """
    Regular OCPP message struct.

    For responses, the `action` field is NOT present in the specification. They are included in the
    struct for validation purposes.
    """
    use TypedStruct

    typedstruct enforce: true do
      field(:type_id, 2 | 3)
      field(:message_id, String.t())
      field(:action, String.t())
      field(:payload, map())
    end
  end

  defmodule ErrorResponse do
    @moduledoc """
    Error OCPP message struct.
    """
    use TypedStruct

    typedstruct enforce: true do
      field(:type_id, 4)
      field(:message_id, String.t())
      field(:error_code, String.t())
      field(:error_description, String.t())
      field(:error_details, map(), default: %{})
    end
  end
end
