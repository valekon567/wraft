defmodule WraftDoc.Military do
  @moduledoc """
  Контекст для роботи з військовими підрозділами та функціями СЕДО.
  """
  import Ecto.Query

  alias WraftDoc.Military.Subdivision
  alias WraftDoc.Repo

  @doc """
  Отримати всі підрозділи організації.
  """
  def list_subdivisions(organisation_id) do
    Subdivision
    |> where([s], s.organisation_id == ^organisation_id)
    |> order_by([s], asc: s.code)
    |> Repo.all()
  end

  @doc """
  Отримати підрозділ за ID.
  """
  def get_subdivision(id), do: Repo.get(Subdivision, id)

  @doc """
  Отримати підрозділ за ID з попередньо завантаженими зв'язками.
  """
  def get_subdivision_with_preloads(id) do
    Subdivision
    |> where([s], s.id == ^id)
    |> preload([:parent, :children, :organisation])
    |> Repo.one()
  end

  @doc """
  Створити новий підрозділ.
  """
  def create_subdivision(attrs \\ %{}) do
    %Subdivision{}
    |> Subdivision.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Оновити підрозділ.
  """
  def update_subdivision(%Subdivision{} = subdivision, attrs) do
    subdivision
    |> Subdivision.update_changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Видалити підрозділ.
  """
  def delete_subdivision(%Subdivision{} = subdivision) do
    Repo.delete(subdivision)
  end

  @doc """
  Отримати дочірні підрозділи.
  """
  def get_children(parent_id) do
    Subdivision
    |> where([s], s.parent_id == ^parent_id)
    |> order_by([s], asc: s.code)
    |> Repo.all()
  end

  @doc """
  Отримати кореневі підрозділи (без батьківського).
  """
  def get_root_subdivisions(organisation_id) do
    Subdivision
    |> where([s], s.organisation_id == ^organisation_id and is_nil(s.parent_id))
    |> order_by([s], asc: s.code)
    |> Repo.all()
  end
end
