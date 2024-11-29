defmodule AlchemintWeb.Nut01Test do
  use AlchemintWeb.ConnCase

  alias Alchemint.Repo

  alias Bitcoinex.Secp256k1.PrivateKey
  alias Bitcoinex.Secp256k1.Point

  describe "GET /v1/keys" do
    test "returns empty active keysets", %{conn: conn} do
      assert [] =
               conn
               |> get(~p"/v1/keys")
               |> json_response(200)
    end

    test "returns one active keyset with one amount", %{conn: conn} do
      amounts = [1]
      saved_keyset = keyset_fixture(amounts)
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
      saved_keyset = keyset_fixture(amounts)
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
      saved_keyset_1 = keyset_fixture([1])
      saved_keyset_2 = keyset_fixture([2])

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
      active_keyset = keyset_fixture([1])
      active_keyset_id = active_keyset.keyset_id
      keyset_fixture([1], false)

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

  defp keyset_fixture(amounts, active \\ true) do
    amount_privkeys =
      Enum.map(amounts, fn amount ->
        privkey_hex =
          32
          |> :crypto.strong_rand_bytes()
          |> Base.encode16(case: :lower)

        {amount, privkey_hex}
      end)

    amount_hex_pubkeys =
      amount_privkeys
      |> Enum.map(fn {amount, privkey_hex} ->
        {privkey_int, ""} = Integer.parse(privkey_hex, 16)
        {:ok, privkey} = PrivateKey.new(privkey_int)
        pubkey = PrivateKey.to_point(privkey)

        {Integer.to_string(amount), Point.serialize_public_key(pubkey)}
      end)
      |> Enum.into(%{})

    keyset =
      amount_hex_pubkeys
      |> Cashu.Keyset.new("sat", active)
      |> Alchemint.Keyset.from_cashu_keyset_changeset()
      |> Repo.insert!()

    amount_privkeys
    |> Enum.each(fn {amount, privkey_hex} ->
      data = %{amount: amount, private_key: privkey_hex, keyset_id: keyset.id}

      %Alchemint.Key{}
      |> Alchemint.Key.changeset(data)
      |> Repo.insert!()
    end)

    keyset
  end
end
