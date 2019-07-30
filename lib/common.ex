defmodule Common do
  use Bitwise

  def bit_extract(str), do: bit_extract(str, [])

  defp bit_extract(<<b::size(1), bits::bitstring>>, acc) do
    bit_extract(bits, [b | acc])
  end

  defp bit_extract(<<>>, acc), do: acc |> Enum.reverse

  def oid2str(oid) do
    oid
      |> :binary.bin_to_list
      |> Enum.reduce(%{prev: [], result: <<>>}, &calc_sub(&1, &2))
      |> Map.get(:result)
  end

  def calc_sub(sub, %{prev: [], result: <<>>})
  when (sub >= 40), do: %{prev: [], result: ".#{div(sub, 40)}.#{rem(sub, 40)}"}

  def calc_sub(sub, %{prev: [], result: acc})
  when (sub &&& 0x80) == 0, do: %{prev: [], result: "#{acc}.#{sub}"}

  def calc_sub(sub, %{prev: prev, result: acc})
  when (sub &&& 0x80) != 0, do: %{prev: [sub &&& 0x7F | prev], result: acc}

  def calc_sub(sub, %{prev: prev, result: acc} = result)
  when (sub &&& 0x80) == 0 do
    prev = [sub | prev]
    sz = (Enum.count(prev) * 8) - Enum.count(prev)
    <<val::integer-size(sz)>> = Enum.reduce(prev, <<>>, fn (x, acc) -> <<x::size(7), acc::bitstring>> end)
    %{prev: [], result: "#{acc}.#{val}"}
  end


  def str2oid(str) do
    str
      |> String.trim(".")
      |> String.split(".")
      |> Enum.map(&String.to_integer(&1))
      |> Enum.reduce(%{prev: [], result: <<>>}, &sub_calc(&1, &2))
      |> Map.get(:result)
  end

  def sub_calc(sub, %{prev: [], result: <<>>}), do: %{prev: [sub * 40], result: <<>>}
  def sub_calc(sub, %{prev: [prev], result: <<>>}), do: %{prev: [], result: <<prev + sub>>}

  def sub_calc(sub, %{prev: [], result: acc})
  when (sub >= 0x80), do: sub_calc(sub >>> 7, %{prev: [<<0::size(1), sub::size(7)>>], result: acc})

  def sub_calc(sub, %{prev: prev, result: acc})
  when (sub >= 0x80), do: sub_calc(sub >>> 7, %{prev: [<<1::size(1), sub::size(7)>> | prev], result: acc})

  def sub_calc(sub, %{prev: [], result: acc})
  when sub < 0x80, do: %{prev: [], result: acc <> <<sub>>}

  def sub_calc(sub, %{prev: prev, result: acc})
  when (sub < 0x80) do
    prev = [<<1::size(1), sub::size(7)>> | prev]
    %{prev: [], result: acc <> Enum.reduce(prev, <<>>, fn(x, a) -> a <> x end)}
  end

  def sizeof(value) when is_binary(value), do: byte_size(value)
  def sizeof(value) when is_integer(value) do
    cond do
      (value &&& 0xFF000000)!=0 -> 4
      (value &&& 0x00FF0000)!=0 -> 3
      (value &&& 0x0000FF00)!=0 -> 2
      true -> 1
    end
  end

end
