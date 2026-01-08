defmodule WraftDoc.Seeds.MilitaryRoles do
  @moduledoc """
  Seed для створення військових ролей у системі СЕДО.
  """

  alias WraftDoc.Account.Role
  alias WraftDoc.Repo

  @doc """
  Створює всі військові ролі для організації.
  """
  def seed(organisation_id) do
    roles = [
      %{
        name: "Командир частини",
        organisation_id: organisation_id,
        permissions: [
          "create",
          "read",
          "update",
          "delete",
          "approve",
          "sign",
          "manage_users",
          "manage_subdivisions"
        ]
      },
      %{
        name: "Начальник штабу",
        organisation_id: organisation_id,
        permissions: [
          "create",
          "read",
          "update",
          "approve",
          "sign",
          "manage_users"
        ]
      },
      %{
        name: "Начальник відділу S1",
        organisation_id: organisation_id,
        permissions: [
          "create",
          "read",
          "update",
          "approve",
          "manage_personnel_docs"
        ]
      },
      %{
        name: "Начальник відділу S2",
        organisation_id: organisation_id,
        permissions: [
          "create",
          "read",
          "update",
          "approve",
          "manage_intelligence_docs"
        ]
      },
      %{
        name: "Начальник відділу S3",
        organisation_id: organisation_id,
        permissions: [
          "create",
          "read",
          "update",
          "approve",
          "manage_operations_docs"
        ]
      },
      %{
        name: "Начальник відділу S4",
        organisation_id: organisation_id,
        permissions: [
          "create",
          "read",
          "update",
          "approve",
          "manage_logistics_docs"
        ]
      },
      %{
        name: "Начальник відділу S6",
        organisation_id: organisation_id,
        permissions: [
          "create",
          "read",
          "update",
          "approve",
          "manage_communications_docs"
        ]
      },
      %{
        name: "Командир роти",
        organisation_id: organisation_id,
        permissions: [
          "create",
          "read",
          "update"
        ]
      },
      %{
        name: "Військовослужбовець",
        organisation_id: organisation_id,
        permissions: [
          "read",
          "create_raport"
        ]
      }
    ]

    Enum.map(roles, fn role_attrs ->
      case Repo.get_by(Role, name: role_attrs.name, organisation_id: organisation_id) do
        nil ->
          %Role{}
          |> Role.changeset(role_attrs)
          |> Repo.insert!()

        existing_role ->
          existing_role
      end
    end)
  end
end
