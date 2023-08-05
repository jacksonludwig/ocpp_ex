defmodule OcppEx do
  use Application

  @impl true
  def start(_type, _args) do
    children = [
      MessageHandling.ResponseQueue,
      MessageParsing.SchemaStore
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: OcppEx.Supervisor)
  end
end
