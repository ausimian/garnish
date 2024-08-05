defmodule Garnish.Renderer.Element.SparklineTest do
  use ExUnit.Case, async: true

  alias Garnish.Renderer.Canvas
  alias Garnish.Renderer.Element.Sparkline

  import Garnish.View

  describe "render/3" do
    test "returns the sparkline" do
      canvas =
        Sparkline.render(
          Canvas.from_dimensions(6, 1),
          sparkline(series: [1, 40, 18, 5, 7, 50]),
          nil
        )

      assert Canvas.render_to_strings(canvas) === ["▁▇▃▂▂█"]
    end
  end
end
