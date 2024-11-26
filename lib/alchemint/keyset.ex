defmodule Alchemint.Keyset do
  use Ecto.Schema
  import Ecto.Changeset

  schema "keysets" do
    field :active, :boolean, default: false
    field :keyset_id, :string
    field :input_fee_ppk, :integer

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(keyset, attrs) do
    keyset
    |> cast(attrs, [:keyset_id, :active, :input_fee_ppk])
    |> validate_required([:keyset_id, :active, :input_fee_ppk])
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
