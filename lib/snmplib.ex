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

  @doc """
  pack SNMPv1
  """

  def pack(%{version: 1, community: comm} = packet) do
    pp = <<0x02, 0x01, 0x00,
           0x04, byte_size(comm), comm::binary,
           SNMPv1.pack(packet)::binary>>

    <<0x30, byte_size(pp), pp::binary>>
  end

  def pack(_), do: {:error, :bad_format}
end
