defmodule Alchemint.Key do
  use Ecto.Schema
  import Ecto.Changeset

  schema "keys" do
    field :private_key, :string
    field :amount, :integer
    belongs_to :keyset, Alchemint.Keyset

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(key, attrs) do
    key
    |> cast(attrs, [:amount, :private_key, :keyset_id])
    |> validate_required([:amount, :private_key, :keyset_id])
    |> assoc_constraint(:keyset)
  end
end
