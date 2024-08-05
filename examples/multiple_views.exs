# An example of how to implement navigation between multiple views.
#
# Run this example with:
#
#   mix run --no-halt examples/multiple_views.exs

defmodule MultipleViews do
  @behaviour Garnish.App

  import Garnish.View

  def init(_context) do
    {:ok, %{selected_tab: 1}, quit_keys: [?q]}
  end

  def handle_key(key_event, model) do
    case key_event do
      %{key: ?1} -> {:ok, %{model | selected_tab: 1}}
      %{key: ?2} -> {:ok, %{model | selected_tab: 2}}
      %{key: ?3} -> {:ok, %{model | selected_tab: 3}}
      _ ->
        {:ok, model, render: false}
    end
  end

  def render(model) do
    view top_bar: title_bar(), bottom_bar: status_bar(model.selected_tab) do
      case model.selected_tab do
        1 -> panel(title: "View 1", height: :fill)
        2 -> panel(title: "View 2", height: :fill)
        3 -> panel(title: "View 3", height: :fill)
      end
    end
  end

  def title_bar do
    bar do
      label(content: "Multiple Views Demo (Press 1, 2 or 3, or q to quit)")
    end
  end

  def status_bar(selected) do
    bar do
      label do
        for item <- 1..3 do
          if item == selected do
            text(
              background: :white,
              color: :black,
              content: " View #{item} "
            )
          else
            text(content: " View #{item} ")
          end
        end
      end
    end
  end
end

opts = [
  system_dir: Path.join(__DIR__, ".keys") |> to_charlist,
  ssh_cli: {Garnish, app: {MultipleViews, []}},
  no_auth_needed: true,
]
:ssh.daemon({127, 0, 0, 1}, 2222, opts)
