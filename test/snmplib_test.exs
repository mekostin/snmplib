defmodule SnmplibTest do
  use ExUnit.Case
  doctest Snmplib

  test "parse" do
    request = <<
      0x30,
      0x29,
        0x02, 0x01, 0x00,
        0x04, 0x06, 0x70, 0x75, 0x62, 0x6c, 0x69, 0x63,
        0xa0, 0x1c,
          0x02, 0x04, 0x62, 0xd0, 0x72, 0x28,
          0x02, 0x01, 0x00,
          0x02, 0x01, 0x00,
          0x30, 0x0e,
            0x30, 0x0c,
              0x06, 0x08, 0x2b, 0x06, 0x01, 0x02, 0x01, 0x01, 0x01, 0x00,
              0x05, 0x00
    >>
    |> Snmplib.unpack

    assert is_map(request)
    assert [%SNMPv1.Variable{oid: ".1.3.6.1.2.1.1.1.0", value: nil}] == Map.get(request, :variable_bindings)

    # |> IO.inspect
    #
    #
    # with true <- is_map(answer),
    #      [%SNMPv1.Variable{oid: ".1.3.6.1.2.1.1.1.0", value: nil}] <- Map.get(answer, :variable_bindings) do
    #
    #   answer
    #     |> Map.merge(%{variable_bindings: [%SNMPv1.Variable{oid: ".1.3.6.1.2.1.1.1.0", value: "Parsed OK"}]})
    #     |> Snmplib.pack
    #     |> IO.inspect(base: :hex, limit: :infinity)
    # else
    #   _ -> IO.inspect answer
    # end
  end

  test "pack" do
    response = %SNMPv1.Packet{
      community: "public",
      error_index: 0,
      error_status: 0,
      request_id: 2821821491,
      type: "response",
      variable_bindings: [%SNMPv1.Variable{oid: ".1.3.6.1.2.1.1.1.0", value: "Parsed OK"}],
      version: 1
    }
    |> Snmplib.pack

    assert is_binary(response)
  end

  test "OID" do
    for x <- 990..1000 do
      for y <- 15000..65535 do
        oid = ".1.3.6.1.2.1.#{x}.#{y}.0"
          # |> IO.inspect
          |> Common.str2oid
          |> Common.oid2str

          assert oid == ".1.3.6.1.2.1.#{x}.#{y}.0"
      end
    end
  end
end
