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
      |> Enum.reduce(%{prev: nil, result: <<>>}, &calc_sub(&1, &2))
      |> Map.get(:result)
  end

  def calc_sub(sub, %{prev: nil, result: <<>>})
  when (sub >= 40), do: %{prev: nil, result: ".#{div(sub, 40)}.#{rem(sub, 40)}"}

  def calc_sub(sub, %{prev: nil, result: acc})
  when (sub &&& 0x80) == 0x80, do: %{prev: sub, result: "#{acc}"}

  def calc_sub(sub, %{prev: nil, result: acc}), do: %{prev: nil, result: "#{acc}.#{sub}"}

  def calc_sub(sub, %{prev: prev_80, result: acc} = result) do
    <<tmp::integer-size(16)>> = <<0x00::size(2), prev_80::size(7), sub::size(7)>>
    %{prev: nil, result: "#{acc}.#{tmp}"}
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

  def sub_calc(sub, %{prev: prev, result: acc})
  when (sub > 127) and (sub &&& 0x80) == 0 do
    IO.inspect {sub, prev}
    sub_calc(sub >>> 7, %{prev: [ <<sub::size(7)>> | prev], result: acc})
  end

  def sub_calc(sub, %{prev: prev, result: acc})
  when (sub > 127) and (sub &&& 0x80) != 0 do
    IO.inspect {sub, prev}
    sub_calc(sub >>> 7, %{prev: [ <<sub::size(7)>> | prev], result: acc})
  end


  def sub_calc(sub, %{prev: [], result: acc}), do: %{prev: [], result: acc <> <<sub>>}

  def sub_calc(sub, %{prev: prev, result: acc}) do
    %{prev: [], result: acc <> Enum.reduce(prev, <<>>, fn(x, acc) -> acc <> x end)  <> <<sub>>}
  end
end
