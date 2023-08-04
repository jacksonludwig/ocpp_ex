defmodule MessageParsing.OCPPErrorMessage do
  @moduledoc """
  Error OCPP message struct.
  """
  use TypedStruct

  typedstruct enforce: true do
    field :type_id, 4
    field :message_id, String.t()
    field :error_code, String.t()
    field :error_description, String.t()
    field :error_details, map(), default: %{}
  end
end
