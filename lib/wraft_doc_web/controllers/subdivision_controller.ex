defmodule WraftDocWeb.SubdivisionController do
  @moduledoc """
  Контролер для управління підрозділами військової частини.
  """
  use WraftDocWeb, :controller

  alias WraftDoc.Military
  alias WraftDoc.Military.Subdivision

  action_fallback(WraftDocWeb.FallbackController)

  @doc """
  Отримати список всіх підрозділів організації.
  GET /api/v1/subdivisions
  """
  def index(conn, _params) do
    current_user = conn.assigns[:current_user]
    organisation_id = current_user.current_org_id

    subdivisions = Military.list_subdivisions(organisation_id)
    render(conn, "index.json", subdivisions: subdivisions)
  end

  @doc """
  Отримати конкретний підрозділ за ID.
  GET /api/v1/subdivisions/:id
  """
  def show(conn, %{"id" => id}) do
    case Military.get_subdivision_with_preloads(id) do
      nil ->
        {:error, :not_found}

      subdivision ->
        render(conn, "show.json", subdivision: subdivision)
    end
  end

  @doc """
  Створити новий підрозділ.
  POST /api/v1/subdivisions
  """
  def create(conn, %{"subdivision" => subdivision_params}) do
    current_user = conn.assigns[:current_user]
    organisation_id = current_user.current_org_id

    subdivision_params =
      subdivision_params
      |> Map.put("organisation_id", organisation_id)

    case Military.create_subdivision(subdivision_params) do
      {:ok, subdivision} ->
        subdivision = Military.get_subdivision_with_preloads(subdivision.id)

        conn
        |> put_status(:created)
        |> render("show.json", subdivision: subdivision)

      {:error, changeset} ->
        {:error, changeset}
    end
  end

  @doc """
  Оновити підрозділ.
  PUT /api/v1/subdivisions/:id
  """
  def update(conn, %{"id" => id, "subdivision" => subdivision_params}) do
    case Military.get_subdivision(id) do
      nil ->
        {:error, :not_found}

      subdivision ->
        case Military.update_subdivision(subdivision, subdivision_params) do
          {:ok, updated_subdivision} ->
            subdivision = Military.get_subdivision_with_preloads(updated_subdivision.id)
            render(conn, "show.json", subdivision: subdivision)

          {:error, changeset} ->
            {:error, changeset}
        end
    end
  end

  @doc """
  Видалити підрозділ.
  DELETE /api/v1/subdivisions/:id
  """
  def delete(conn, %{"id" => id}) do
    case Military.get_subdivision(id) do
      nil ->
        {:error, :not_found}

      subdivision ->
        case Military.delete_subdivision(subdivision) do
          {:ok, _subdivision} ->
            send_resp(conn, :no_content, "")

          {:error, changeset} ->
            {:error, changeset}
        end
    end
  end

  @doc """
  Отримати дочірні підрозділи.
  GET /api/v1/subdivisions/:id/children
  """
  def children(conn, %{"id" => id}) do
    children = Military.get_children(id)
    render(conn, "index.json", subdivisions: children)
  end

  @doc """
  Отримати кореневі підрозділи (без батьківського).
  GET /api/v1/subdivisions/roots
  """
  def roots(conn, _params) do
    current_user = conn.assigns[:current_user]
    organisation_id = current_user.current_org_id

    roots = Military.get_root_subdivisions(organisation_id)
    render(conn, "index.json", subdivisions: roots)
  end
end
