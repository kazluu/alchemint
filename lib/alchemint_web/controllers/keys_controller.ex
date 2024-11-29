defmodule AlchemintWeb.KeysController do
  use AlchemintWeb, :controller

  alias Alchemint.Keysets
  alias Alchemint.Keyset

  def active_keysets(conn, _params) do
    active_keysets = Keysets.get_active_keysets()

    json(conn, active_keysets)
  end

  def keysets(conn, _params) do
    keysets = Keysets.list_keysets()
    json(conn, Enum.map(keysets, &keyset_to_map/1))
  end

  defp keyset_to_map(%Keyset{
         keyset_id: id,
         unit: unit,
         active: active,
         input_fee_ppk: input_fee_ppk
       }) do
    %{
      "id" => id,
      "unit" => unit,
      "active" => active,
      "input_fee_ppk" => input_fee_ppk
    }
  end

  def keyset(conn, %{"keyset_id" => keyset_id}) do
    case Keysets.get_keyset(keyset_id) do
      nil ->
        conn
        |> put_status(404)
        |> json(%{"error" => "keyset not found"})

      keyset ->
        json(conn, %{"keysets" => [keyset]})
    end
  end
end
