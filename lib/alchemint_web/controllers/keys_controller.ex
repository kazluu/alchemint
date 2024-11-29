defmodule AlchemintWeb.KeysController do
  use AlchemintWeb, :controller

  alias Alchemint.Keysets

  def active_keysets(conn, _params) do
    active_keysets = Keysets.get_active_keysets()

    json(conn, active_keysets)
  end
end
