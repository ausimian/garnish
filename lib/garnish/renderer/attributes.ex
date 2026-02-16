defmodule Garnish.Renderer.Attributes do
  @moduledoc """
  Functions for working with element attributes
  """

  alias Garnish.Constants

  @valid_attribute_codes Constants.attributes() |> Map.values()

  # Accept any integer in the valid range for termbox colors.
  # 0 = default, 1-8 = standard colors, 9-256 = extended 256-color palette.
  def to_terminal_color(code)
      when is_integer(code) and code >= 0 and code <= 256 do
    code
  end

  def to_terminal_color(name) when is_atom(name) do
    Constants.color(name)
  end

  def to_terminal_attribute(code)
      when is_integer(code) and code in @valid_attribute_codes do
    code
  end

  def to_terminal_attribute(name) do
    Constants.attribute(name)
  end
end
