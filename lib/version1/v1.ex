defmodule SNMPv1 do
  defmodule Variable do
    defstruct oid: nil, value: nil
  end

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
    unpack
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
    [%Variable{oid: Common.oid2str(oid)} | acc]
  end

  def unpack_vars(_, acc), do: acc

  @doc """
    pack
  """

  def pack(packet) do
    vars = pack_vars(packet, <<>>)
    <<0x00>>
  end

  def pack_vars(%{variable_bindings: [h | t]}, acc) do

  end

end
