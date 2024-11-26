defmodule Alchemint.Repo.Migrations.CreateKeysets do
  use Ecto.Migration

  def change do
    create table(:keysets) do
      add :keyset_id, :string
      add :active, :boolean, default: false, null: false
      add :input_fee_ppk, :integer
      add :unit, :string

      timestamps(type: :utc_datetime)
    end
  end
end
