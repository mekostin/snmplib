defmodule SNMPv1 do
  use Bitwise

  defmodule Packet do
    defstruct version: nil,
      community: nil,
      type: nil,
      request_id: nil,
      error_status: nil,
      error_index: nil,
      variable_bindings: []
  end


  @doc """
    unpack REQUEST A0
  """
  def unpack(<<0x04, com_len::little-size(8), tail::binary>>) do
    # IO.inspect "COM_LEN = #{com_len}"
    <<community::bytes-size(com_len), 0xA0, pdu_len::little-size(8), pdu::binary>> = tail
    # IO.inspect "COMMUNITY = #{community}"
    # IO.inspect "PDU_LEN = #{pdu_len}"
    if pdu_len == byte_size(pdu) do
      %Packet{version: 1, community: community, type: "request"}
        |> Map.merge(unpack_pdu(pdu))
    else
      {:error, :pdu_size}
    end
  end

  def unpack_pdu(<<0x02,0x04, request_id::little-size(32),
                   0x02, 0x01, error_status::little-size(8),
                   0x02, 0x01, error_index::little-size(8),
                   vars::binary>>) do
    %{request_id: request_id,
      error_status: error_status,
      error_index: error_index,
      variable_bindings: unpack_vars(vars)}
  end

  def unpack_vars(<<0x30, var_len::little-size(8), tail::binary>>)
  when var_len == byte_size(tail), do: unpack_vars(tail, [])

  def unpack_vars(_), do: {:error, :variable_bindings_size}

  def unpack_vars(<<0x30, _var_len::little-size(8), 0x06, oid_len::little-size(8), variable::binary>>, acc) do
    <<oid::bytes-size(oid_len), 0x05, 0x00, tail::binary>> = variable
    [oid2str(oid) | acc]
  end

  def unpack_vars(_, acc), do: acc

  def oid2str(oid) do
    oid
      |> :binary.bin_to_list
      |> Enum.reduce(%{prev: nil, result: <<>>}, &calc_sub(&1, &2))
      |> Map.get(:result) 
  end

  def calc_sub(sub, %{prev: nil, result: acc}) do
    cond do
      band(sub, 40) == 40 -> %{prev: nil, result: "#{acc}.1.#{sub-40}"}
      band(sub, 128) == 128 -> %{prev: sub, result: "#{acc}"}
      true -> %{prev: nil, result: "#{acc}.#{sub}"}
    end
  end

  def calc_sub(sub, %{prev: prev_80, result: acc} = result) do
    <<tmp::integer-size(16)>> = <<0x00::size(2), prev_80::size(7), sub::size(7)>>
    %{prev: nil, result: "#{acc}.#{tmp}"}
  end

end
