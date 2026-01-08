defmodule WraftDocWeb.SubdivisionView do
  @moduledoc """
  View для відображення даних підрозділів у JSON форматі.
  """
  use WraftDocWeb, :view

  alias WraftDoc.Military.Subdivision

  @doc """
  Рендер списку підрозділів.
  """
  def render("index.json", %{subdivisions: subdivisions}) do
    %{
      subdivisions: Enum.map(subdivisions, &subdivision_json/1)
    }
  end

  @doc """
  Рендер одного підрозділу з деталями.
  """
  def render("show.json", %{subdivision: subdivision}) do
    %{
      subdivision: subdivision_detail_json(subdivision)
    }
  end

  @doc """
  Базове представлення підрозділу.
  """
  defp subdivision_json(%Subdivision{} = subdivision) do
    %{
      id: subdivision.id,
      name: subdivision.name,
      code: subdivision.code,
      parent_id: subdivision.parent_id,
      organisation_id: subdivision.organisation_id,
      meta: subdivision.meta || %{},
      inserted_at: subdivision.inserted_at,
      updated_at: subdivision.updated_at
    }
  end

  @doc """
  Детальне представлення підрозділу з relationships.
  """
  defp subdivision_detail_json(%Subdivision{} = subdivision) do
    base = subdivision_json(subdivision)

    base
    |> maybe_add_parent(subdivision)
    |> maybe_add_children(subdivision)
    |> maybe_add_organisation(subdivision)
  end

  defp maybe_add_parent(json, %{parent: %Ecto.Association.NotLoaded{}}), do: json

  defp maybe_add_parent(json, %{parent: nil}), do: json

  defp maybe_add_parent(json, %{parent: parent}) do
    Map.put(json, :parent, subdivision_json(parent))
  end

  defp maybe_add_children(json, %{children: %Ecto.Association.NotLoaded{}}), do: json

  defp maybe_add_children(json, %{children: children}) when is_list(children) do
    Map.put(json, :children, Enum.map(children, &subdivision_json/1))
  end

  defp maybe_add_children(json, _), do: json

  defp maybe_add_organisation(json, %{organisation: %Ecto.Association.NotLoaded{}}), do: json

  defp maybe_add_organisation(json, %{organisation: nil}), do: json

  defp maybe_add_organisation(json, %{organisation: organisation}) do
    Map.put(json, :organisation, %{
      id: organisation.id,
      name: organisation.name
    })
  end
end
