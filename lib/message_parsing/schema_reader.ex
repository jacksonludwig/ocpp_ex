defmodule MessageParsing.SchemaReader do
  @moduledoc """
  Retrieves schemas from disk and caches them.
  """
  alias MessageParsing.{SchemaValidation, JSONParser, SchemaStoreServer}

  # TODO: handle error cases when reading or decoding schema

  defp get_schema_path(protocol), do: "#{File.cwd!()}/lib/#{protocol}/schemas"
  defp get_message_schema_path(protocol), do: "#{File.cwd!()}/lib/#{protocol}/message_schemas"

  defp read_schema(protocol, action, 2) do
    case File.read("#{get_schema_path(protocol)}/#{action}.json") do
      {:ok, data} -> {:ok, data}
      {:error, error} -> {:error, :schema_read_error, error}
    end
  end

  defp read_schema(protocol, action, 3) do
    case File.read("#{get_schema_path(protocol)}/#{action}Response.json") do
      {:ok, data} -> {:ok, data}
      {:error, error} -> {:error, :schema_read_error, error}
    end
  end

  defp read_message_schema(protocol) do
    case File.read("#{get_message_schema_path(protocol)}/Message.json") do
      {:ok, data} -> {:ok, data}
      {:error, error} -> {:error, :schema_read_error, error}
    end
  end

  @doc """
  Retrieve the schema for a specific OCPP message type.

  ex - get_message_schema("v16") returns the schema for a v16 an OCPP message
  """
  @spec get_message_schema(String.t()) :: {:error, atom(), term()} | {:ok, term()}
  def get_message_schema(protocol) do
    case SchemaStoreServer.get({protocol, -1}) do
      nil ->
        with {:ok, data} <- read_message_schema(protocol),
             {:ok, schema_obj} <- JSONParser.decode(data),
             {:ok, resolved_schema} <- SchemaValidation.resolve_schema(schema_obj) do
          SchemaStoreServer.set({protocol, -1}, resolved_schema)
          resolved_schema
        end

      resolved_schema ->
        {:ok, resolved_schema}
    end
  end

  @doc """
  Retrieve the schema for a specific request or response OCPP message payload.

  ex - get_schema("v16", "BootNotification", 2) returns the schema for the BootNotification
  request payload.
  """
  @spec get_payload_schema(String.t(), String.t(), 2 | 3) :: {:error, atom(), term()} | {:ok, term()}
  def get_payload_schema(protocol, action, type_id) do
    case SchemaStoreServer.get({action, type_id}) do
      nil ->
        with {:ok, data} <- read_schema(protocol, action, type_id),
             {:ok, schema_obj} <- JSONParser.decode(data),
             {:ok, resolved_schema} <- SchemaValidation.resolve_schema(schema_obj) do
          SchemaStoreServer.set({action, type_id}, resolved_schema)
          resolved_schema
        end

      resolved_schema ->
        {:ok, resolved_schema}
    end
  end
end
