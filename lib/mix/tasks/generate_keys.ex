defmodule Mix.Tasks.GenerateKeys do
  use Mix.Task

  alias Alchemint.Repo
  alias Alchemint.Key
  alias Alchemint.Keysets

  def run(_) do
    {:ok, _} = Application.ensure_all_started(:alchemint)

    amounts = [1, 2, 4, 8, 16, 32, 64, 128, 256, 512, 1024]

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
        {
          Integer.to_string(amount),
          Keysets.privkey_to_pubkey(privkey_hex)
        }
      end)
      |> Enum.into(%{})

    dbg(amount_hex_pubkeys)

    keyset =
      amount_hex_pubkeys
      |> Cashu.Keyset.new("sat", true)
      |> Alchemint.Keyset.from_cashu_keyset_changeset()
      |> Repo.insert!()

    dbg(keyset)

    priv_keys =
      amount_privkeys
      |> Enum.each(fn {amount, privkey_hex} ->
        IO.puts("Saving key with amount #{amount} and privkey #{privkey_hex}")
        data = %{amount: amount, private_key: privkey_hex, keyset_id: keyset.id}

        %Key{}
        |> Key.changeset(data)
        |> Repo.insert!()
      end)

    dbg(priv_keys)
  end
end
