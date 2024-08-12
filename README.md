# Garnish

[![Hex.pm Version](https://img.shields.io/hexpm/v/garnish)](https://hex.pm/packages/garnish)
![GitHub License](https://img.shields.io/github/license/ausimian/garnish)


`Garnish` is a terminal-UI (TUI) framework built around via Erlang's
[ssh](https://www.erlang.org/doc/apps/ssh/ssh.html) application.

[![asciicast](https://asciinema.org/a/5FPyUxdxDPMHNRjU13wrrcEWh.svg)](https://asciinema.org/a/5FPyUxdxDPMHNRjU13wrrcEWh)

## Installation

The package can be installed by adding `garnish` to your list of dependencies
in `mix.exs`:

```elixir
def deps do
  [
    {:garnish, "~> 0.1.0"}
  ]
end
```

## Architecture

The architecure is heavily based on the approach taken by
[Ratatouille](https://github.com/ndreynolds/ratatouille) - indeed the _entire_ view
and rendering code has been copied from that project. The main differences are:

1. The `Garnish.App` behaviour is a little more idiomatic in its callback style.
2. The result of the rendering process is translated into escape sequences without
    the ExTermbox NIF requirement.

## SSH Support

To expose your app via ssh, add `ssh` to the list of extra applications in mix.exs

```elixir
def application do
  [
    extra_applications: [:logger, :ssh, ...],
    mod: ...
  ]
end
```

and start the ssh daemon e.g. in your application's `start/2` callback:

```elixir
  @impl true
  def start(_type, _args) do
    opts = [
      # ... other ssh opts
      ssh_cli: {Garnish, app: My.App}
    ]
    {:ok, ref} = :ssh.daemon({127,0,0,1}, 2222, opts)

    children = [
    ]

    opts = [strategy: :one_for_one, name: My.Supervisor]
    with {:ok, pid} <- Supervisor.start_link(children, opts) do
      {:ok, pid, ref}
    end
  end

  @impl true
  def stop(ref) do
    :ssh.stop_daemon(ref)
  end
```

See the `Garnish.App` behaviour for details of the application model.

## Examples

To run the examples, first start the example, e.g.

    > mix run --no-halt examples/counter.exs

and then connect over ssh

    > ssh -o NoHostAuthenticationForLocalhost=yes -p 2222 localhost

## Credits

The entire view and logical rendering framework is lifted from
[Ratatouille](https://github.com/ndreynolds/ratatouille), with some renaming.

