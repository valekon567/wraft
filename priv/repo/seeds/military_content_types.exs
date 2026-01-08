defmodule WraftDoc.Seeds.MilitaryContentTypes do
  @moduledoc """
  Seed для створення типів військових документів.
  """

  alias WraftDoc.ContentTypes.ContentType
  alias WraftDoc.ContentTypes.ContentTypeField
  alias WraftDoc.Fields.Field
  alias WraftDoc.Fields.FieldType
  alias WraftDoc.Repo

  @doc """
  Створює всі типи військових документів.
  """
  def seed(organisation_id, creator_id, flow_id, layout_id, theme_id) do
    # Отримуємо типи полів
    string_type = Repo.get_by(FieldType, name: "String")
    text_type = Repo.get_by(FieldType, name: "Text")
    date_type = Repo.get_by(FieldType, name: "Date")

    content_types = [
      %{
        name: "Наказ по частині",
        description: "Наказ командира військової частини",
        prefix: "НАК",
        color: "#FF6B6B",
        organisation_id: organisation_id,
        creator_id: creator_id,
        flow_id: flow_id,
        layout_id: layout_id,
        theme_id: theme_id,
        fields: [
          %{name: "Номер наказу", field_type_id: string_type.id, required: true},
          %{name: "Дата наказу", field_type_id: date_type.id, required: true},
          %{name: "Назва наказу", field_type_id: string_type.id, required: true},
          %{name: "Зміст наказу", field_type_id: text_type.id, required: true},
          %{name: "Виконавець", field_type_id: string_type.id, required: true},
          %{name: "Підстава", field_type_id: text_type.id, required: false},
          %{name: "Номер частини", field_type_id: string_type.id, required: true},
          %{name: "Місто", field_type_id: string_type.id, required: true},
          %{name: "Звання командира", field_type_id: string_type.id, required: true},
          %{name: "ПІБ командира", field_type_id: string_type.id, required: true},
          %{name: "Звання начальника штабу", field_type_id: string_type.id, required: true},
          %{name: "ПІБ начальника штабу", field_type_id: string_type.id, required: true}
        ]
      },
      %{
        name: "Службова записка",
        description: "Службова записка між підрозділами",
        prefix: "СЗ",
        color: "#4ECDC4",
        organisation_id: organisation_id,
        creator_id: creator_id,
        flow_id: flow_id,
        layout_id: layout_id,
        theme_id: theme_id,
        fields: [
          %{name: "Від кого (посада)", field_type_id: string_type.id, required: true},
          %{name: "Кому (посада)", field_type_id: string_type.id, required: true},
          %{name: "Дата", field_type_id: date_type.id, required: true},
          %{name: "Тема", field_type_id: string_type.id, required: true},
          %{name: "Зміст", field_type_id: text_type.id, required: true},
          %{name: "Звання відправника", field_type_id: string_type.id, required: true},
          %{name: "ПІБ відправника", field_type_id: string_type.id, required: true}
        ]
      },
      %{
        name: "Рапорт",
        description: "Рапорт військовослужбовця",
        prefix: "РАП",
        color: "#95E1D3",
        organisation_id: organisation_id,
        creator_id: creator_id,
        flow_id: flow_id,
        layout_id: layout_id,
        theme_id: theme_id,
        fields: [
          %{name: "ПІБ військовослужбовця", field_type_id: string_type.id, required: true},
          %{name: "Звання", field_type_id: string_type.id, required: true},
          %{name: "Підрозділ", field_type_id: string_type.id, required: true},
          %{name: "Тема рапорту", field_type_id: string_type.id, required: true},
          %{name: "Зміст рапорту", field_type_id: text_type.id, required: true},
          %{name: "Дата", field_type_id: date_type.id, required: true}
        ]
      },
      %{
        name: "Звіт",
        description: "Звіт підрозділу або виконавця",
        prefix: "ЗВТ",
        color: "#F38181",
        organisation_id: organisation_id,
        creator_id: creator_id,
        flow_id: flow_id,
        layout_id: layout_id,
        theme_id: theme_id,
        fields: [
          %{name: "Тип звіту", field_type_id: string_type.id, required: true},
          %{name: "Період (з)", field_type_id: date_type.id, required: true},
          %{name: "Період (по)", field_type_id: date_type.id, required: true},
          %{name: "Підрозділ", field_type_id: string_type.id, required: true},
          %{name: "Дані звіту", field_type_id: text_type.id, required: true},
          %{name: "Виконавець", field_type_id: string_type.id, required: true}
        ]
      },
      %{
        name: "Вихідний лист",
        description: "Вихідна кореспонденція",
        prefix: "ВИХ",
        color: "#AA96DA",
        organisation_id: organisation_id,
        creator_id: creator_id,
        flow_id: flow_id,
        layout_id: layout_id,
        theme_id: theme_id,
        fields: [
          %{name: "Адресат", field_type_id: string_type.id, required: true},
          %{name: "Тема", field_type_id: string_type.id, required: true},
          %{name: "Зміст листа", field_type_id: text_type.id, required: true},
          %{name: "Додатки", field_type_id: string_type.id, required: false},
          %{name: "Дата", field_type_id: date_type.id, required: true},
          %{name: "Виконавець", field_type_id: string_type.id, required: true}
        ]
      },
      %{
        name: "Вхідний лист",
        description: "Вхідна кореспонденція",
        prefix: "ВХ",
        color: "#FCBAD3",
        organisation_id: organisation_id,
        creator_id: creator_id,
        flow_id: flow_id,
        layout_id: layout_id,
        theme_id: theme_id,
        fields: [
          %{name: "Відправник", field_type_id: string_type.id, required: true},
          %{name: "Вхідний номер", field_type_id: string_type.id, required: true},
          %{name: "Дата отримання", field_type_id: date_type.id, required: true},
          %{name: "Тема", field_type_id: string_type.id, required: true},
          %{name: "Зміст листа", field_type_id: text_type.id, required: true},
          %{name: "Резолюція", field_type_id: text_type.id, required: false},
          %{name: "Відповідальний", field_type_id: string_type.id, required: false}
        ]
      }
    ]

    Enum.map(content_types, fn ct_attrs ->
      fields_data = ct_attrs.fields
      ct_attrs = Map.delete(ct_attrs, :fields)

      # Створюємо або отримуємо content type
      content_type =
        case Repo.get_by(ContentType, name: ct_attrs.name, organisation_id: organisation_id) do
          nil ->
            %ContentType{}
            |> ContentType.changeset(ct_attrs)
            |> Repo.insert!()

          existing ->
            existing
        end

      # Створюємо поля для content type
      Enum.with_index(fields_data, 1)
      |> Enum.each(fn {field_data, index} ->
        # Створюємо або отримуємо поле
        field =
          case Repo.get_by(Field,
                 name: field_data.name,
                 organisation_id: organisation_id
               ) do
            nil ->
              %Field{}
              |> Field.changeset(%{
                name: field_data.name,
                field_type_id: field_data.field_type_id,
                organisation_id: organisation_id,
                meta: %{}
              })
              |> Repo.insert!()

            existing ->
              existing
          end

        # Зв'язуємо поле з content type
        case Repo.get_by(ContentTypeField,
               content_type_id: content_type.id,
               field_id: field.id
             ) do
          nil ->
            %ContentTypeField{}
            |> ContentTypeField.changeset(%{
              content_type_id: content_type.id,
              field_id: field.id,
              order: index
            })
            |> Repo.insert!()

          existing ->
            existing
        end
      end)

      content_type
    end)
  end
end
