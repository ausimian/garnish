defmodule Garnish.Constants do
  @moduledoc """
  Defines constants from the termbox library. These can be used e.g. to set a
  formatting attributes or to identify keys passed in an event.
  """

  @type constant :: integer

  @type key :: constant
  @keys %{
    f1: 0xFFFF - 0,
    f2: 0xFFFF - 1,
    f3: 0xFFFF - 2,
    f4: 0xFFFF - 3,
    f5: 0xFFFF - 4,
    f6: 0xFFFF - 5,
    f7: 0xFFFF - 6,
    f8: 0xFFFF - 7,
    f9: 0xFFFF - 8,
    f10: 0xFFFF - 9,
    f11: 0xFFFF - 10,
    f12: 0xFFFF - 11,
    insert: 0xFFFF - 12,
    delete: 0xFFFF - 13,
    home: 0xFFFF - 14,
    end: 0xFFFF - 15,
    pgup: 0xFFFF - 16,
    pgdn: 0xFFFF - 17,
    arrow_up: 0xFFFF - 18,
    arrow_down: 0xFFFF - 19,
    arrow_left: 0xFFFF - 20,
    arrow_right: 0xFFFF - 21,
    mouse_left: 0xFFFF - 22,
    mouse_right: 0xFFFF - 23,
    mouse_middle: 0xFFFF - 24,
    mouse_release: 0xFFFF - 25,
    mouse_wheel_up: 0xFFFF - 26,
    mouse_wheel_down: 0xFFFF - 27,
    ctrl_tilde: 0x00,
    # clash with 'CTRL_TILDE'
    ctrl_2: 0x00,
    ctrl_a: 0x01,
    ctrl_b: 0x02,
    ctrl_c: 0x03,
    ctrl_d: 0x04,
    ctrl_e: 0x05,
    ctrl_f: 0x06,
    ctrl_g: 0x07,
    backspace: 0x08,
    # clash with 'CTRL_BACKSPACE'
    ctrl_h: 0x08,
    tab: 0x09,
    # clash with 'TAB'
    ctrl_i: 0x09,
    ctrl_j: 0x0A,
    ctrl_k: 0x0B,
    ctrl_l: 0x0C,
    enter: 0x0D,
    # clash with 'ENTER'
    ctrl_m: 0x0D,
    ctrl_n: 0x0E,
    ctrl_o: 0x0F,
    ctrl_p: 0x10,
    ctrl_q: 0x11,
    ctrl_r: 0x12,
    ctrl_s: 0x13,
    ctrl_t: 0x14,
    ctrl_u: 0x15,
    ctrl_v: 0x16,
    ctrl_w: 0x17,
    ctrl_x: 0x18,
    ctrl_y: 0x19,
    ctrl_z: 0x1A,
    esc: 0x1B,
    # clash with 'ESC'
    ctrl_lsq_bracket: 0x1B,
    # clash with 'ESC'
    ctrl_3: 0x1B,
    ctrl_4: 0x1C,
    # clash with 'CTRL_4'
    ctrl_backslash: 0x1C,
    ctrl_5: 0x1D,
    # clash with 'CTRL_5'
    ctrl_rsq_bracket: 0x1D,
    ctrl_6: 0x1E,
    ctrl_7: 0x1F,
    # clash with 'CTRL_7'
    ctrl_slash: 0x1F,
    # clash with 'CTRL_7'
    ctrl_underscore: 0x1F,
    space: 0x20,
    backspace2: 0x7F,
    # clash with 'BACKSPACE2'
    ctrl_8: 0x7F
  }

  @type color :: constant
  @colors %{
    default: 0x00,
    black: 0x01,
    red: 0x02,
    green: 0x03,
    yellow: 0x04,
    blue: 0x05,
    magenta: 0x06,
    cyan: 0x07,
    white: 0x08
  }

  @type attribute :: constant
  @attributes %{
    bold: 0x0100,
    underline: 0x0200,
    reverse: 0x0400
  }

  @type event_type :: constant
  @event_types %{
    key: 1,
    resize: 2,
    mouse: 3
  }

  @type error_code :: constant
  @error_codes %{
    unsupported_terminal: -1,
    failed_to_open_tty: -2,
    pipe_trap_error: -3
  }

  @type input_mode :: constant
  @input_modes %{
    current: 0,
    esc: 1,
    esc_with_mouse: 5,
    alt: 2,
    alt_with_mouse: 6,
    mouse: 4
  }

  @type output_mode :: constant
  @output_modes %{
    current: 0,
    normal: 1,
    term_256: 2,
    term_216: 3,
    grayscale: 4
  }

  @type hide_cursor :: constant
  @hide_cursor -1

  @doc """
  Retrieves the mapping of key constants for use with termbox.

  These are based on terminfo constants. Note that there's some overlap
  of terminfo values. For example, it's not possible to distinguish between
  `<backspace>` and `ctrl-h`.
  """
  @spec keys() :: %{atom => key}
  def keys, do: @keys

  @doc """
  Retrieves a key constant by name

  ## Examples

      iex> key(:esc)
      0x1B
      iex> key(:space)
      0x20

  """
  @spec key(atom) :: key
  def key(name), do: Map.fetch!(@keys, name)

  @doc """
  Retrieves the mapping of color constants.
  """
  @spec colors() :: %{atom => color}
  def colors, do: @colors

  @doc """
  Retrieves a color constant by name

  ## Examples

      iex> color(:red)
      0x02
      iex> color(:blue)
      0x05

  """
  @spec color(atom) :: color
  def color(name), do: Map.fetch!(@colors, name)

  @doc """
  Retrieves the mapping of attribute constants.
  """
  @spec attributes() :: %{atom => attribute}
  def attributes, do: @attributes

  @doc """
  Retrieves an attribute constant by name

  ## Examples

      iex> attribute(:bold)
      0x0100
      iex> attribute(:underline)
      0x0200

  """
  @spec attribute(atom) :: attribute
  def attribute(name), do: Map.fetch!(@attributes, name)

  @doc """
  Retrieves the mapping of event type constants.
  """
  @spec event_types() :: %{atom => event_type}
  def event_types, do: @event_types

  @doc """
  Retrieves an event type constant by name

  ## Examples

      iex> event_type(:key)
      0x01
      iex> event_type(:resize)
      0x02
      iex> event_type(:mouse)
      0x03

  """
  @spec event_type(atom) :: event_type
  def event_type(name), do: Map.fetch!(@event_types, name)

  @doc """
  Retrieves the mapping of error code constants.
  """
  @spec error_codes() :: %{atom => error_code}
  def error_codes, do: @error_codes

  @doc """
  Retrieves an error code constant by name

  ## Examples

      iex> error_code(:unsupported_terminal)
      -1

  """
  @spec error_code(atom) :: error_code
  def error_code(name), do: Map.fetch!(@error_codes, name)

  @doc """
  Retrieves the mapping of input mode constants.
  """
  @spec input_modes() :: %{atom => input_mode}
  def input_modes, do: @input_modes

  @doc """
  Retrieves an input mode constant by name

  ## Examples

      iex> input_mode(:esc)
      1
      iex> input_mode(:esc_with_mouse)
      5

  """
  @spec input_mode(atom) :: input_mode
  def input_mode(name), do: Map.fetch!(@input_modes, name)

  @doc """
  Retrieves the mapping of output mode constants.
  """
  @spec output_modes() :: %{atom => output_mode}
  def output_modes, do: @output_modes

  @doc """
  Retrieves an output mode constant by name

  ## Examples

      iex> output_mode(:term_256)
      2

  """
  @spec output_mode(atom) :: output_mode
  def output_mode(name), do: Map.fetch!(@output_modes, name)

  @doc """
  Retrieves the hide cursor constant.

  ## Examples

      iex> hide_cursor()
      -1

  """
  @spec hide_cursor() :: hide_cursor
  def hide_cursor, do: @hide_cursor
end
