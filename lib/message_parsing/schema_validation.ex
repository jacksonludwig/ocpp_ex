defmodule MessageParsing.SchemaValidation do
  @moduledoc """
  JSON schema validation.
  """

  @doc """
  Given a resolved schema and input, try to validate the input.
  """
  @spec validate(struct(), map()) :: :ok | {:error, :validation_failed, term()}
  def validate(resolved_schema, map_data) do
    case ExJsonSchema.Validator.validate(resolved_schema, map_data) do
      :ok -> :ok
      unexpected_return -> {:error, :validation_failed, unexpected_return}
    end
  end

  @doc """
  Given a map that describes a JSON schema, resolve it.
  """
  @spec resolve_schema(map()) :: {:ok, struct()} | {:error, :unable_to_resolve, term()}
  def resolve_schema(map_schema) do
    case ExJsonSchema.Schema.resolve(map_schema) do
      value when is_struct(value) -> {:ok, value}
      value -> {:error, :unable_to_resolve, value}
    end
  end
end
