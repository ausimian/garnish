defmodule Garnish.Cell do
  @moduledoc """
  Represents a cell, a character at a position, along with the cell's
  background and foreground colors.
  """

  alias __MODULE__, as: Cell
  alias Garnish.{Constants, Position}

  @type t :: %__MODULE__{
          position: Position.t(),
          ch: non_neg_integer()
        }

  @enforce_keys [:position, :ch]
  defstruct position: nil,
            ch: nil,
            bg: Constants.colors().default,
            fg: Constants.colors().default

  def empty do
    %Cell{position: nil, ch: nil}
  end
end
