defmodule GarnishTest do
  use ExUnit.Case
  doctest Garnish

  test "greets the world" do
    assert Garnish.hello() == :world
  end
end
