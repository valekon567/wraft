defmodule WraftDoc.Seeds.MilitarySetup do
  @moduledoc """
  Головний seed файл для налаштування військової СЕДО.
  
  Використання:
    mix run priv/repo/seeds/military_setup.exs
  
  Або з параметрами:
    MILITARY_UNIT_NAME="Військова частина А-1234" mix run priv/repo/seeds/military_setup.exs
  """

  alias WraftDoc.Account.User
  alias WraftDoc.Account.UserOrganisation
  alias WraftDoc.Account.UserRole
  alias WraftDoc.Documents.Engine
  alias WraftDoc.Enterprise
  alias WraftDoc.Enterprise.Organisation
  alias WraftDoc.Layouts.Layout
  alias WraftDoc.Military
  alias WraftDoc.Military.Subdivision
  alias WraftDoc.Repo
  alias WraftDoc.Themes.Theme

  require Logger

  @doc """
  Головна функція для налаштування військової системи.
  """
  @spec run() :: :ok
  def run do
    Logger.info("🎖️  Початок налаштування військової СЕДО...")

    # 1. Створюємо організацію
    unit_name = System.get_env("MILITARY_UNIT_NAME") || "Військова частина А-1234"
    {organisation, admin_user} = create_organisation(unit_name)

    Logger.info("✅ Створено організацію: #{organisation.name}")

    # 2. Створюємо підрозділи
    subdivisions = create_subdivisions(organisation.id)
    Logger.info("✅ Створено #{length(subdivisions)} підрозділів")

    # 3. Створюємо ролі
    roles = WraftDoc.Seeds.MilitaryRoles.seed(organisation.id)
    Logger.info("✅ Створено #{length(roles)} військових ролей")

    # 4. Створюємо workflow
    order_flow = WraftDoc.Seeds.MilitaryFlows.seed(organisation.id, admin_user.id)
    simple_flow = WraftDoc.Seeds.MilitaryFlows.seed_simple_flow(organisation.id, admin_user.id)
    Logger.info("✅ Створено workflow процеси")

    # 4.1 Створюємо або отримуємо layout та theme
    {layout, theme} = ensure_layout_and_theme(organisation.id, admin_user.id)

    # 5. Створюємо типи документів
    content_types =
      WraftDoc.Seeds.MilitaryContentTypes.seed(
        organisation.id,
        admin_user.id,
        order_flow.id,
        layout.id,
        theme.id
      )

    Logger.info("✅ Створено #{length(content_types)} типів документів")

    # 6. Створюємо демо-користувачів
    demo_users = create_demo_users(organisation, roles, subdivisions)
    Logger.info("✅ Створено #{length(demo_users)} демо-користувачів")

    Logger.info("🎖️  Налаштування завершено успішно!")
    Logger.info("")
    Logger.info("📋 Інформація для входу:")
    Logger.info("Email: commander@military.local")
    Logger.info("Пароль: Military2025!")
    Logger.info("")
    Logger.info("Інші тестові користувачі:")
    Logger.info("- chief@military.local (Начальник штабу)")
    Logger.info("- s1@military.local (Начальник S1)")
    Logger.info("- s2@military.local (Начальник S2)")
    Logger.info("- s3@military.local (Начальник S3)")
    Logger.info("- s4@military.local (Начальник S4)")
    Logger.info("- s6@military.local (Начальник S6)")
    Logger.info("- company@military.local (Командир роти)")
    Logger.info("- soldier@military.local (Військовослужбовець)")
    Logger.info("Пароль для всіх: Military2025!")

    :ok
  end

  defp create_organisation(name) do
    # Створюємо адміністратора
    admin_user =
      case Repo.get_by(User, email: "commander@military.local") do
        nil ->
          %User{}
          |> User.guest_user_changeset(%{
            name: "Командир частини",
            email: "commander@military.local",
            password: "Military2025!",
            is_guest: false,
            email_verify: true
          })
          |> Repo.insert!()

        existing ->
          existing
      end

    # Створюємо організацію
    organisation =
      case Repo.get_by(Organisation, name: name) do
        nil ->
          %Organisation{}
          |> Organisation.changeset(%{
            name: name,
            email: "command@military.local",
            creator_id: admin_user.id,
            owner_id: admin_user.id
          })
          |> Repo.insert!()

        existing ->
          existing
      end

    # Прив'язуємо користувача до організації
    case Repo.get_by(UserOrganisation,
           user_id: admin_user.id,
           organisation_id: organisation.id
         ) do
      nil ->
        %UserOrganisation{}
        |> UserOrganisation.changeset(%{
          user_id: admin_user.id,
          organisation_id: organisation.id
        })
        |> Repo.insert!()

      existing ->
        existing
    end

    # Оновлюємо last_signed_in_org
    admin_user
    |> Ecto.Changeset.change(%{last_signed_in_org: organisation.id})
    |> Repo.update!()

    # Створюємо безкоштовну підписку
    Enterprise.create_free_subscription(organisation.id)

    {organisation, admin_user}
  end

  defp create_subdivisions(organisation_id) do
    # Створюємо головний штаб
    {:ok, shtab} =
      Military.create_subdivision(%{
        name: "Штаб",
        code: "SHTAB",
        organisation_id: organisation_id,
        meta: %{description: "Головний штаб військової частини"}
      })

    # Створюємо відділи штабу
    s_divisions = [
      %{name: "Відділ кадрів (S1)", code: "S1", description: "Персонал та адміністрування"},
      %{name: "Відділ розвідки (S2)", code: "S2", description: "Розвідка та безпека"},
      %{name: "Відділ операцій (S3)", code: "S3", description: "Планування та операції"},
      %{
        name: "Відділ матзабезпечення (S4)",
        code: "S4",
        description: "Логістика та постачання"
      },
      %{name: "Відділ зв'язку (S6)", code: "S6", description: "Зв'язок та IT"}
    ]

    s_subdivisions =
      Enum.map(s_divisions, fn div ->
        {:ok, subdivision} =
          Military.create_subdivision(%{
            name: div.name,
            code: div.code,
            parent_id: shtab.id,
            organisation_id: organisation_id,
            meta: %{description: div.description}
          })

        subdivision
      end)

    # Створюємо роти
    companies =
      for i <- 1..3 do
        {:ok, company} =
          Military.create_subdivision(%{
            name: "#{i}-а рота",
            code: "ROTA_#{i}",
            organisation_id: organisation_id,
            meta: %{description: "#{i}-а стрілецька рота"}
          })

        company
      end

    [shtab | s_subdivisions] ++ companies
  end

  defp create_demo_users(organisation, roles, subdivisions) do
    users_data = [
      %{
        name: "Начальник штабу",
        email: "chief@military.local",
        role: "Начальник штабу",
        subdivision: Enum.find(subdivisions, &(&1.code == "SHTAB"))
      },
      %{
        name: "Начальник S1",
        email: "s1@military.local",
        role: "Начальник відділу S1",
        subdivision: Enum.find(subdivisions, &(&1.code == "S1"))
      },
      %{
        name: "Начальник S2",
        email: "s2@military.local",
        role: "Начальник відділу S2",
        subdivision: Enum.find(subdivisions, &(&1.code == "S2"))
      },
      %{
        name: "Начальник S3",
        email: "s3@military.local",
        role: "Начальник відділу S3",
        subdivision: Enum.find(subdivisions, &(&1.code == "S3"))
      },
      %{
        name: "Начальник S4",
        email: "s4@military.local",
        role: "Начальник відділу S4",
        subdivision: Enum.find(subdivisions, &(&1.code == "S4"))
      },
      %{
        name: "Начальник S6",
        email: "s6@military.local",
        role: "Начальник відділу S6",
        subdivision: Enum.find(subdivisions, &(&1.code == "S6"))
      },
      %{
        name: "Командир роти",
        email: "company@military.local",
        role: "Командир роти",
        subdivision: Enum.find(subdivisions, &(&1.code == "ROTA_1"))
      },
      %{
        name: "Військовослужбовець",
        email: "soldier@military.local",
        role: "Військовослужбовець",
        subdivision: Enum.find(subdivisions, &(&1.code == "ROTA_1"))
      }
    ]

    Enum.map(users_data, fn user_data ->
      user =
        case Repo.get_by(User, email: user_data.email) do
          nil ->
            %User{}
            |> User.guest_user_changeset(%{
              name: user_data.name,
              email: user_data.email,
              password: "Military2025!",
              is_guest: false,
              email_verify: true
            })
            |> Repo.insert!()

          existing ->
            existing
        end

      # Прив'язуємо до організації
      case Repo.get_by(UserOrganisation,
             user_id: user.id,
             organisation_id: organisation.id
           ) do
        nil ->
          %UserOrganisation{}
          |> UserOrganisation.changeset(%{
            user_id: user.id,
            organisation_id: organisation.id
          })
          |> Repo.insert!()

        _ ->
          :ok
      end

      # Призначаємо роль
      role = Enum.find(roles, &(&1.name == user_data.role))

      if role do
        case Repo.get_by(UserRole, user_id: user.id, role_id: role.id) do
          nil ->
            %UserRole{}
            |> UserRole.changeset(%{
              user_id: user.id,
              role_id: role.id
            })
            |> Repo.insert!()

          _ ->
            :ok
        end
      end

      user
    end)
  end

  defp ensure_layout_and_theme(organisation_id, creator_id) do
    # Отримуємо або створюємо двигун
    engine =
      case Repo.get_by(Engine, name: "pandoc") do
        nil ->
          %Engine{}
          |> Engine.changeset(%{
            name: "pandoc",
            api_route: "pandoc"
          })
          |> Repo.insert!()

        existing ->
          existing
      end

    # Створюємо або отримуємо layout
    layout =
      case Repo.get_by(Layout, name: "Військовий бланк", organisation_id: organisation_id) do
        nil ->
          %Layout{}
          |> Layout.changeset(%{
            name: "Військовий бланк",
            description: "Базовий бланк для військових документів",
            slug: "military-letterhead",
            engine_id: engine.id,
            organisation_id: organisation_id,
            creator_id: creator_id,
            width: 210.0,
            height: 297.0,
            unit: "mm"
          })
          |> Repo.insert!()

        existing ->
          existing
      end

    # Створюємо або отримуємо theme
    theme =
      case Repo.get_by(Theme, name: "Військова тема", organisation_id: organisation_id) do
        nil ->
          %Theme{}
          |> Theme.changeset(%{
            name: "Військова тема",
            font: "Roboto",
            typescale: %{h1: 18, h2: 14, h3: 12, p: 10},
            body_color: "#000000",
            primary_color: "#2C5F2D",
            secondary_color: "#97BC62",
            organisation_id: organisation_id,
            creator_id: creator_id
          })
          |> Repo.insert!()

        existing ->
          existing
      end

    {layout, theme}
  end
end

# Запускаємо seed
WraftDoc.Seeds.MilitarySetup.run()
