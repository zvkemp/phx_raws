defmodule SocketTest do
  use ExUnit.Case, async: true
  import ExUnit.CaptureLog

  import Phoenix.Socket
  alias Phoenix.Socket.{Message, InvalidMessageError}
  require IEx

  # Setup adapted from Phoenix socket integration tests:
  # https://github.com/phoenixframework/phoenix/blob/master/test/phoenix/integration/websocket_test.exs

  defmodule TestSocket do
    use Phoenix.Socket

    transport :websocket, Phoenix.Transports.WebSocket.Raw

    def connect(_, socket) do
      send(socket.transport_pid, {:text, "confirm connect"})
      {:ok, socket}
    end

    def id(_), do: nil

    def handle(:text, message, %{ socket: %{ transport_pid: socket }} = state) do
      IO.inspect(message)
      %{ "echo" => count } = Poison.decode!(message)
      send(socket, {:text, "#{count}"})
      send(socket, {:text, "complete"})
      state
    end

    def handle(:closed, _reason, _state) do
      # IO.inspect({:closing, _reason, _state})
    end
  end

  Application.put_env(:phx_raws, SocketTest.Endpoint, [
    https: false,
    http: [port: 5807], # TODO: pick port from OS?
    secret_key_base: String.duplicate("abcdefgh", 8),
    debug_errors: true,
    server: true,
    handler: Phoenix.Endpoint.CowboyHandler,
    pubsub: [adapter: Phoenix.PubSub.PG2, name: __MODULE__]
  ])

  defmodule Endpoint do
    use Phoenix.Endpoint, otp_app: :phx_raws

    socket "/ws", TestSocket
  end

  defmodule TestSocketClient do
    def connect! do
      Socket.Web.connect!()
    end
  end

  setup_all do
    capture_log fn ->
      Endpoint.start_link()
    end

    :ok
  end

  setup do
    {:ok, client} = Socket.Web.connect({"0.0.0.0", 5807}, path: "/ws/websocket")
    assert {:text, "confirm connect"} = Socket.Web.recv!(client)
    {:ok, %{client: client}}
  end

  test "it receives a connection message", %{client: client} do
    # assert {:text, "confirm connect"} = Socket.Web.recv!(client)
  end

  test "it responds with a sequence of messages", %{client: client} do
    # assert {:text, "confirm connect"} = Socket.Web.recv!(client)
    Socket.Web.send!(client, {:text, "{ \"echo\": 2 }"})
    assert {:text, "2"} = Socket.Web.recv!(client)
    assert {:text, "complete"} = Socket.Web.recv!(client)
  end

  test "error handling", %{client: client} do
    # assert {:text, "confirm connect"} = Socket.Web.recv!(client)
    Socket.Web.close(client)
    # IEx.pry
    # assert_receive {:DOWN, _, :process, ^client, :normal}
    # TODO ^ what to test here? Port is closed? Server-side socket is shut down?
  end
end
