defmodule Snmplib do
  @moduledoc """
  Documentation for Snmplib.
  """
  def unpack(<<0x30, length::little-size(8), tail::binary>>) do
    # IO.inspect "LEN = #{length}"
    if length == byte_size(tail) do
      tail |> unpack
    else
      {:error, :packet_size}
    end
  end

  @doc """
  parse SNMPv1
  """
  def unpack(<<0x02, 0x01, 0x00, tail::binary>>), do: SNMPv1.unpack(tail)
  def unpack(_), do: {:error, :bad_format}

  def pack(%{version: 1} = packet) do
    pp = <<0x02, 0x01, 0x00>> <> SNMPv1.pack(packet)
    <<0x30, byte_size(pp)>>  <> pp
  end

  def pack(_), do: {:error, :bad_format}
end
