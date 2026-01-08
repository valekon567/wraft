defmodule WraftDoc.Seeds.MilitaryFlows do
  @moduledoc """
  Seed для створення workflow процесів погодження військових документів.
  """

  alias WraftDoc.Enterprise.Flow
  alias WraftDoc.Enterprise.Flow.State
  alias WraftDoc.Repo

  @doc """
  Створює процес погодження наказу.
  """
  def seed(organisation_id, creator_id) do
    # Створюємо workflow "Погодження наказу"
    flow =
      case Repo.get_by(Flow, name: "Погодження наказу", organisation_id: organisation_id) do
        nil ->
          %Flow{}
          |> Flow.changeset(%{
            name: "Погодження наказу",
            organisation_id: organisation_id,
            creator_id: creator_id
          })
          |> Repo.insert!()

        existing ->
          existing
      end

    # Створюємо стани процесу
    states = [
      %{
        name: "Проект",
        state: "draft",
        order: 1,
        colour: "#9E9E9E"
      },
      %{
        name: "Погодження S1",
        state: "review",
        order: 2,
        colour: "#4ECDC4"
      },
      %{
        name: "Погодження S3",
        state: "review",
        order: 3,
        colour: "#4ECDC4"
      },
      %{
        name: "Затвердження начальником штабу",
        state: "approval",
        order: 4,
        colour: "#FFD93D"
      },
      %{
        name: "Підпис командира",
        state: "approval",
        order: 5,
        colour: "#FF6B6B"
      },
      %{
        name: "Затверджено",
        state: "approved",
        order: 6,
        colour: "#6BCF7F"
      }
    ]

    Enum.map(states, fn state_attrs ->
      case Repo.get_by(State, name: state_attrs.name, flow_id: flow.id) do
        nil ->
          %State{}
          |> State.changeset(
            Map.merge(state_attrs, %{
              flow_id: flow.id,
              organisation_id: organisation_id,
              creator_id: creator_id
            })
          )
          |> Repo.insert!()

        existing ->
          existing
      end
    end)

    flow
  end

  @doc """
  Створює базовий workflow для службових записок та рапортів.
  """
  def seed_simple_flow(organisation_id, creator_id, flow_name \\ "Базовий процес") do
    flow =
      case Repo.get_by(Flow, name: flow_name, organisation_id: organisation_id) do
        nil ->
          %Flow{}
          |> Flow.changeset(%{
            name: flow_name,
            organisation_id: organisation_id,
            creator_id: creator_id
          })
          |> Repo.insert!()

        existing ->
          existing
      end

    states = [
      %{
        name: "Створено",
        state: "draft",
        order: 1,
        colour: "#9E9E9E"
      },
      %{
        name: "На розгляді",
        state: "review",
        order: 2,
        colour: "#4ECDC4"
      },
      %{
        name: "Виконано",
        state: "approved",
        order: 3,
        colour: "#6BCF7F"
      }
    ]

    Enum.map(states, fn state_attrs ->
      case Repo.get_by(State, name: state_attrs.name, flow_id: flow.id) do
        nil ->
          %State{}
          |> State.changeset(
            Map.merge(state_attrs, %{
              flow_id: flow.id,
              organisation_id: organisation_id,
              creator_id: creator_id
            })
          )
          |> Repo.insert!()

        existing ->
          existing
      end
    end)

    flow
  end
end
