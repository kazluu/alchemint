defmodule Alchemint.Keyset do
  use Ecto.Schema
  import Ecto.Changeset

  schema "keysets" do
    field :active, :boolean, default: false
    field :keyset_id, :string
    field :input_fee_ppk, :integer
    field :unit, :string

    has_many :keys, Alchemint.Key

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(keyset, attrs) do
    keyset
    |> cast(attrs, [:keyset_id, :active, :input_fee_ppk, :unit])
    |> validate_required([:keyset_id, :active, :input_fee_ppk, :unit])
  end

  def from_cashu_keyset_changeset(%Cashu.Keyset{id: keyset_id, active: active, unit: unit}) do
    changeset(%__MODULE__{}, %{
      keyset_id: keyset_id,
      active: active,
      input_fee_ppk: 0,
      unit: unit
    })
  end
end

defimpl Jason.Encoder, for: Alchemint.Keyset do
  alias Alchemint.Keysets

  def encode(value, opts) do
    Jason.Encode.map(
      %{
        "id" => value.keyset_id,
        "unit" => value.unit,
        "input_fee_ppk" => value.input_fee_ppk,
        "keys" => encode_keys(value.keys)
      },
      opts
    )
  end

  defp encode_keys(keys) do
    keys
    |> Enum.map(fn %Alchemint.Key{amount: amount, private_key: privkey_hex} ->
      {
        Integer.to_string(amount),
        Keysets.privkey_to_pubkey(privkey_hex)
      }
    end)
    |> Enum.into(%{})
  end
end
