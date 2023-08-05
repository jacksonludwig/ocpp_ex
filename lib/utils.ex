defmodule Utils do
  @moduledoc """
  Util file hold some common types and functions.
  """
  alias MessageParsing.{OCPPMessage, OCPPErrorMessage}

  @type error_tuple :: {:error, atom(), term()}
  @type any_OCPP_message :: OCPPMessage.t() | OCPPErrorMessage.t()
end
