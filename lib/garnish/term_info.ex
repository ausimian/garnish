defmodule Garnish.TermInfo do
  @moduledoc """
  A behaviour for defining the terminfo sequences a 'terminal'
  module should support.
  """

  @doc "Returns the keymap for the terminal"
  @callback get_keymap() :: %{required(String.t()) => :atom}
  @doc "Make the cursor invisible"
  @callback civis() :: binary()
  @doc "Clear the screen"
  @callback clear() :: binary()
  @doc "Restore the cursor"
  @callback cnorm() :: binary()
  @doc "Return the number of colors supported by the terminal"
  @callback colors() :: non_neg_integer()
  @doc "Move the cursor to the specified position"
  @callback cup(row :: non_neg_integer(), col :: non_neg_integer()) :: binary()
  @doc "Restore the main buffer"
  @callback rmcup() :: binary()
  @doc "Restore the terminal mode"
  @callback rmkx() :: binary()
  @doc "Set the background color"
  @callback setab(bg :: non_neg_integer()) :: binary()
  @doc "Set the foreground color"
  @callback setaf(fg :: non_neg_integer()) :: binary()
  @doc "Set the graphic attributes"
  @callback sgr(flags :: non_neg_integer()) :: binary()
  @doc "Clear the graphic attributes"
  @callback sgr0() :: binary()
  @doc "Save the main buffer and switch to the alternate buffer"
  @callback smcup() :: binary()
  @doc "Set the terminal to application mode"
  @callback smkx() :: binary()

  @optional_callbacks rmkx: 0, smkx: 0

  @supported %{
    "xterm-256color" => Garnish.TermInfo.Xterm256color
  }

  @doc """
  Look up the terminal module by name, returning nil if not supported.
  """
  @spec lookup(name :: String.t()) :: module() | nil
  def lookup(name) do
    Map.get(@supported, name)
  end

  defmacro __using__(_opts) do
    quote do
      @behaviour Garnish.TermInfo
      defguardp bitset?(flags, n) when Bitwise.band(flags, Bitwise.bsl(1, n)) != 0
    end
  end
end
