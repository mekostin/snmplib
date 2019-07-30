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
    <<community::bytes-size(com_len), 0xA0, pdu_len::little-size(8), pdu::binary>> = tail
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
    pack_vars(<<>>, packet)
      |> pack_pdu(packet)
  end

  def pack_vars(acc, %{variable_bindings: []}), do: <<0x30, byte_size(acc), acc::binary>>
  def pack_vars(acc, %{variable_bindings: [%{oid: s_oid, value: value} | t]}) do
    oid = Common.str2oid(s_oid)
    acc = <<0x06, byte_size(oid), oid::binary, pack_value(value)::binary, acc::binary>>
    <<0x30, byte_size(acc), acc::binary>>
      |> pack_vars(%{variable_bindings: t})
  end

  def pack_value(value) when is_binary(value) do
    <<0x04, byte_size(value), value::binary>>
  end

  def pack_value(value) when is_integer(value) do
    bytes = Common.sizeof(value)
    bits = bytes * 8
    <<0x02, bytes, value::integer-size(bits)>>
  end

  def pack_pdu(acc, %{error_index: err_i, error_status: err_s, request_id: req_id}) do
    acc = <<0x02, 0x04, req_id::little-size(32),
            0x02, 0x01, err_s::size(8),
            0x02, 0x01, err_i::size(8), acc::binary>>

    <<0xa2, byte_size(acc), acc::binary>>
  end

end
