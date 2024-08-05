# An example that shows the basics of event handling and rendering.
#
# Run this example with:
#
#   mix run examples/counter.exs

defmodule Counter do
  @behaviour Garnish.App

  import Garnish.View

  def init(_context), do: {:ok, 0}

  def handle_key(%{key: key}, model) do
    case key do
      ?+ -> {:ok, model + 1}
      ?- -> {:ok, model - 1}
      _ -> {:ok, model, render: false}
    end
  end

  def render(model) do
    view do
      label(
        content: "Counter is #{model} (+/- to increment/decrement, Ctrl-C to quit)"
      )
    end
  end
end

opts = [
  system_dir: Path.join(__DIR__, ".keys") |> to_charlist,
  ssh_cli: {Garnish, app: {Counter, []}},
  no_auth_needed: true,
]
:ssh.daemon({127, 0, 0, 1}, 2222, opts)
