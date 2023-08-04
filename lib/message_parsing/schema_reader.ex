defmodule MessageParsing.SchemaReader do
  @moduledoc """
  Retrieves schemas from disk and caches them.
  """
  alias MessageParsing.{SchemaValidation, JSONParser, SchemaStoreServer}

  defp get_schema_path(protocol), do: "#{File.cwd!()}/lib/#{protocol}/schemas"

  defp read_schema(protocol, action, 2) do
    File.read("#{get_schema_path(protocol)}/#{action}.json")
  end

  defp read_schema(protocol, action, 3) do
    File.read("#{get_schema_path(protocol)}/#{action}Response.json")
  end

  defp read_schema(protocol, _, 4) do
    File.read("#{get_schema_path(protocol)}/ErrorResponse.json")
  end

  # TODO: handle error cases when reading or decoding schema
  @doc """
  Retrieve the schema for a specific OCPP message.

  When `type_id` is 4, the `action` is ignored.

  ex - get_schema("v16", "BootNotification", 2) returns the schema for the BootNotification
  request payload.
  """
  @spec get_schema(String.t(), String.t(), 2 | 3 | 4) :: term()
  def get_schema(protocol, action, type_id) do
    case SchemaStoreServer.get({action, type_id}) do
      nil ->
        {:ok, data} = read_schema(protocol, action, type_id)
        {:ok, schema_obj} = JSONParser.decode(data)
        resolved_schema = SchemaValidation.resolve(schema_obj)
        SchemaStoreServer.set({action, type_id}, resolved_schema)
        resolved_schema

      resolved_schema ->
        resolved_schema
    end
  end
end
