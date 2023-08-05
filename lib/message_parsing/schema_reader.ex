defmodule MessageParsing.SchemaReader do
  @moduledoc """
  Retrieves schemas from disk and caches them.
  """
  alias MessageParsing.{SchemaValidation, JSONParser, SchemaStoreServer}

  # TODO: handle file traversal attacks?

  defp get_schema_path(protocol), do: "#{File.cwd!()}/lib/#{protocol}/schemas"

  defp get_meta_schema_path(name) do
    schema_file_name =
      case name do
        :message -> "Messages"
        :protocol_type -> "AllowedProtocolTypes"
      end

    "#{File.cwd!()}/lib/message_parsing/meta_schemas/#{schema_file_name}.json"
  end

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

  defp read_schema(protocol) do
    case File.read("#{get_schema_path(protocol)}/AllowedActions.json") do
      {:ok, data} -> {:ok, data}
      {:error, error} -> {:error, :schema_read_error, error}
    end
  end

  defp read_meta_schema(name) do
    case get_meta_schema_path(name) |> File.read() do
      {:ok, data} -> {:ok, data}
      {:error, error} -> {:error, :schema_read_error, error}
    end
  end

  @doc """
  Retrieve the given meta schema. A meta schema is used to validate the structure
  of messages rather than message contents.
  """
  @spec get_meta_schema(:message | :protocol_type) :: {:ok, term()} | Utils.error_tuple()
  def get_meta_schema(schema_type) do
    meta_schema_store_key = {to_string(schema_type), -1}

    case SchemaStoreServer.get(meta_schema_store_key) do
      nil ->
        with {:ok, data} <- read_meta_schema(schema_type),
             {:ok, schema_obj} <- JSONParser.decode(data),
             {:ok, resolved_schema} <- SchemaValidation.resolve_schema(schema_obj) do
          SchemaStoreServer.set(meta_schema_store_key, resolved_schema)
          {:ok, resolved_schema}
        end

      resolved_schema ->
        {:ok, resolved_schema}
    end
  end

  @doc """
  Retrieves the schema for the allowed actions for the given protocol.
  """
  @spec get_action_schema(String.t()) :: {:ok, term()} | Utils.error_tuple()
  def get_action_schema(protocol) do
    action_schema_store_key = {protocol, -1}

    case SchemaStoreServer.get(action_schema_store_key) do
      nil ->
        with {:ok, data} <- read_schema(protocol),
             {:ok, schema_obj} <- JSONParser.decode(data),
             {:ok, resolved_schema} <- SchemaValidation.resolve_schema(schema_obj) do
          SchemaStoreServer.set(action_schema_store_key, resolved_schema)
          {:ok, resolved_schema}
        end

      resolved_schema ->
        {:ok, resolved_schema}
    end
  end

  @doc """
  Retrieve the schema for a specific request or response OCPP message payload.
  """
  @spec get_payload_schema(String.t(), String.t(), 2 | 3) :: {:ok, term()} | Utils.error_tuple()
  def get_payload_schema(protocol, action, type_id) do
    case SchemaStoreServer.get({action, type_id}) do
      nil ->
        with {:ok, data} <- read_schema(protocol, action, type_id),
             {:ok, schema_obj} <- JSONParser.decode(data),
             {:ok, resolved_schema} <- SchemaValidation.resolve_schema(schema_obj) do
          SchemaStoreServer.set({action, type_id}, resolved_schema)
          {:ok, resolved_schema}
        end

      resolved_schema ->
        {:ok, resolved_schema}
    end
  end
end
