defmodule OcppEx do
  use Application

  @impl true
  def start(_type, _args) do
    children = [
      MessageParsing.SchemaStore,
      MessageStream.EventBus,
      MessageStream.EventLogger,
      MessageHandling.ResponseQueue,
      {V16.Configuration,
       %V16.ConfigurationState{
         charge_point_model: "Example Model",
         charge_point_vendor: "Example Vendor"
       }},
      V16.ChargePoint
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: OcppEx.Supervisor)
  end
end
