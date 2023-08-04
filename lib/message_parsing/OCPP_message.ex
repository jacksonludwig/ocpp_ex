defmodule MessageParsing.OCPPmessage do
  @moduledoc """
  Regular OCPP message struct.
  """
  use TypedStruct

  typedstruct enforce: true do
    field :type_id, 2 | 3
    field :message_id, String.t()
    field :action, String.t()
    field :payload, map()
  end
end
