defmodule Alchemint.Fixtures do
  alias Alchemint.Repo
  alias Bitcoinex.Secp256k1.PrivateKey
  alias Bitcoinex.Secp256k1.Point

  def keyset_fixture(amounts, active \\ true) do
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
