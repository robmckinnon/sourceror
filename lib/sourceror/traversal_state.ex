defmodule VendoredSourceror.TraversalState do
  @moduledoc """
  The state struct for VendoredSourceror traversal functions.
  """
  import VendoredSourceror.Utils.TypedStruct

  typedstruct do
    field :acc, term()
  end
end
