defmodule MessageParsing.JSONParser do
  @moduledoc """
  JSON encoding and decoding.
  """
  defdelegate encode(a1), to: Jason
  defdelegate encode!(a1), to: Jason
  defdelegate decode(a1), to: Jason
  defdelegate decode!(a1), to: Jason
end
