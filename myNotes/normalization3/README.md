
# Лабораторная работа №3. Нормализация данных в БД (с ведением лога)

## Цель работы

Привести ненормализованную таблицу продаж сотрудников по отделам к третьей нормальной форме, разбив её на таблицы-справочники и таблицу фактов; перенести данные без потерь и искажений; снять дампы до и после нормализации; освоить ведение и экспорт общего лога действий пользователя MySQL.

## Среда выполнения

- VS Code
- Git Bash (Windows)
- Docker CLI
- Образ `mysql:8.0`
- Контейнер `mysql_norm`
- Volume `mysql_norm_data`
- База данных `sales_norm`

## 1. Подготовка окружения

### 1.1. Удаление старого контейнера (если был)

```bash
docker stop mysql_norm 2>/dev/null
docker rm mysql_norm 2>/dev/null
docker volume rm mysql_norm_data 2>/dev/null
```

### 1.2. Запуск контейнера MySQL с логированием

Настройки логирования передаются напрямую в `docker run`, без использования файла `my.cnf`. Такой подход исключает ситуацию, когда Docker при отсутствии файла конфигурации на хосте создаёт каталог с тем же именем и MySQL не может прочитать настройки.

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

Префикс `MSYS_NO_PATHCONV=1` отключает автоматическое преобразование Unix-путей в Windows-пути в Git Bash. Без него путь `/var/lib/mysql/general.log` превращается в `C:/Program Files/Git/var/lib/mysql/general.log`, и команды `docker exec`/`docker cp` работают с неверным путём.

### 1.3. Проверка, что контейнер запущен

```bash
docker ps
```

### 1.4. Подключение к MySQL

```bash
MSYS_NO_PATHCONV=1 docker exec -it mysql_norm mysql -uroot -p
```

Пароль: `123`.

### 1.5. Проверка настроек логирования

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
CREATE DATABASE sales_norm
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;
USE sales_norm;
```

### 2.2. Создание таблицы `employee_sales_bad`

Исходная таблица содержит повторяющиеся группы: для одного сотрудника в одном месяце перечислены несколько отделов. В реляционной таблице эти данные продублированы в каждой строке.

```sql
CREATE TABLE employee_sales_bad (
    employee_id     INT,
    employee_name   VARCHAR(100),
    sale_month      VARCHAR(7),
    sales_amount    DECIMAL(12,2),
    department_id   INT,
    department_name VARCHAR(100)
);
```

### 2.3. Заполнение таблицы данными

```sql
INSERT INTO employee_sales_bad VALUES
(1, 'Иванов Иван',     '2026-01', 120000.00, 10, 'Отдел реализации'),
(1, 'Иванов Иван',     '2026-01',  80000.00, 20, 'Отдел развития'),
(1, 'Иванов Иван',     '2026-01',  50000.00, 30, 'Отдел экспорта'),
(2, 'Петрова Мария',   '2026-01', 150000.00, 10, 'Отдел реализации'),
(2, 'Петрова Мария',   '2026-01',  60000.00, 30, 'Отдел экспорта'),
(3, 'Сидоров Алексей', '2026-01',  90000.00, 20, 'Отдел развития'),
(3, 'Сидоров Алексей', '2026-01',  70000.00, 30, 'Отдел экспорта'),
(1, 'Иванов Иван',     '2026-02', 130000.00, 10, 'Отдел реализации'),
(1, 'Иванов Иван',     '2026-02',  85000.00, 20, 'Отдел развития'),
(2, 'Петрова Мария',   '2026-02', 160000.00, 10, 'Отдел реализации');
```

### 2.4. Проверка исходных данных

```sql
SELECT COUNT(*) FROM employee_sales_bad;
SELECT * FROM employee_sales_bad ORDER BY employee_id, sale_month, department_id;
```

Ожидается 10 строк. Контрольная сумма `SUM(sales_amount)` для этих данных равна `995000.00`.

```sql
SELECT SUM(sales_amount) AS total_sum FROM employee_sales_bad;
```

### 2.5. Дамп базы до нормализации

Выполняется в Git Bash, не в клиенте MySQL:

```bash
MSYS_NO_PATHCONV=1 docker exec -e MYSQL_PWD=123 mysql_norm mysqldump -uroot sales_norm > dump_before.sql
```

Проверка, что дамп не пустой:

```bash
grep -c "INSERT INTO" dump_before.sql
```

## 3. Создание нормализованных таблиц (3NF)

Ненормализованная таблица содержит частичные и транзитивные зависимости: имя сотрудника зависит только от `employee_id`, название отдела — только от `department_id`. Для приведения к 3NF создаются справочники `employees`, `departments` и таблица фактов `employee_sales`.

```sql
CREATE TABLE employees (
    employee_id   INT PRIMARY KEY,
    employee_name VARCHAR(100) NOT NULL
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE TABLE departments (
    department_id   INT PRIMARY KEY,
    department_name VARCHAR(100) NOT NULL
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE TABLE employee_sales (
    employee_id   INT NOT NULL,
    sale_month    VARCHAR(7) NOT NULL,
    department_id INT NOT NULL,
    sales_amount  DECIMAL(12,2) NOT NULL,
    PRIMARY KEY (employee_id, sale_month, department_id),
    FOREIGN KEY (employee_id)   REFERENCES employees(employee_id),
    FOREIGN KEY (department_id) REFERENCES departments(department_id)
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
```

## 4. Перенос данных в нормализованные таблицы

```sql
INSERT INTO employees (employee_id, employee_name)
SELECT DISTINCT employee_id, employee_name
FROM employee_sales_bad;

INSERT INTO departments (department_id, department_name)
SELECT DISTINCT department_id, department_name
FROM employee_sales_bad;

INSERT INTO employee_sales (employee_id, sale_month, department_id, sales_amount)
SELECT employee_id, sale_month, department_id, sales_amount
FROM employee_sales_bad;
```

## 5. Проверка целостности перенесённых данных

### 5.1. Сравнение количества строк

```sql
SELECT COUNT(DISTINCT employee_id) AS employees_before FROM employee_sales_bad;
SELECT COUNT(*) AS employees_after FROM employees;

SELECT COUNT(DISTINCT department_id) AS departments_before FROM employee_sales_bad;
SELECT COUNT(*) AS departments_after FROM departments;

SELECT COUNT(*) AS sales_before FROM employee_sales_bad;
SELECT COUNT(*) AS sales_after FROM employee_sales;
```

Ожидается: сотрудников 3, отделов 3, фактов продаж 10.

### 5.2. Сравнение общей суммы

```sql
SELECT 'before' AS stage, SUM(sales_amount) AS total_sum
FROM employee_sales_bad
UNION ALL
SELECT 'after',
       (SELECT SUM(sales_amount) FROM employee_sales);
```

Оба значения `total_sum` должны равняться `995000.00`.

## 6. Тестовые запросы на нормализованной схеме

### 6.1. Сумма продаж сотрудника 1 по месяцам

```sql
SELECT e.employee_name, es.sale_month, SUM(es.sales_amount) AS total_sales
FROM employees e
JOIN employee_sales es ON es.employee_id = e.employee_id
WHERE e.employee_id = 1
GROUP BY e.employee_id, e.employee_name, es.sale_month
ORDER BY es.sale_month;
```

### 6.2. Сумма продаж по отделам

```sql
SELECT d.department_name, SUM(es.sales_amount) AS total_sales
FROM departments d
JOIN employee_sales es ON es.department_id = d.department_id
GROUP BY d.department_id, d.department_name
ORDER BY total_sales DESC;
```

### 6.3. Все факты продаж с расшифровкой

```sql
SELECT e.employee_name, es.sale_month, d.department_name, es.sales_amount
FROM employee_sales es
JOIN employees e   ON e.employee_id = es.employee_id
JOIN departments d ON d.department_id = es.department_id
ORDER BY es.employee_id, es.sale_month, es.department_id;
```

## 7. Переименование исходной таблицы

После успешной проверки исходная таблица переименована:

```sql
RENAME TABLE employee_sales_bad TO employee_sales_bad_backup;
```

## 8. Дамп базы после нормализации

Выполняется в Git Bash:

```bash
MSYS_NO_PATHCONV=1 docker exec -e MYSQL_PWD=123 mysql_norm mysqldump -uroot \
  --set-gtid-purged=OFF \
  --single-transaction \
  sales_norm > dump_after.sql
```

Проверка, что дамп не пустой:

```bash
grep -c "INSERT INTO" dump_after.sql
```

## 9. Ведение и экспорт лога действий пользователя

### 9.1. Проверка, что лог пишется

```bash
MSYS_NO_PATHCONV=1 docker exec mysql_norm ls -la /var/lib/mysql/general.log
```

Файл должен иметь размер больше 0 и принадлежать пользователю `mysql`.

### 9.2. Просмотр последних строк лога

```bash
MSYS_NO_PATHCONV=1 docker exec mysql_norm tail -n 30 /var/lib/mysql/general.log
```

### 9.3. Фильтрация только своих действий

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

### 9.4. Копирование лога на хост

```bash
MSYS_NO_PATHCONV=1 docker cp mysql_norm:/var/lib/mysql/general.log ./general.log
ls -la general.log
```

Размер скопированного файла должен быть больше 0.

### 9.5. Очистка лога

Выполняется после копирования лога и снятия скриншотов:

```bash
MSYS_NO_PATHCONV=1 docker exec -u mysql mysql_norm sh -c ': > /var/lib/mysql/general.log'
```

## 10. Состав файлов в репозитории

```
normalization_lab/
├── README.md
├── general.log
├── my_actions.log
├── dump_before.sql
└── dump_after.sql
```



## Скриншоты о выполнении работы

![alt text](<screen/Снимок экрана 2026-11-12 104058.png>)

![alt text](<screen/Снимок экрана 2026-11-12 104128.png>)

![alt text](<screen/Снимок экрана 2026-11-12 104230.png>)

![alt text](<screen/Снимок экрана 2026-11-12 104329.png>)

![alt text](<screen/Снимок экрана 2026-11-12 104345.png>)

![alt text](<screen/Снимок экрана 2026-11-12 104355.png>)

![alt text](<screen/Снимок экрана 2026-11-12 104405.png>)

![alt text](<screen/Снимок экрана 2026-11-12 104416.png>)