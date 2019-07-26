defmodule Snmpd do
  defmacro __using__(_) do
    quote do
      use GenServer
      def start_link(port), do: GenServer.start_link(__MODULE__, port)
      def init(port), do: :gen_udp.open(port, [:binary, active: true])
      def send(data, socket, address, port), do: :gen_udp.send(socket, address, port, data)
      def handle_info({:udp, sock, address, port, data}, socket) do
        data |> request |> send(sock, address, port)
        {:noreply, nil}
      end
    end
  end
end
