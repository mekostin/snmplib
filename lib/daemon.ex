defmodule Snmpd do
  defmacro __using__(_) do
    quote do
      use GenServer
      def start_link(port), do: GenServer.start_link(__MODULE__, port)
      def init(port), do: :gen_udp.open(port, [:binary, active: true])
      defp send(data, socket, address, port), do: :gen_udp.send(socket, address, port, data)
      def handle_info({:udp, sock, address, port, data}, socket) do
        data
          |> IO.inspect(base: :hex, limit: :infinity)
          |> Snmplib.unpack
          |> response
          |> Snmplib.pack
          |> IO.inspect(base: :hex, limit: :infinity)
          |> send(sock, address, port)

        {:noreply, nil}
      end

      defp response(%{variable_bindings: vars} = data) do
        data
          |> Map.merge(%{type: "response"})
          |> Map.merge(%{variable_bindings: Enum.map(vars, &get_variable_value(&1))})
      end

      defp get_variable_value(%{oid: oid}), do: %{oid: oid, value: variable_callback(oid)}

    end
  end
end
