defmodule AlchemintWeb.Nut01Test do
  use AlchemintWeb.ConnCase

  alias Alchemint.Fixtures

  describe "GET /v1/keys" do
    test "returns empty active keysets", %{conn: conn} do
      assert [] =
               conn
               |> get(~p"/v1/keys")
               |> json_response(200)
    end

    test "returns one active keyset with one amount", %{conn: conn} do
      amounts = [1]
      saved_keyset = Fixtures.keyset_fixture(amounts)
      saved_keyset_id = saved_keyset.keyset_id

      assert [keyset] =
               conn
               |> get(~p"/v1/keys")
               |> json_response(200)

      assert %{
               "id" => ^saved_keyset_id,
               "unit" => "sat",
               "keys" => keys
             } = keyset

      assert %{"1" => _pubkey} = keys
    end

    test "returns one active keyset with two amounts", %{conn: conn} do
      amounts = [1, 2]
      saved_keyset = Fixtures.keyset_fixture(amounts)
      saved_keyset_id = saved_keyset.keyset_id

      assert [keyset] =
               conn
               |> get(~p"/v1/keys")
               |> json_response(200)

      assert %{
               "id" => ^saved_keyset_id,
               "unit" => "sat",
               "keys" => keys
             } = keyset

      assert %{"1" => _, "2" => _} = keys
    end

    test "returns two active keysets one amount each", %{conn: conn} do
      saved_keyset_1 = Fixtures.keyset_fixture([1])
      saved_keyset_2 = Fixtures.keyset_fixture([2])

      saved_keyset_id_1 = saved_keyset_1.keyset_id
      saved_keyset_id_2 = saved_keyset_2.keyset_id

      assert active_keysets =
               conn
               |> get(~p"/v1/keys")
               |> json_response(200)

      assert MapSet.equal?(
               active_keysets |> Enum.map(fn %{"id" => id} -> id end) |> MapSet.new(),
               [saved_keyset_id_1, saved_keyset_id_2] |> MapSet.new()
             )
    end

    test "returns the only active keyset", %{conn: conn} do
      active_keyset = Fixtures.keyset_fixture([1])
      active_keyset_id = active_keyset.keyset_id
      Fixtures.keyset_fixture([1], false)

      assert [keyset] =
               conn
               |> get(~p"/v1/keys")
               |> json_response(200)

      assert %{
               "id" => ^active_keyset_id,
               "unit" => "sat",
               "keys" => _keys
             } = keyset
    end
  end
end
