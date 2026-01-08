defmodule WraftDoc.Military.DocumentNumberGenerator do
  @moduledoc """
  Генератор номерів військових документів.
  Формати:
  - НАК-XXX/YYYY (Наказ)
  - СЗ-XXX/YYYY (Службова записка)
  - РАП-XXX/YYYY (Рапорт)
  - ЗВТ-XXX/YYYY (Звіт)
  - ВИХ-XXX/YYYY (Вихідний лист)
  - ВХ-XXX/YYYY (Вхідний лист)
  """

  import Ecto.Query
  alias WraftDoc.Documents.Counter
  alias WraftDoc.Repo

  @doc """
  Генерує наступний номер документа для заданого типу та року.

  ## Приклади

      iex> generate_number("НАК", 2025)
      "НАК-001/2025"

      iex> generate_number("СЗ", 2025)
      "СЗ-001/2025"
  """
  @spec generate_number(String.t(), integer()) :: String.t()
  def generate_number(prefix, year \\ nil) do
    year = year || Date.utc_today().year
    counter_name = "#{prefix}_#{year}"

    # Отримуємо або створюємо лічильник для цього типу документа та року
    counter =
      case Repo.get_by(Counter, name: counter_name) do
        nil ->
          %Counter{}
          |> Counter.changeset(%{name: counter_name, count: 1})
          |> Repo.insert!()

        existing_counter ->
          existing_counter
          |> Counter.changeset(%{count: existing_counter.count + 1})
          |> Repo.update!()
      end

    # Форматуємо номер: PREFIX-NNN/YYYY
    number = String.pad_leading("#{counter.count}", 3, "0")
    "#{prefix}-#{number}/#{year}"
  end

  @doc """
  Отримує поточний номер документа без інкременту.
  """
  @spec current_number(String.t(), integer()) :: String.t() | nil
  def current_number(prefix, year \\ nil) do
    year = year || Date.utc_today().year
    counter_name = "#{prefix}_#{year}"

    case Repo.get_by(Counter, name: counter_name) do
      nil ->
        nil

      counter ->
        number = String.pad_leading("#{counter.count}", 3, "0")
        "#{prefix}-#{number}/#{year}"
    end
  end

  @doc """
  Скидає лічильник для нового року.
  """
  @spec reset_year_counters(integer()) :: :ok
  def reset_year_counters(year) do
    prefixes = ["НАК", "СЗ", "РАП", "ЗВТ", "ВИХ", "ВХ"]

    Enum.each(prefixes, fn prefix ->
      counter_name = "#{prefix}_#{year}"

      # Видаляємо старий лічильник, якщо існує
      case Repo.get_by(Counter, name: counter_name) do
        nil -> :ok
        counter -> Repo.delete(counter)
      end
    end)

    :ok
  end

  @doc """
  Парсить номер документа та повертає його компоненти.

  ## Приклади

      iex> parse_number("НАК-015/2025")
      {:ok, %{prefix: "НАК", number: 15, year: 2025}}

      iex> parse_number("invalid")
      {:error, :invalid_format}
  """
  @spec parse_number(String.t()) :: {:ok, map()} | {:error, atom()}
  def parse_number(document_number) do
    case Regex.run(~r/^([А-ЯІЇЄ]+)-(\d+)\/(\d{4})$/, document_number) do
      [_, prefix, number, year] ->
        {:ok,
         %{
           prefix: prefix,
           number: String.to_integer(number),
           year: String.to_integer(year)
         }}

      _ ->
        {:error, :invalid_format}
    end
  end
end
