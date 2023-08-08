defmodule MessageHandling.ChargePoint do
  # TODO

  # def handle_cs_call("TriggerMessage", message = %RequestResponse{}) do
  # end

  def handle_cs_call(unknown_message, _message) do
    {:error, :unknown_call_from_cs, unknown_message}
  end
end
