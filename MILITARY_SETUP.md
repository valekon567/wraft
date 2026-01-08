# Інструкція з налаштування військової СЕДО на базі Wraft

## Вступ

Цей документ описує процес встановлення та налаштування системи електронного документообігу (СЕДО) для військової частини Збройних Сил України на базі платформи Wraft.

## 📋 Зміст

1. [Системні вимоги](#системні-вимоги)
2. [Встановлення](#встановлення)
3. [Початкове налаштування](#початкове-налаштування)
4. [Створення користувачів](#створення-користувачів)
5. [Робота з документами](#робота-з-документами)
6. [Резервне копіювання](#резервне-копіювання)
7. [Безпека](#безпека)
8. [Troubleshooting](#troubleshooting)

## Системні вимоги

### Мінімальні вимоги

- **CPU**: 4 ядра (рекомендовано 8)
- **RAM**: 8 GB (рекомендовано 16 GB)
- **Диск**: 100 GB SSD (рекомендовано 500 GB)
- **ОС**: Ubuntu 20.04 LTS або новіша / Debian 11+
- **Мережа**: Локальна мережа 100 Mbps+

### Необхідне програмне забезпечення

- Docker 20.10+ та Docker Compose 2.0+
- PostgreSQL 14+ (якщо не використовується Docker)
- Elixir 1.14+ та Erlang/OTP 25+ (для розробки)
- Git

## Встановлення

### Варіант 1: Використання Docker Compose (Рекомендовано)

#### Крок 1: Клонування репозиторію

```bash
git clone https://github.com/wraft/wraft.git
cd wraft
```

#### Крок 2: Налаштування змінних середовища

```bash
# Копіюємо приклад конфігурації
cp .env.military.example .env

# Генеруємо секретні ключі
mix phx.gen.secret    # Копіюємо в SECRET_KEY_BASE
mix guardian.gen.secret  # Копіюємо в GUARDIAN_KEY
openssl rand -base64 32  # Копіюємо в CLOAK_KEY

# Редагуємо .env файл
nano .env
```

**Важливо**: Змініть всі значення `CHANGE_ME` на згенеровані ключі!

#### Крок 3: Налаштування бази даних

Відредагуйте параметри бази даних в `.env`:

```bash
export DB_USERNAME=vch_user
export DB_PASSWORD=ваш_безпечний_пароль
export DB_NAME=vch_edo
```

#### Крок 4: Запуск через Docker Compose

```bash
# Завантажуємо .env змінні
source .env

# Запускаємо сервіси
docker compose -f docker-compose.military.yml up -d

# Перевіряємо статус
docker compose -f docker-compose.military.yml ps
```

#### Крок 5: Створення бази даних та міграції

```bash
# Входимо в контейнер backend
docker exec -it military_backend bash

# Створюємо базу даних
mix ecto.create

# Запускаємо міграції
mix ecto.migrate

# Запускаємо військовий seed
mix run priv/repo/seeds/military_setup.exs

# Виходимо з контейнера
exit
```

### Варіант 2: Встановлення без Docker

#### Крок 1: Встановлення залежностей

```bash
# Ubuntu/Debian
sudo apt update
sudo apt install -y postgresql-14 erlang elixir git build-essential

# Встановлюємо Node.js для frontend (опціонально)
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt install -y nodejs
```

#### Крок 2: Налаштування PostgreSQL

```bash
sudo -u postgres psql

-- В psql консолі:
CREATE USER vch_user WITH PASSWORD 'ваш_безпечний_пароль';
CREATE DATABASE vch_edo OWNER vch_user;
GRANT ALL PRIVILEGES ON DATABASE vch_edo TO vch_user;
\q
```

#### Крок 3: Клонування та налаштування

```bash
git clone https://github.com/wraft/wraft.git
cd wraft

# Копіюємо конфігурацію
cp .env.military.example .env

# Встановлюємо залежності
mix deps.get
mix deps.compile
```

#### Крок 4: Завантаження змінних та міграція

```bash
source .env

mix ecto.create
mix ecto.migrate
mix run priv/repo/seeds/military_setup.exs
```

#### Крок 5: Запуск серверу

```bash
mix phx.server
```

Або для production:

```bash
MIX_ENV=prod mix release
_build/prod/rel/wraft_doc/bin/wraft_doc start
```

## Початкове налаштування

### Перший вхід

Після встановлення відкрийте браузер і перейдіть на:

```
http://localhost:3000
```

Для першого входу використовуйте:

- **Email**: `commander@military.local`
- **Пароль**: `Military2025!`

### Що створюється автоматично

Скрипт `military_setup.exs` автоматично створює:

#### 1. Організацію
- Військова частина А-1234 (або з `MILITARY_UNIT_NAME`)

#### 2. Підрозділи
- Штаб (SHTAB)
- Відділ кадрів - S1
- Відділ розвідки - S2
- Відділ операцій - S3
- Відділ матзабезпечення - S4
- Відділ зв'язку - S6
- 1-а, 2-а, 3-я роти

#### 3. Ролі
- Командир частини
- Начальник штабу
- Начальник відділу S1-S6
- Командир роти
- Військовослужбовець

#### 4. Типи документів
- Наказ по частині (НАК-XXX/YYYY)
- Службова записка (СЗ-XXX/YYYY)
- Рапорт (РАП-XXX/YYYY)
- Звіт (ЗВТ-XXX/YYYY)
- Вихідний лист (ВИХ-XXX/YYYY)
- Вхідний лист (ВХ-XXX/YYYY)

#### 5. Workflow процеси
- Погодження наказу (6 етапів)
- Базовий процес (3 етапи)

#### 6. Демо-користувачі

| Email | Пароль | Роль |
|-------|--------|------|
| commander@military.local | Military2025! | Командир частини |
| chief@military.local | Military2025! | Начальник штабу |
| s1@military.local | Military2025! | Начальник S1 |
| s2@military.local | Military2025! | Начальник S2 |
| s3@military.local | Military2025! | Начальник S3 |
| s4@military.local | Military2025! | Начальник S4 |
| s6@military.local | Military2025! | Начальник S6 |
| company@military.local | Military2025! | Командир роти |
| soldier@military.local | Military2025! | Військовослужбовець |

**⚠️ Важливо**: Змініть всі паролі після першого входу!

## Створення користувачів

### Через веб-інтерфейс

1. Увійдіть як командир частини
2. Перейдіть в розділ "Користувачі"
3. Натисніть "Додати користувача"
4. Заповніть форму:
   - ПІБ
   - Email (службовий)
   - Роль
   - Підрозділ
5. Збережіть

Користувач отримає email з інструкціями для активації облікового запису.

### Через консоль (альтернативний спосіб)

```bash
# Входимо в Elixir консоль
docker exec -it military_backend iex -S mix

# Або якщо без Docker
iex -S mix
```

```elixir
# Створюємо користувача
alias WraftDoc.Account.User
alias WraftDoc.Repo

%User{}
|> User.changeset(%{
  name: "Іванов Іван Іванович",
  email: "ivanov@military.local",
  encrypted_password: Bcrypt.hash_pwd_salt("temporary_password"),
  email_verify: true
})
|> Repo.insert!()
```

## Робота з документами

### Створення наказу

1. Натисніть "Створити документ"
2. Оберіть тип "Наказ по частині"
3. Заповніть поля:
   - Номер наказу (генерується автоматично)
   - Дата наказу
   - Назва наказу
   - Зміст наказу
   - Виконавець
   - Підстава
4. Збережіть як "Проект"

### Процес погодження

Наказ проходить наступні етапи:

1. **Проект** - створення документу
2. **Погодження S1** - перевірка кадрових питань
3. **Погодження S3** - перевірка операційних аспектів
4. **Затвердження начальником штабу** - попереднє затвердження
5. **Підпис командира** - фінальне затвердження
6. **Затверджено** - документ вступає в силу

### Нумерація документів

Номери генеруються автоматично в форматі:

- `НАК-001/2025` - наказ №1 за 2025 рік
- `СЗ-045/2025` - службова записка №45 за 2025 рік
- `РАП-123/2025` - рапорт №123 за 2025 рік

Лічильники скидаються на початку кожного року.

### Пошук документів

Використовуйте пошукову панель для знаходження документів за:

- Номером
- Датою
- Автором
- Типом
- Підрозділом
- Станом (проект, погоджено, затверджено)

## Резервне копіювання

### Автоматичний backup через Docker

```bash
# Створення backup
docker compose -f docker-compose.military.yml --profile backup run backup

# Backup буде збережено в ./backups/backup_YYYYMMDD_HHMMSS.sql
```

### Ручний backup PostgreSQL

```bash
# Backup бази даних
pg_dump -h localhost -U vch_user vch_edo > backup_$(date +%Y%m%d).sql

# Відновлення з backup
psql -h localhost -U vch_user vch_edo < backup_20250108.sql
```

### Backup файлів MinIO

```bash
# Backup всіх документів
docker exec military_minio mc mirror /data/vch-documents /backups/minio_backup
```

### Рекомендований графік backup

- **Щодня**: Інкрементальний backup бази даних
- **Щотижня**: Повний backup бази даних
- **Щомісяця**: Повний backup бази даних та файлів

## Безпека

### Рекомендації з безпеки

#### 1. Мережева безпека

- Використовуйте firewall (ufw або iptables)
- Обмежте доступ тільки до внутрішньої мережі
- Налаштуйте IP whitelist в `.env`:

```bash
export ALLOWED_IPS=192.168.1.0/24,10.0.0.0/8
```

#### 2. Паролі та ключі

- Змініть всі дефолтні паролі
- Використовуйте складні паролі (мінімум 12 символів)
- Регулярно оновлюйте паролі (кожні 90 днів)
- Зберігайте ключі в безпечному місці

#### 3. Аудит та логування

Система автоматично логує всі дії користувачів:

- Створення/редагування документів
- Зміна прав доступу
- Вхід/вихід з системи
- Зміни в підрозділах

Логи зберігаються протягом 5 років (1825 днів).

#### 4. Оновлення

Регулярно оновлюйте систему:

```bash
# Оновлення через Git
git pull origin main

# Оновлення залежностей
mix deps.get
mix deps.update --all

# Застосування нових міграцій
mix ecto.migrate

# Перезапуск
docker compose -f docker-compose.military.yml restart
```

#### 5. HTTPS

Для production використовуйте HTTPS:

```bash
# Встановлення Let's Encrypt (якщо є зовнішній доступ)
sudo apt install certbot

# Або налаштуйте власний SSL сертифікат
# Додайте в docker-compose.military.yml:
# volumes:
#   - ./ssl/cert.pem:/app/ssl/cert.pem
#   - ./ssl/key.pem:/app/ssl/key.pem
```

### Firewall правила (приклад для ufw)

```bash
# Дозволяємо SSH
sudo ufw allow 22/tcp

# Дозволяємо HTTP/HTTPS тільки з локальної мережі
sudo ufw allow from 192.168.1.0/24 to any port 80
sudo ufw allow from 192.168.1.0/24 to any port 443
sudo ufw allow from 192.168.1.0/24 to any port 3000
sudo ufw allow from 192.168.1.0/24 to any port 4000

# Блокуємо все інше
sudo ufw default deny incoming
sudo ufw default allow outgoing

# Активуємо firewall
sudo ufw enable
```

## Troubleshooting

### Проблема: База даних не підключається

**Симптоми**: Помилка `connection refused` або `could not connect to server`

**Рішення**:

```bash
# Перевірте чи запущено PostgreSQL
sudo systemctl status postgresql

# Перезапустіть PostgreSQL
sudo systemctl restart postgresql

# Перевірте credentials в .env
cat .env | grep DATABASE_URL
```

### Проблема: MinIO не зберігає файли

**Симптоми**: Помилки при завантаженні файлів

**Рішення**:

```bash
# Перевірте чи створено bucket
docker exec -it military_minio mc ls myminio

# Створіть bucket вручну якщо потрібно
docker exec -it military_minio mc mb myminio/vch-documents
docker exec -it military_minio mc anonymous set download myminio/vch-documents
```

### Проблема: Typesense не працює

**Симптоми**: Пошук не повертає результатів

**Рішення**:

```bash
# Перевірте чи запущено Typesense
docker ps | grep typesense

# Перезапустіть Typesense
docker restart military_typesense

# Переіндексуйте дані
docker exec -it military_backend mix typesense.reindex
```

### Проблема: Високе навантаження на CPU/RAM

**Рішення**:

```bash
# Перевірте використання ресурсів
docker stats

# Збільште ліміти в docker-compose.military.yml:
# deploy:
#   resources:
#     limits:
#       cpus: '2'
#       memory: 4G
```

### Проблема: Seed не створює дані

**Рішення**:

```bash
# Очистіть базу даних (УВАГА: видалить всі дані!)
docker exec -it military_backend mix ecto.drop
docker exec -it military_backend mix ecto.create
docker exec -it military_backend mix ecto.migrate

# Запустіть seed знову
docker exec -it military_backend mix run priv/repo/seeds/military_setup.exs
```

### Логи для діагностики

```bash
# Backend логи
docker logs military_backend --tail 100 -f

# Database логи
docker logs military_db --tail 100 -f

# MinIO логи
docker logs military_minio --tail 100 -f

# Всі логи разом
docker compose -f docker-compose.military.yml logs -f
```

## Підтримка

Для отримання додаткової інформації:

- 📚 Документація Wraft: https://docs.wraft.com
- 🐛 Повідомити про помилку: https://github.com/wraft/wraft/issues
- 💬 Спільнота: https://github.com/wraft/wraft/discussions

## Ліцензія

Wraft розповсюджується під ліцензією AGPL-3.0. Детальніше в файлі LICENSE.md.

---

**Версія документу**: 1.0  
**Дата останнього оновлення**: 08.01.2026  
**Автор**: Команда Wraft  
**Мова**: Українська
