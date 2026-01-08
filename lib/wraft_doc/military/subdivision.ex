defmodule WraftDoc.Military.Subdivision do
  @moduledoc """
  Модель підрозділу військової частини.
  Підтримує ієрархічну структуру: штаб, відділи S1-S6, роти тощо.
  """
  use WraftDoc.Schema

  alias __MODULE__

  @derive {Jason.Encoder, only: [:id, :name, :code, :parent_id, :organisation_id, :meta]}
  schema "subdivisions" do
    field(:name, :string)
    field(:code, :string)
    field(:meta, :map, default: %{})

    belongs_to(:parent, Subdivision)
    belongs_to(:organisation, WraftDoc.Enterprise.Organisation)

    has_many(:children, Subdivision, foreign_key: :parent_id)

    timestamps()
  end

  @doc """
  Changeset для створення нового підрозділу.
  """
  def changeset(%Subdivision{} = subdivision, attrs \\ %{}) do
    subdivision
    |> cast(attrs, [:name, :code, :parent_id, :organisation_id, :meta])
    |> validate_required([:name, :code, :organisation_id])
    |> foreign_key_constraint(:organisation_id)
    |> foreign_key_constraint(:parent_id)
    |> unique_constraint([:code, :organisation_id],
      name: :subdivisions_code_organisation_id_index,
      message: "Код підрозділу вже використовується в цій організації"
    )
  end

  @doc """
  Changeset для оновлення підрозділу.
  """
  def update_changeset(%Subdivision{} = subdivision, attrs \\ %{}) do
    subdivision
    |> cast(attrs, [:name, :code, :parent_id, :meta])
    |> validate_required([:name, :code])
    |> foreign_key_constraint(:parent_id)
    |> unique_constraint([:code, :organisation_id],
      name: :subdivisions_code_organisation_id_index,
      message: "Код підрозділу вже використовується в цій організації"
    )
  end
end
