defmodule Bits do
  def extract(str), do: extract(str, [])

  defp extract(<<b::size(1), bits::bitstring>>, acc) do
    extract(bits, [b | acc])
  end

  defp extract(<<>>, acc), do: acc |> Enum.reverse
end
