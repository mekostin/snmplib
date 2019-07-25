defmodule Snmplib do
  @moduledoc """
  Documentation for Snmplib.
  """
  def parse(<<0x30, length::little-size(8), tail::binary>>) do
    # IO.inspect "LEN = #{length}"
    if length == byte_size(tail) do
      tail |> parse
    else
      {:error, :packet_size}
    end
  end

  @doc """
  parse SNMPv1
  """
  def parse(<<0x02, 0x01, 0x00, tail::binary>>), do: SNMPv1.unpack(tail)
  def parse(_), do: {:error, :bad_format}
end
