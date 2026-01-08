# Інструкція з тестування військової СЕДО

## Швидкий старт для тестування

### 1. Перевірка міграції

```bash
# Підніміть базу даних
docker-compose -f docker-compose.military.yml up -d db

# Зачекайте 10 секунд для ініціалізації PostgreSQL

# Запустіть міграції (через backend контейнер або локально)
mix ecto.create
mix ecto.migrate
```

Очікуваний результат: Міграція `20260108123440_create_subdivisions_table.exs` повинна виконатись успішно.

### 2. Перевірка seed файлів

```bash
# Запустіть військовий seed
mix run priv/repo/seeds/military_setup.exs
```

Очікуваний вивід:
```
🎖️  Початок налаштування військової СЕДО...
✅ Створено організацію: Військова частина А-1234
✅ Створено 9 підрозділів
✅ Створено 9 військових ролей
✅ Створено workflow процеси
✅ Створено 6 типів документів
✅ Створено 8 демо-користувачів
🎖️  Налаштування завершено успішно!

📋 Інформація для входу:
Email: commander@military.local
Пароль: Military2025!
...
```

### 3. Перевірка створених даних

```bash
# Підключіться до бази даних
psql -U vch_user -d vch_edo

# Перевірте підрозділи
SELECT * FROM subdivisions;

# Перевірте ролі
SELECT * FROM role WHERE organisation_id IN (SELECT id FROM organisation WHERE name LIKE 'Військова%');

# Перевірте типи документів
SELECT * FROM content_type WHERE organisation_id IN (SELECT id FROM organisation WHERE name LIKE 'Військова%');

# Перевірте користувачів
SELECT name, email FROM "user" WHERE email LIKE '%@military.local';
```

### 4. Тестування через API

```bash
# Отримайте токен аутентифікації
curl -X POST http://localhost:4000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "commander@military.local",
    "password": "Military2025!"
  }'

# Збережіть отриманий token у змінну
export TOKEN="your_token_here"

# Отримайте список підрозділів
curl -X GET http://localhost:4000/api/v1/subdivisions \
  -H "Authorization: Bearer $TOKEN"

# Створіть новий підрозділ
curl -X POST http://localhost:4000/api/v1/subdivisions \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "subdivision": {
      "name": "Взвод зв'\''язку",
      "code": "VZ_ZV",
      "meta": {"description": "Взвод зв'\''язку"}
    }
  }'
```

## Перевірка окремих компонентів

### Генератор номерів документів

```elixir
# У iex консолі
iex -S mix

# Перевірка генерації номерів
alias WraftDoc.Military.DocumentNumberGenerator

DocumentNumberGenerator.generate_number("НАК", 2025)
# Повинно повернути: "НАК-001/2025"

DocumentNumberGenerator.generate_number("СЗ", 2025)
# Повинно повернути: "СЗ-001/2025"

DocumentNumberGenerator.generate_number("НАК", 2025)
# Повинно повернути: "НАК-002/2025"

# Парсинг номера
DocumentNumberGenerator.parse_number("НАК-015/2025")
# Повинно повернути: {:ok, %{prefix: "НАК", number: 15, year: 2025}}
```

### Контекст Military

```elixir
# У iex консолі
alias WraftDoc.Military
alias WraftDoc.Repo

# Отримати організацію
org = Repo.get_by(WraftDoc.Enterprise.Organisation, name: "Військова частина А-1234")

# Отримати всі підрозділи
subdivisions = Military.list_subdivisions(org.id)
IO.inspect(subdivisions, label: "Підрозділи")

# Отримати кореневі підрозділи
roots = Military.get_root_subdivisions(org.id)
IO.inspect(roots, label: "Кореневі підрозділи")

# Отримати підрозділ штабу
shtab = Enum.find(subdivisions, &(&1.code == "SHTAB"))

# Отримати дочірні підрозділи штабу
children = Military.get_children(shtab.id)
IO.inspect(children, label: "Відділи штабу")
```

## Запуск повної системи

### Через Docker Compose

```bash
# Скопіюйте приклад конфігурації
cp .env.military.example .env

# Відредагуйте .env та згенеруйте секретні ключі
# (див. коментарі у файлі)

# Завантажте змінні середовища
source .env

# Запустіть всі сервіси
docker-compose -f docker-compose.military.yml up -d

# Перевірте логи
docker-compose -f docker-compose.military.yml logs -f backend

# Перейдіть на frontend
open http://localhost:3000
```

### Локально (без Docker)

```bash
# Встановіть залежності
mix deps.get

# Створіть базу та міграції
mix ecto.create
mix ecto.migrate

# Запустіть seed
mix run priv/repo/seeds/military_setup.exs

# Запустіть сервер
mix phx.server

# Або для production:
MIX_ENV=prod mix release
_build/prod/rel/wraft_doc/bin/wraft_doc start
```

## Очікувані результати

### Створені об'єкти

1. **Організація**: 1 (Військова частина А-1234)
2. **Підрозділи**: 9 (Штаб, S1-S6, 3 роти)
3. **Ролі**: 9 (Командир, Начальник штабу, Начальники відділів, Командир роти, Військовослужбовець)
4. **Типи документів**: 6 (НАК, СЗ, РАП, ЗВТ, ВИХ, ВХ)
5. **Workflow**: 2 (Погодження наказу з 6 етапами, Базовий процес з 3 етапами)
6. **Користувачі**: 9 (1 командир + 8 демо користувачів)
7. **Layout**: 1 (Військовий бланк)
8. **Theme**: 1 (Військова тема)

### Функціональність

- ✅ Створення та управління підрозділами
- ✅ Автоматична генерація номерів документів
- ✅ Ієрархія підрозділів (батько-дитина)
- ✅ Військові ролі з різними правами доступу
- ✅ Шаблони документів для кожного типу
- ✅ Workflow для погодження документів
- ✅ API для роботи з підрозділами

## Troubleshooting

### Помилка: "organisation_id cannot be null"

Переконайтеся, що seed файл правильно отримує organisation_id:

```elixir
# У iex
org = Repo.get_by(Organisation, name: "Військова частина А-1234")
IO.inspect(org.id)
```

### Помилка: "Field type not found"

Перевірте, що базові типи полів були створені:

```elixir
# У iex
alias WraftDoc.Fields.FieldType
Repo.all(FieldType) |> Enum.map(&(&1.name)) |> IO.inspect()
# Повинно включати: "String", "Text", "Date"
```

### Помилка: "Engine not found"

Запустіть основний seed файл перед військовим:

```bash
mix run priv/repo/seeds.exs
mix run priv/repo/seeds/military_setup.exs
```

## Наступні кроки

Після успішного тестування:

1. ✅ Перевірте код через code review
2. ✅ Запустіть CodeQL для перевірки безпеки
3. ✅ Додайте unit тести (опціонально)
4. ✅ Оновіть документацію для користувачів
5. ✅ Підготуйте production deployment

---

**Примітка**: Ця адаптація готова до використання у production середовищі після зміни всіх дефолтних паролів та секретних ключів.
