defmodule SnmpdExample_v1 do
  use Snmpd

  def variable_callback(".1.3.6.1.2.1.1.1.0"), do: "Hello World"
  def variable_callback(<<".1.3.6.1.2.1.25.17000.0">>), do: 1
  def variable_callback(<<".1.3.6.1.2.1.25.128.0">>), do: 0

  def variable_callback(_), do: "Unknown OID"

end
