defmodule Garnish do
  @moduledoc """
  Implements the `:ssh_server_channel` behaviour on behalf of the app.
  """

  @behaviour :ssh_server_channel

  use TypedStruct

  import Bitwise

  alias Garnish.Cell

  require Logger

  typedstruct opaque: true do
    # ssh connection
    field(:conn, pid() | nil)
    # ssh channel id
    field(:chan, integer() | nil)
    # handling module for the terminal
    field(:term, module() | nil)
    # Number of rows
    field(:rows, non_neg_integer() | nil)
    # Number of cols
    field(:cols, non_neg_integer() | nil)
    # The process environment passed by ssh
    field(:env, %{String.t() => String.t()}, default: %{})
    # The 'app' module
    field(:app, module())
    # The args passed to app.init
    field(:init_args, any(), default: [])
    # The model data
    field(:model, any())
    # The renderer
    field(:renderer, module(), default: Garnish.Renderer)
    # The canvas
    field(:canvas, module(), default: Garnish.Renderer.Canvas)
    # The back buffer
    field(:back_buffer, map(), default: %{})
    # Term key map
    field(:key_map, %{String.t() => :atom}, default: %{})
    # Quit keys
    field(:quit_keys, list(integer()), default: [3])
  end

  @impl true
  def init(args) do
    case Keyword.fetch!(args, :app) do
      app when is_atom(app) ->
        {:ok, %__MODULE__{app: app, init_args: []}}

      {app, args} when is_atom(app) ->
        {:ok, %__MODULE__{app: app, init_args: args}}
    end
  end

  @impl true
  def handle_msg({:ssh_channel_up, chan, conn}, %__MODULE__{conn: nil, chan: nil} = state) do
    # Typically the first message after process creation - a new connection/channel has
    # been established.
    {:ok, %__MODULE__{state | conn: conn, chan: chan}}
  end

  def handle_msg(msg, %__MODULE__{app: app} = state) do
    if function_exported?(app, :handle_info, 2) do
      handle_response(app.handle_info(msg, state.model), state)
    else
      Logger.debug("Unhandled message: #{inspect(msg)}")
      {:ok, state}
    end
  end

  @impl true
  # Process a key
  def handle_ssh_msg(
        {:ssh_cm, conn, {:data, chan, 0, data}},
        %__MODULE__{conn: conn, chan: chan} = state
      ) do
    event = decode_key(data, state.key_map)

    if Enum.member?(state.quit_keys, event.key) do
      stop({:shutdown, :quit}, state)
    else
      handle_response(state.app.handle_key(event, state.model), state)
    end
  end

  # Process a window resize
  def handle_ssh_msg(
        {:ssh_cm, conn, {:window_change, chan, cols, rows, _, _}},
        %__MODULE__{conn: conn, chan: chan} = state
      ) do
    if function_exported?(state.app, :handle_resize, 2) do
      case state.app.handle_resize({rows, cols}, state.model) do
        {:ok, model} ->
          render(%__MODULE__{state | model: model, back_buffer: %{}, cols: cols, rows: rows})

        {:stop, reason, model} ->
          stop(reason, %__MODULE__{state | model: model})
      end
    else
      render(%__MODULE__{state | back_buffer: %{}, cols: cols, rows: rows})
    end
  end

  # Allocate a new terminal, just record the properties passed for now
  def handle_ssh_msg(
        {:ssh_cm, conn, {:pty, chan, wr, props}},
        %__MODULE__{conn: conn, chan: chan} = state
      ) do
    {term, cols, rows, _, _, _} = props

    if mod = Garnish.TermInfo.lookup(to_string(term)) do
      :ssh_connection.reply_request(conn, wr, :success, chan)
      init_term(%__MODULE__{state | term: mod, cols: cols, rows: rows, key_map: mod.get_keymap()})
    else
      :ssh_connection.reply_request(conn, wr, :failure, chan)
      {:stop, :no_terminfo, state}
    end
  end

  # Record any environment variables passed by the client
  def handle_ssh_msg(
        {:ssh_cm, conn, {:env, chan, wr, key, val}},
        %__MODULE__{conn: conn, chan: chan} = state
      ) do
    :ssh_connection.reply_request(conn, wr, :success, chan)
    {:ok, %__MODULE__{state | env: Map.put(state.env, to_string(key), to_string(val))}}
  end

  # Start the app - this 'shell' message arrives _after_ the 'pty' and
  # 'env' messages
  def handle_ssh_msg(
        {:ssh_cm, conn, {:shell, chan, wr}},
        %__MODULE__{conn: conn, chan: chan} = state
      ) do
    context = %{
      args: state.init_args,
      size: {state.rows, state.cols},
      environment: state.env,
      connection: conn
    }

    case state.app.init(context) do
      {:ok, model} ->
        on_model_init(state, model, wr)

      {:ok, model, opts} ->
        on_model_init(state, model, wr, opts)

      {:stop, _reason} ->
        {:stop, chan, state}

      {:error, _reason} ->
        {:stop, chan, state}
    end
  end

  def handle_ssh_msg(msg, state) do
    Logger.debug("cli: unhandled ssh message: #{inspect(msg)}")
    {:ok, state}
  end

  @impl true
  def terminate(reason, %__MODULE__{app: app} = state) do
    if function_exported?(app, :terminate, 2) do
      app.terminate(reason, state.model)
    end
  end

  defp handle_response({:ok, model}, %__MODULE__{} = state),
    do: handle_response({:ok, model, []}, state)

  defp handle_response({:ok, model, opts}, %__MODULE__{} = state) do
    next_state = %__MODULE__{state | model: model}

    if Keyword.get(opts, :render, true) do
      render(next_state)
    else
      {:ok, next_state}
    end
  end

  defp handle_response({:stop, reason, model}, %__MODULE__{} = state) do
    stop(reason, %__MODULE__{state | model: model})
  end

  defp on_model_init(%__MODULE__{} = state, model, wr, opts \\ []) do
    :ok = :ssh_connection.reply_request(state.conn, wr, :success, state.chan)

    render(%__MODULE__{
      state
      | model: model,
        quit_keys: Keyword.get(opts, :quit_keys, state.quit_keys)
    })
  end

  defp init_term(%__MODULE__{term: mod, conn: conn, chan: chan} = state) do
    [:smcup, :smkx, :civis]
    |> Enum.filter(&function_exported?(mod, &1, 0))
    |> Enum.map(&apply(mod, &1, []))
    |> Enum.each(&:ssh_connection.send(conn, chan, &1))

    {:ok, state}
  end

  defp decode_key(data, _) when byte_size(data) == 1,
    do: %{data: data, key: :binary.at(data, 0), alt: false}

  defp decode_key(<<27, ch::8>> = data, _), do: %{data: data, key: ch, alt: true}

  defp decode_key(data, key_map) do
    if mnemonic = Map.get(key_map, data) do
      %{data: data, key: mnemonic, alt: false}
    else
      %{data: data, key: nil, alt: false}
    end
  end

  defp stop(_reason, %__MODULE__{conn: conn, chan: chan, term: mod} = state) do
    [:rmkx, :rmcup, :cnorm]
    |> Enum.filter(&function_exported?(mod, &1, 0))
    |> Enum.map(&apply(mod, &1, []))
    |> Enum.each(&:ssh_connection.send(conn, chan, &1))

    {:stop, chan, state}
  end

  #
  # Rendering is done here, directly in the connection process.
  #
  defp render(%__MODULE__{app: app, model: model} = state) do
    render_view(app.render(model), state)
  end

  defp render_view(view, %__MODULE__{cols: cols, rows: rows, term: term} = state) do
    empty_canvas = state.canvas.from_dimensions(cols, rows)

    case state.renderer.render(empty_canvas, view) do
      {:ok, %{cells: cells}} ->
        # Discard all unchanged cells
        case invalid_cells(cells, state.back_buffer) do
          diff when map_size(diff) > 0 ->
            # Send a clear if we are redrawing everything
            pref = if map_size(state.back_buffer) == 0, do: term.clear(), else: <<>>
            # Sort the cells by row, column and then call render_cells/2 to
            # get a binary
            data =
              diff
              |> Enum.sort_by(fn {%{x: x, y: y}, _} -> {y, x} end)
              |> render_cells(term, pref)

            # Send the data to the terminal
            if byte_size(data) > 0 do
              :ok = :ssh_connection.send(state.conn, state.chan, data)
            end

            # Update the back buffer with the diff
            {:ok, %__MODULE__{state | back_buffer: Map.merge(state.back_buffer, diff)}}

          _ ->
            {:ok, state}
        end

      {:error, error} ->
        Logger.error("Render error: #{inspect(error)}")
        {:stop, :failed, state}
    end
  end

  defp invalid_cells(front_buffer, back_buffer) do
    if map_size(back_buffer) == 0 do
      front_buffer
    else
      Map.merge(
        changed_cells(front_buffer, back_buffer),
        dropped_cells(front_buffer, back_buffer)
      )
    end
  end

  defp changed_cells(front_buffer, back_buffer) do
    Map.reject(front_buffer, fn {k, v} -> v == Map.get(back_buffer, k) end)
  end

  defp dropped_cells(front_buffer, back_buffer) do
    back_buffer
    |> Map.reject(fn {k, _} -> is_map_key(front_buffer, k) end)
    |> Map.new(fn {k, _} -> {k, %Cell{position: k, ch: ?\s}} end)
  end

  defp render_cells(cells, term, prefix), do: render_cells(cells, nil, term, prefix)

  #
  # render_cells/4 is effectively a reduction, walking the ordered list
  # of cells and building a binary. It's done this way, rather than via
  # `Enum.reduce/3`, to allow the compiler to optimize the building of
  # the binary (although I haven't measured anything tbh)
  #
  # The optimization is that consecutive cells with the same attributes
  # result only in the new data being appended to the binary
  #
  defp render_cells([], _, _, data), do: data

  defp render_cells(
         [{_, %{position: %{x: x, y: y}, fg: fg, bg: bg, ch: ch} = curr} | next],
         %{position: %{x: xp, y: y}, fg: fg, bg: bg},
         term,
         data
       )
       when x == xp + 1 do
    # Only add the data if the attributes are the same in row-consective cells
    render_cells(next, curr, term, <<data::binary, ch::utf8>>)
  end

  defp render_cells(
         [{_, %{position: %{x: x, y: y}, fg: fg, bg: bg, ch: ch} = curr} | next],
         _,
         term,
         data
       ) do
    # Otherwise, explicitly move the cursor and set the attributes and the data
    # There is further optimisation not implemented here - if the cells are row-consecutive
    # there is no need for the 'cup'.
    render_cells(
      next,
      curr,
      term,
      <<
        data::binary,
        term.cup(y, x)::binary,
        sgr(fg &&& 0xFF00, term)::binary,
        set_colors(fg &&& 0xFF, bg &&& 0xFF, term)::binary,
        ch::utf8
      >>
    )
  end

  defp set_colors(0, 0, _), do: <<>>

  defp set_colors(fg, bg, term) do
    <<term.setaf(fg - 1)::binary, term.setab(bg - 1)::binary>>
  end

  defp sgr(0, term) when is_atom(term), do: term.sgr0()

  defp sgr(f, term) when is_atom(term) do
    flags = 0
    # reverse
    flags = flags ||| if (f &&& 0x400) == 0x400, do: 0b00000100, else: 0
    # underline
    flags = flags ||| if (f &&& 0x200) == 0x200, do: 0b00000010, else: 0
    # bold
    flags = flags ||| if (f &&& 0x100) == 0x100, do: 0b00100000, else: 0
    term.sgr(flags)
  end
end
