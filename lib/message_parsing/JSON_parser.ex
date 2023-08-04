defmodule MessageParsing.JSONParser do
  @moduledoc """
  JSON encoding and decoding.
  """

  @doc """
  Encode a value to JSON.
  """
  @spec encode(term()) :: {:ok, String.t()} | {:error, :encode_failed, term()}
  def encode(value) do
    case Jason.encode(value) do
      {:ok, string_val} -> {:ok, string_val}
      {:error, error} -> {:error, :encode_failed, error}
    end
  end


  @doc """
  Decode a value from a JSON string.
  """
  @spec decode(iodata()) :: {:ok, term()} | {:error, :decode_failed, term()}
  def decode(value) do
    case Jason.decode(value) do
      {:ok, map_value} -> {:ok, map_value}
      {:error, error} -> {:error, :decode_failed, error}
    end
  end
end
