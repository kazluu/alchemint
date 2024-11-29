defmodule AlchemintWeb.Nut02Test do
  use AlchemintWeb.ConnCase

  alias Alchemint.Fixtures

  describe "GET /v1/keysets" do
    test "empty when there are no keysets", %{conn: conn} do
      assert [] =
               conn
               |> get(~p"/v1/keysets")
               |> json_response(200)
    end

    test "returns one keyset", %{conn: conn} do
      keyset = Fixtures.keyset_fixture([1, 2, 4, 8, 16])
      keyset_id = keyset.keyset_id

      assert [keyset] =
               conn
               |> get(~p"/v1/keysets")
               |> json_response(200)

      assert %{
               "id" => ^keyset_id,
               "unit" => "sat",
               "active" => true,
               "input_fee_ppk" => 0
             } = keyset
    end

    test "returns one active one non active keyset", %{conn: conn} do
      Fixtures.keyset_fixture([1, 2, 4, 8, 16])
      Fixtures.keyset_fixture([1, 2, 4, 8, 16], false)

      assert [keyset1, keyset2] =
               conn
               |> get(~p"/v1/keysets")
               |> json_response(200)

      assert keyset1["unit"] == "sat"
      assert keyset2["unit"] == "sat"
    end

    test "returns 100 keysets", %{conn: conn} do
      Enum.each(1..100, fn _ ->
        Fixtures.keyset_fixture([1])
      end)

      assert all_keysets =
               conn
               |> get(~p"/v1/keysets")
               |> json_response(200)

      assert length(all_keysets) == 100
    end
  end

  describe "GET /v1/keys/{keyset_id}" do
    test "return a non-existent keyset", %{conn: conn} do
      assert %{"error" => "keyset not found"} =
               conn
               |> get(~p"/v1/keys/non-existent")
               |> json_response(404)
    end

    test "returns the keyset with the given keyset_id", %{conn: conn} do
      keyset = Fixtures.keyset_fixture([1])
      keyset_id = keyset.keyset_id

      assert %{"keysets" => [keyset]} =
               conn
               |> get(~p"/v1/keys/#{keyset.keyset_id}")
               |> json_response(200)

      assert %{
               "unit" => "sat",
               "input_fee_ppk" => 0,
               "id" => ^keyset_id
             } = keyset
    end
  end
end
