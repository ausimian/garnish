defmodule Garnish.App do
  @moduledoc """
  Defines the `Garnish.App` behaviour. It provides the structure for
  architecting both large and small terminal applications, over SSH.

  The entrypoint to the application is defined by parameters to the
  [ssh_cli](https://www.erlang.org/doc/apps/ssh/ssh.html#t:ssh_cli_daemon_option/0)
  daemon option.

  ## A Simple Example

      # Assumes that `:ssh_cli` daemon option was set to:
      # ssh_cli: {Garnish, {Counter.App, []}}

      defmodule Counter.App do
        @behaviour Garnish.App

        # Initialize our model state
        def init(_context), do: {:ok, 0}

        # Respond to key presses
        def handle_key(%{key: key}, model) do
          case key do
            ?+ -> {:ok, model + 1}
            ?- -> {:ok, model - 1}
            _ -> {:ok, model, render: false}
        end

        # Turn the model into view
        def render(model) do
          view do
            label(content: "Counter is \#{model} (+/-)")
          end
        end
      end

  ## Callbacks

  The behaviour describes 3 mandatory and 3 optional callbacks. The mandatory
  callbacks are:

  * `c:init/1` for setting the initial model state
  * `c:handle_key/2` for handling keys from the client
  * `c:render/1` for rendering the model to a view

  The three optional callbacks are:

  * `c:handle_resize/2` for handling resize events
  * `c:handle_info/2` for handling all other messages
  * `c:terminate/2` for handling process termination

  For all the `handle_/2` callbacks, it is possible to disable re-rendering,
  even after a model update, by returning `[render: false]` from the callback.
  This is useful if the model has 'private' data that does not itself affect
  the view.
  """

  alias Garnish.Renderer.Element

  @type row_count :: non_neg_integer()
  @type col_count :: non_neg_integer()
  @type dimension :: {row_count(), col_count()}

  @type context :: %{
          required(:args) => term(),
          required(:size) => dimension(),
          required(:environment) => %{required(String.t()) => String.t()},
          required(:connection) => :ssh.connection_ref()
        }
  @type model :: term
  @type msg :: term
  @type reason :: term

  @type key_event :: %{data: binary(), key: integer() | atom(), alt: boolean()}

  @type init_opt :: {:quit_keys, list(integer())}
  @type init_opts :: [init_opt()]

  @type handle_opt :: {:render, boolean()}
  @type handle_opts :: [handle_opt()]

  @doc """
  The `init/1` callback defines the initial model. The context is a map with the
  following keys:

  - `args` the args passed as passed to `ssh_cli`, defaults to `[]`
  - `size` the size of the initial window passed as `{rows, cols}`
  - `environment` the environment passed from the client
  - `connection` the ssh connection reference. This may be used to query information
    via `:ssh.connection_info/1`

  The callback should return the initial state on success or an error otherwise.
  Additionally, on success, the client may return some options that adjust the behaviour
  of the app. The currently supported values are:

  - `quit_keys` a list of integers that determine which keys will automatically close
    the app. If not specified, defaults to ctrl-c (`[3]`).
  """
  @callback init(context) ::
              {:ok, model}
              | {:ok, model, init_opts}
              | {:stop | :error, reason}

  @doc """
  Handle a key-press from the client.

  The key event is a map containing the following entries:

  - `key` an integer or mnenomic representing the key pressed. Most literal
    keys are expressed as an integer. Other keys are expressed as an atom
    based on their terminal settings such as `:kcud1` for left-arrow. The mnemomics
    are derived from their terminfo specifications (see [the terminfo manual page](https://man7.org/linux/man-pages/man5/terminfo.5.html))
    for more details.
  - `alt` a boolean indicating whether the alt-key was pressed
  - `data` the raw data from the connection
  """
  @callback handle_key(key_event, model) ::
              {:ok, model}
              | {:ok, model, handle_opts()}
              | {:stop, reason, model}

  @doc """
  Handle a resize event from the client.

  This callback is optional. If not specified, the default behaviour is render the
  existing model again (for the new size).
  """
  @callback handle_resize(dimension(), model) ::
              {:ok, model}
              | {:stop, reason, model}

  @doc """
  Handle an event.

  Used to handle any non-key/non-resize message. This callback is optional. If
  not specified, the message is ignored.
  """
  @callback handle_info(term(), model) ::
              {:ok, model}
              | {:ok, model, handle_opts()}
              | {:stop, reason, model}

  @doc """
  The `render/1` callback defines how to render the model as a view.

  It should return a `Garnish.Renderer.Element` with the `:view` tag. For example:

      @impl true
      def render(model) do
        view do
          label(content: "Hello, \#{model.name}!")
        end
      end

  """
  @callback render(model) :: Element.t()

  @doc """
  Handle termination of the application.

  This callback is optional and can be used for arbitrary clean-up. Note that the
  client's session has already been closed by the time this callback in invoked.
  """
  @callback terminate(reason :: :normal | :shutdown | {:shutdown, term()} | term(), state :: term) ::
              term()

  @optional_callbacks handle_resize: 2, handle_info: 2, terminate: 2
end
