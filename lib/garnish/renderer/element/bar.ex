defmodule Garnish.Renderer.Element.Bar do
  @moduledoc false
  @behaviour Garnish.Renderer

  alias Garnish.Renderer.{Canvas, Element}

  @impl true
  def render(
        %Canvas{} = canvas,
        %Element{children: children},
        render_fn
      ) do
    render_fn.(canvas, children)
  end
end
