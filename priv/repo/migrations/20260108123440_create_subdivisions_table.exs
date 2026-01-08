defmodule WraftDoc.Repo.Migrations.CreateSubdivisionsTable do
  @moduledoc """
  Міграція для створення таблиці підрозділів військової частини.
  Підтримує ієрархічну структуру (штаб, відділи S1-S6, роти).
  """
  use Ecto.Migration

  def change do
    create table(:subdivisions, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :name, :string, null: false
      add :code, :string, null: false
      add :parent_id, references(:subdivisions, type: :uuid, on_delete: :nilify_all)
      add :organisation_id, references(:organisation, type: :uuid, on_delete: :delete_all),
        null: false
      add :meta, :jsonb, default: "{}"

      timestamps()
    end

    create index(:subdivisions, [:organisation_id])
    create index(:subdivisions, [:parent_id])
    create unique_index(:subdivisions, [:code, :organisation_id])
  end
end
