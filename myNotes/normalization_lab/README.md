
# Лабораторная работа №1. Нормализация данных в БД (с ведением лога)

## Цель работы

Привести ненормализованную таблицу `sales_unnormalized_2` к третьей нормальной форме (3NF), разбив её на четыре таблицы, продемонстрировать аномалии исходной схемы, перенести данные без потерь и искажений, а также освоить ведение и экспорт общего лога действий пользователя MySQL.

## Среда выполнения

- VS Code
- Git Bash (Windows)
- Docker CLI
- Образ `mysql:8.0`
- Контейнер `mysql_norm`
- Volume `mysql_norm_data`

## 1. Подготовка окружения

### 1.1. Запуск контейнера MySQL

Настройки логирования переданы напрямую в `docker run`, без монтирования файла `my.cnf`:

```bash
MSYS_NO_PATHCONV=1 docker run --name mysql_norm \
  -e MYSQL_ROOT_PASSWORD=123 \
  -e LANG=C.UTF-8 \
  -e MYSQL_INITDB_SKIP_TZINFO=1 \
  -v mysql_norm_data:/var/lib/mysql \
  -d mysql:8.0 \
  --general-log=1 \
  --general-log-file=/var/lib/mysql/general.log \
  --log-output=FILE
```

Префикс `MSYS_NO_PATHCONV=1` отключает автоматическое преобразование Unix-путей в Windows-пути в Git Bash.

### 1.2. Проверка, что контейнер запущен

```bash
docker ps
```

### 1.3. Подключение к MySQL

```bash
MSYS_NO_PATHCONV=1 docker exec -it mysql_norm mysql -uroot -p
```

Пароль: `123`.

### 1.4. Проверка настроек логирования

```sql
SHOW VARIABLES LIKE 'general_log';
SHOW VARIABLES LIKE 'general_log_file';
SHOW VARIABLES LIKE 'log_output';
```

Ожидаемые значения:

- `general_log` — `ON`
- `general_log_file` — `/var/lib/mysql/general.log`
- `log_output` — `FILE`

## 2. Создание базы данных и ненормализованной таблицы

### 2.1. Создание базы данных

```sql
CREATE DATABASE normalization_task
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;
USE normalization_task;
```

### 2.2. Создание таблицы `sales_unnormalized_2`

```sql
CREATE TABLE sales_unnormalized_2 (
    report_id     INT,
    report_date   DATE,
    customer_id   INT,
    customer_name VARCHAR(100),
    product_id    INT,
    product_name  VARCHAR(100),
    price         DECIMAL(10,2),
    quantity      INT
);
```

### 2.3. Заполнение таблицы данными

```sql
INSERT INTO sales_unnormalized_2 VALUES
(1101, '2026-03-05', 12, 'Дания',   101, 'Дыни',      800, 1100),
(1101, '2026-03-05', 12, 'Дания',   102, 'Клубника',  150,  300),
(1102, '2026-03-07', 23, 'Испания', 103, 'Яблоки',    120, 1700),
(1103, '2026-03-08', 25, 'Албания', 104, 'Лимоны',    200,  500),
(1104, '2026-03-10', 12, 'Дания',   101, 'Дыни',      800, 2500),
(1105, '2026-03-12', 25, 'Албания', 103, 'Яблоки',    120, 2000),
(1105, '2026-03-12', 25, 'Албания', 104, 'Лимоны',    200,  700);
```

### 2.4. Проверка исходных данных

```sql
SELECT COUNT(*) FROM sales_unnormalized_2;
SELECT * FROM sales_unnormalized_2;
```

Ожидается 7 строк.

### 2.5. Дамп базы до нормализации

Выполняется в Git Bash (не в клиенте MySQL):

```bash
MSYS_NO_PATHCONV=1 docker exec -e MYSQL_PWD=123 mysql_norm mysqldump -uroot normalization_task > dump_before.sql
```

Проверка, что дамп не пустой:

```bash
grep -c "INSERT INTO" dump_before.sql
```

## 3. Демонстрация аномалий

### 3.1. Аномалия обновления

Изменение имени покупателя в одной строке приводит к рассогласованию данных по одному и тому же `customer_id`:

```sql
UPDATE sales_unnormalized_2
SET customer_name = 'Дания (обновлено)'
WHERE customer_id = 12 AND product_id = 101;

SELECT customer_id, customer_name
FROM sales_unnormalized_2
WHERE customer_id = 12;
```

В результате у покупателя с кодом `12` одновременно присутствуют значения `Дания` и `Дания (обновлено)`.

Откат изменения:

```sql
UPDATE sales_unnormalized_2
SET customer_name = 'Дания'
WHERE customer_id = 12;
```

### 3.2. Аномалия вставки

Добавить нового покупателя без оформленного отчёта невозможно: для этого пришлось бы вставить строку с `report_id` и `product_id`, которых не существует. Аналогично нельзя добавить новый товар, не привязав его к отчёту.

### 3.3. Аномалия удаления

Удаление всех строк покупателя с кодом `12` приведёт к полной потере информации о покупателе, так как отдельного справочника покупателей нет.

## 4. Создание нормализованных таблиц (3NF)

```sql
CREATE TABLE customers (
    customer_id   INT PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE TABLE products (
    product_id   INT PRIMARY KEY,
    product_name VARCHAR(100) NOT NULL,
    price        DECIMAL(10,2) NOT NULL
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE TABLE reports (
    report_id   INT PRIMARY KEY,
    report_date DATE NOT NULL,
    customer_id INT NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE TABLE report_items (
    report_id  INT NOT NULL,
    product_id INT NOT NULL,
    quantity   INT NOT NULL,
    PRIMARY KEY (report_id, product_id),
    FOREIGN KEY (report_id)  REFERENCES reports(report_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
```

## 5. Перенос данных в нормализованные таблицы

```sql
INSERT INTO customers (customer_id, customer_name)
SELECT DISTINCT customer_id, customer_name
FROM sales_unnormalized_2;

INSERT INTO products (product_id, product_name, price)
SELECT DISTINCT product_id, product_name, price
FROM sales_unnormalized_2;

INSERT INTO reports (report_id, report_date, customer_id)
SELECT DISTINCT report_id, report_date, customer_id
FROM sales_unnormalized_2;

INSERT INTO report_items (report_id, product_id, quantity)
SELECT report_id, product_id, quantity
FROM sales_unnormalized_2;
```

## 6. Проверка целостности перенесённых данных

### 6.1. Сравнение количества строк

```sql
SELECT COUNT(DISTINCT customer_id) AS customers_before FROM sales_unnormalized_2;
SELECT COUNT(*) AS customers_after FROM customers;

SELECT COUNT(DISTINCT product_id) AS products_before FROM sales_unnormalized_2;
SELECT COUNT(*) AS products_after FROM products;

SELECT COUNT(DISTINCT report_id) AS reports_before FROM sales_unnormalized_2;
SELECT COUNT(*) AS reports_after FROM reports;
```

### 6.2. Сравнение общей суммы

```sql
SELECT 'before' AS stage, SUM(price * quantity) AS total_sum
FROM sales_unnormalized_2
UNION ALL
SELECT 'after',
       (SELECT SUM(p.price * ri.quantity)
        FROM report_items ri
        JOIN products p ON p.product_id = ri.product_id);
```

Значения `total_sum` до и после должны совпадать.

## 7. Тестовые запросы на нормализованной схеме

### 7.1. Сумма покупок покупателя с кодом 12

```sql
SELECT c.customer_name, SUM(p.price * ri.quantity) AS total_spent
FROM customers c
JOIN reports r ON r.customer_id = c.customer_id
JOIN report_items ri ON ri.report_id = r.report_id
JOIN products p ON p.product_id = ri.product_id
WHERE c.customer_id = 12
GROUP BY c.customer_id, c.customer_name;
```

### 7.2. Все отчёты с позициями

```sql
SELECT r.report_id, r.report_date, c.customer_name, p.product_name, ri.quantity
FROM reports r
JOIN customers c ON c.customer_id = r.customer_id
JOIN report_items ri ON ri.report_id = r.report_id
JOIN products p ON p.product_id = ri.product_id
ORDER BY r.report_id, p.product_id;
```

## 8. Переименование исходной таблицы

После успешной проверки исходная таблица переименована:

```sql
RENAME TABLE sales_unnormalized_2 TO sales_unnormalized_2_backup;
```

## 9. Дамп базы после нормализации

Выполняется в Git Bash:

```bash
MSYS_NO_PATHCONV=1 docker exec -e MYSQL_PWD=123 mysql_norm mysqldump -uroot \
  --set-gtid-purged=OFF \
  --single-transaction \
  normalization_task > dump_after.sql
```

Проверка, что дамп не пустой:

```bash
grep -c "INSERT INTO" dump_after.sql
```

## 10. Ведение и экспорт лога действий пользователя

### 10.1. Проверка, что лог пишется

```bash
MSYS_NO_PATHCONV=1 docker exec mysql_norm ls -la /var/lib/mysql/general.log
```

Файл должен иметь размер больше 0 и принадлежать пользователю `mysql`.

### 10.2. Просмотр последних строк лога

```bash
MSYS_NO_PATHCONV=1 docker exec mysql_norm tail -n 30 /var/lib/mysql/general.log
```

### 10.3. Фильтрация только своих действий

```bash
MSYS_NO_PATHCONV=1 docker exec mysql_norm cat /var/lib/mysql/general.log \
  | grep -E "Query[[:space:]]+(CREATE|INSERT|SELECT|UPDATE|DELETE|ALTER|DROP|RENAME|SHOW DATABASES|SHOW TABLES|SHOW FULL TABLES|SHOW CREATE|SHOW VARIABLES LIKE)" \
  | grep -v -E "INSERT INTO help_|INSERT INTO time_zone|INSERT INTO mysql\.|SELECT \* FROM mysql\.general_log" \
  > my_actions.log
```

Проверка результата:

```bash
wc -l my_actions.log
cat my_actions.log
```

В файле должны остаться только осмысленные SQL-команды, выполненные в ходе работы.

### 10.4. Копирование лога на хост

```bash
MSYS_NO_PATHCONV=1 docker cp mysql_norm:/var/lib/mysql/general.log ./general.log
ls -la general.log
```

Размер скопированного файла должен быть больше 0.

### 10.5. Очистка лога

```bash
MSYS_NO_PATHCONV=1 docker exec -u mysql mysql_norm sh -c ': > /var/lib/mysql/general.log'
```

## 11. Состав файлов в репозитории

```
normalization_lab/
├── README.md
├── general.log
├── my_actions.log
├── dump_before.sql
└── dump_after.sql
```

## 12. Примечания

- Настройки логирования переданы аргументами в `docker run` (`--general-log=1`, `--general-log-file=/var/lib/mysql/general.log`, `--log-output=FILE`), без использования файла `my.cnf`. Это исключает проблему, при которой Docker создаёт каталог вместо файла конфигурации при отсутствии исходного файла на хосте.
- Все команды `docker exec`, `docker cp` и `docker run`, содержащие Unix-пути, выполнены с префиксом `MSYS_NO_PATHCONV=1`, чтобы Git Bash не преобразовывал пути вида `/var/lib/mysql/...` в Windows-пути.
- Лог скопирован в репозиторий как `general.log`; отфильтрованная версия содержит только действия, выполненные в рамках работы.
- Дампы `dump_before.sql` и `dump_after.sql` сняты до и после нормализации соответственно.

## Скриншоты о выполнении работы

![alt text](<screen/Снимок экрана 2026-11-10 112332.png>)

![alt text](<screen/Снимок экрана 2026-11-10 112345.png>)

![alt text](<screen/Снимок экрана 2026-11-10 112401.png>)

![alt text](<screen/Снимок экрана 2026-11-10 112413.png>)

![alt text](<screen/Снимок экрана 2026-11-10 112917.png>)

![alt text](<screen/Снимок экрана 2026-11-10 113507.png>)