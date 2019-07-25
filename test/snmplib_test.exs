defmodule SnmplibTest do
  use ExUnit.Case
  doctest Snmplib

  test "greets the world" do
    assert Snmplib.hello() == :world
  end
end
