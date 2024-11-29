defmodule Alchemint.Keysets do
  alias Alchemint.Repo
  alias Alchemint.Keyset

  alias Bitcoinex.Secp256k1.PrivateKey
  alias Bitcoinex.Secp256k1.Point

  import Ecto.Query

  def get_active_keysets do
    Repo.all(from(ks in Keyset, where: ks.active == true, preload: [:keys]))
  end

  def privkey_to_pubkey(hex_privkey) when is_binary(hex_privkey) do
    {privkey_int, ""} = Integer.parse(hex_privkey, 16)
    {:ok, privkey} = PrivateKey.new(privkey_int)

    privkey
    |> PrivateKey.to_point()
    |> Point.serialize_public_key()
  end
end
