defmodule OcppEx do
  use Application

  @impl true
  def start(_type, _args) do
    children = [
      MessageParsing.SchemaStore,
      MessageStream.EventBus,
      MessageStream.EventLogger,
      MessageHandling.ResponseQueue
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: OcppEx.Supervisor)
  end
end
