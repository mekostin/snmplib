defmodule Snmpd_v1 do
  use Snmpd

  def request(data) do
    data
      |> IO.inspect(base: :hex, limit: :infinity)
      |> Snmplib.unpack
      |> IO.inspect
  end

end
