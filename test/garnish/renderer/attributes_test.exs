defmodule Garnish.Renderer.AttributesTest do
  use ExUnit.Case, async: true

  alias Garnish.{Constants, Renderer.Attributes}

  describe "to_terminal_color/1" do
    test "with color as atom" do
      assert Attributes.to_terminal_color(:red) == Constants.color(:red)
    end

    test "with color as code" do
      assert Attributes.to_terminal_color(Constants.color(:red)) ==
               Constants.color(:red)
    end

    test "with 256-color index" do
      # xterm color 208 (orange) is stored as 209 (offset by 1)
      assert Attributes.to_terminal_color(209) == 209
    end

    test "with maximum 256-color index" do
      # xterm color 255 is stored as 256
      assert Attributes.to_terminal_color(256) == 256
    end

    test "when out of range" do
      assert_raise FunctionClauseError, fn ->
        Attributes.to_terminal_color(257)
      end
    end

    test "when negative" do
      assert_raise FunctionClauseError, fn ->
        Attributes.to_terminal_color(-1)
      end
    end
  end

  describe "to_terminal_attribute/1" do
    test "with color as atom" do
      assert Attributes.to_terminal_attribute(:bold) ==
               Constants.attribute(:bold)
    end

    test "with color as code" do
      assert Attributes.to_terminal_attribute(Constants.attribute(:bold)) ==
               Constants.attribute(:bold)
    end

    test "when invalid" do
      assert_raise KeyError, fn ->
        Attributes.to_terminal_attribute(1000)
      end
    end
  end
end
