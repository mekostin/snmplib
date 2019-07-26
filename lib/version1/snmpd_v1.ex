defmodule Snmpd_v1 do
  use Snmpd

  def request(data) do
    data
      |> IO.inspect(base: :hex, limit: :infinity)
      |> Snmplib.parse
      |> IO.inspect
  end

end
