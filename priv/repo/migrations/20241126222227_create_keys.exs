defmodule Alchemint.Repo.Migrations.CreateKeys do
  use Ecto.Migration

  def change do
    create table(:keys) do
      add :amount, :integer
      add :private_key, :string # hex encoded integer
      add :keyset_id, references(:keysets, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end
  end
end
