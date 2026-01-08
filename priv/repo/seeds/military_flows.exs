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
        state: "Проект",
        order: 1
      },
      %{
        state: "Погодження S1",
        order: 2
      },
      %{
        state: "Погодження S3",
        order: 3
      },
      %{
        state: "Затвердження начальником штабу",
        order: 4
      },
      %{
        state: "Підпис командира",
        order: 5
      },
      %{
        state: "Затверджено",
        order: 6
      }
    ]

    Enum.map(states, fn state_attrs ->
      case Repo.get_by(State, state: state_attrs.state, flow_id: flow.id) do
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
        state: "Створено",
        order: 1
      },
      %{
        state: "На розгляді",
        order: 2
      },
      %{
        state: "Виконано",
        order: 3
      }
    ]

    Enum.map(states, fn state_attrs ->
      case Repo.get_by(State, state: state_attrs.state, flow_id: flow.id) do
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
