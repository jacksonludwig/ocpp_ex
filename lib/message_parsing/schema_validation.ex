defmodule MessageParsing.SchemaValidation do
  @moduledoc """
  JSON schema validation.
  """
  defdelegate validate_schema(map_schema, map_data), to: ExJsonSchema.Validator, as: :validate
  defdelegate resolve(map_schema), to: ExJsonSchema.Schema
end
