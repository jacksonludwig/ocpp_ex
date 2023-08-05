defmodule MessageParsing.OCPPMessage do
  @moduledoc """
  OCPP message structs and types.
  """

  @typedoc """
  Matches any type of OCPP message struct.
  """
  @type any_OCPP_message :: __MODULE__.RequestResponse.t() | __MODULE__.ErrorResponse.t()

  defmodule RequestResponse do
    @moduledoc """
    Regular OCPP message struct.
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
