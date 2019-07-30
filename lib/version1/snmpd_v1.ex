defmodule SnmpdExample_v1 do
  use Snmpd

  def variable_callback(".1.3.6.1.2.1.1.1.0"), do: "Hello World"
  def variable_callback(<<".1.3.6.1.2.1.25.", tail::binary>>) do
    tail
      |> String.split(".")
      |> hd
      |> String.to_integer
      |> rem(2)
  end

  def variable_callback(_), do: "Unknown OID"

end
