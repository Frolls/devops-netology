# Решение домашнего задания к занятию "6.2. SQL"

## Задача 1

Используя docker поднимите инстанс PostgreSQL (версию 12) c 2 volume,
в который будут складываться данные БД и бэкапы.

Приведите получившуюся команду или docker-compose манифест.

**Решение**

Docker-compose манифест [тут](/06-db-02-sql/task1/stack.yml)

## Задача 2

В БД из задачи 1:

- создайте пользователя test-admin-user и БД test_db
- в БД test_db создайте таблицу orders и clients (спeцификация таблиц ниже)
- предоставьте привилегии на все операции пользователю test-admin-user на таблицы БД test_db
- создайте пользователя test-simple-user
- предоставьте пользователю test-simple-user права на SELECT/INSERT/UPDATE/DELETE данных таблиц БД test_db

Таблица orders:

- id (serial primary key)
- наименование (string)
- цена (integer)

Таблица clients:

- id (serial primary key)
- фамилия (string)
- страна проживания (string, index)
- заказ (foreign key orders)

Приведите:

- итоговый список БД после выполнения пунктов выше,
- описание таблиц (describe)
- SQL-запрос для выдачи списка пользователей с правами над таблицами test_db
- список пользователей с правами над таблицами test_db

**Решение**

Итоговый список БД после выполнения пунктов запросил командой `SELECT datname FROM pg_database;`. Получилось так:

| datname   |
| --------- |
| postgres  |
| test_db   |
| template1 |
| template0 |

Описание таблиц (describe) получил запросом `SELECT column_name, data_type, column_default FROM INFORMATION_SCHEMA.COLUMNS WHERE table_name = '<table_name>';`

В итоге для таблицы `orders`:

| column_name  | data_type         | column_default                     |
| ------------ | ----------------- | ---------------------------------- |
| id           | integer           | nextval('orders_id_seq'::regclass) |
| наименование | character varying |                                    |
| цена         | integer           |                                    |

Для таблицы `clients`:

| column_name       | data_type         | column_default                      |
| ----------------- | ----------------- | ----------------------------------- |
| id                | integer           | nextval('clients_id_seq'::regclass) |
| фамилия           | character varying |                                     |
| страна проживания | character varying |                                     |
| заказ             | integer           |                                     |

SQL-запрос для выдачи списка пользователей с правами над таблицами test_db:

```sql
SELECT table_name, grantee, privilege_type
FROM information_schema.table_privileges
WHERE table_catalog = 'test_db' AND (table_name = 'orders' OR table_name = 'clients');
```

Результат запроса:

| table_name | grantee          | privilege_type |
| ---------- | ---------------- | -------------- |
| orders     | postgres         | INSERT         |
| orders     | postgres         | SELECT         |
| orders     | postgres         | UPDATE         |
| orders     | postgres         | DELETE         |
| orders     | postgres         | TRUNCATE       |
| orders     | postgres         | REFERENCES     |
| orders     | postgres         | TRIGGER        |
| orders     | test-admin-user  | INSERT         |
| orders     | test-admin-user  | SELECT         |
| orders     | test-admin-user  | UPDATE         |
| orders     | test-admin-user  | DELETE         |
| orders     | test-admin-user  | TRUNCATE       |
| orders     | test-admin-user  | REFERENCES     |
| orders     | test-admin-user  | TRIGGER        |
| orders     | test-simple-user | INSERT         |
| orders     | test-simple-user | SELECT         |
| orders     | test-simple-user | UPDATE         |
| orders     | test-simple-user | DELETE         |
| clients    | postgres         | INSERT         |
| clients    | postgres         | SELECT         |
| clients    | postgres         | UPDATE         |
| clients    | postgres         | DELETE         |
| clients    | postgres         | TRUNCATE       |
| clients    | postgres         | REFERENCES     |
| clients    | postgres         | TRIGGER        |
| clients    | test-admin-user  | INSERT         |
| clients    | test-admin-user  | SELECT         |
| clients    | test-admin-user  | UPDATE         |
| clients    | test-admin-user  | DELETE         |
| clients    | test-admin-user  | TRUNCATE       |
| clients    | test-admin-user  | REFERENCES     |
| clients    | test-admin-user  | TRIGGER        |
| clients    | test-simple-user | INSERT         |
| clients    | test-simple-user | SELECT         |
| clients    | test-simple-user | UPDATE         |
| clients    | test-simple-user | DELETE         |

## Задача 3

Используя SQL синтаксис - наполните таблицы следующими тестовыми данными:

Таблица orders

| Наименование | цена |
| ------------ | ---- |
| Шоколад      | 10   |
| Принтер      | 3000 |
| Книга        | 500  |
| Монитор      | 7000 |
| Гитара       | 4000 |

Таблица clients

| ФИО                  | Страна проживания |
| -------------------- | ----------------- |
| Иванов Иван Иванович | USA               |
| Петров Петр Петрович | Canada            |
| Иоганн Себастьян Бах | Japan             |
| Ронни Джеймс Дио     | Russia            |
| Ritchie Blackmore    | Russia            |

**Решение**

Заполняем таблицы:

```sql
INSERT INTO orders ("наименование", "цена") VALUES
    ('Шоколад', 10),
    ('Принтер', 3000),
    ('Книга', 500),
    ('Монитор', 7000),
    ('Гитара', 4000);
```

```sql
INSERT INTO clients ("фамилия", "страна проживания") VALUES
    ('Иванов Иван Иванович', 'USA'),
    ('Петров Петр Петрович', 'Canada'),
    ('Иоганн Себастьян Бах', 'Japan'),
    ('Ронни Джеймс Дио', 'Russia'),
    ('Ritchie Blackmore', 'Russia');
```

Используя SQL синтаксис:

- вычислите количество записей для каждой таблицы
- приведите в ответе:
  - запросы
  - результаты их выполнения.

Запросы:

```sql
SELECT COUNT(*) FROM clients;
SELECT COUNT(*) FROM orders;
```

Результат выполнения одинаков и имеет значение `5`.

## Задача 4

Часть пользователей из таблицы clients решили оформить заказы из таблицы orders.

Используя foreign keys свяжите записи из таблиц, согласно таблице:

| ФИО                  | Заказ   |
| -------------------- | ------- |
| Иванов Иван Иванович | Книга   |
| Петров Петр Петрович | Монитор |
| Иоганн Себастьян Бах | Гитара  |

**Приведите SQL-запросы для выполнения данных операций.**

Не получилось использовать переменные, видимо, есть нюансы в Postgres.. В итоге, запросы на обновление:

```sql
UPDATE clients
SET "заказ" = (SELECT DISTINCT id FROM orders WHERE "наименование" = 'Книга' LIMIT 1)
WHERE "фамилия" = 'Иванов Иван Иванович';

UPDATE clients
SET "заказ" = (SELECT DISTINCT id FROM orders WHERE "наименование" = 'Монитор' LIMIT 1)
WHERE "фамилия" = 'Петров Петр Петрович';

UPDATE clients
SET "заказ" = (SELECT DISTINCT id FROM orders WHERE "наименование" = 'Гитара' LIMIT 1)
WHERE "фамилия" = 'Иоганн Себастьян Бах';
```

**Приведите SQL-запрос для выдачи всех пользователей, которые совершили заказ, а также вывод данного запроса**

Предположу, что нужно вывести всех пользователей, у которых не пустой заказ:

```sql
SELECT "фамилия" FROM clients
WHERE "заказ" IS NOT NULL;
```

или так:

```sql
SELECT "фамилия" FROM clients "cli"
JOIN orders "ord" ON "cli"."заказ" = "ord".id;
```

Результат:

| фамилия              |
| -------------------- |
| Иванов Иван Иванович |
| Петров Петр Петрович |
| Иоганн Себастьян Бах |

## Задача 5

Получите полную информацию по выполнению запроса выдачи всех пользователей из задачи 4
(используя директиву EXPLAIN).

Приведите получившийся результат и объясните что значат полученные значения.

**Решение**

Результат:

```
QUERY PLAN
Hash Join  (cost=37.00..57.24 rows=810 width=32)
"  Hash Cond: (cli.""заказ"" = ord.id)"
  ->  Seq Scan on clients cli  (cost=0.00..18.10 rows=810 width=36)
  ->  Hash  (cost=22.00..22.00 rows=1200 width=4)
        ->  Seq Scan on orders ord  (cost=0.00..22.00 rows=1200 width=4)
```

Результат содержит план выполнения запроса и предположительные оценки:

- сколько времени потратится на поиск первой записи, а также всех значений `cost=первая_запись..все_значения`;
- число строк. Это значение `rows`;
- длина строки. Значение `width`.

В итоге это кратко можно описать следующим образом:

- прочитана таблица `orders`;
- по `orders.id` был создан hash;
- прочитана таблица `clients`;
- проверяется соответствие в hash `clients."заказ"` и `orders.id`. Далее, если соответствия нет, пропускаем строку. Если есть соответствие, то формируем вывод из hash.

## Задача 6

Создайте бэкап БД test_db и поместите его в volume, предназначенный для бэкапов (см. Задачу 1).

Остановите контейнер с PostgreSQL (но не удаляйте volumes).

Поднимите новый пустой контейнер с PostgreSQL.

Восстановите БД test_db в новом контейнере.

Приведите список операций, который вы применяли для бэкапа данных и восстановления.

**Решение**

Ого! Это же придётся лезть в контейнер..

Проверим, насколько глубока кроличья нора:

```bash
[frolls@mainframe devops-netology]$ docker exec -it postgres_container bash
root@21e8f21e8b9e:/# pg_dump -U postgres test_db > /backups/test_db.dump
```

Проверим, что бэкап базы создан:

```
root@21e8f21e8b9e:/# ls -la /backups/
total 16
drwxr-xr-x 2 root root 4096 May 31 15:33 .
drwxr-xr-x 1 root root 4096 May 31 15:20 ..
-rw-r--r-- 1 root root 4475 May 31 15:33 test_db.dump
```

Не станем мелочиться, удалим контейнеры:

```bash
[frolls@mainframe task1]$ docker-compose -f stack.yml down
[+] Running 3/3
 ⠿ Container postgres_container  Removed                                                                                                       0.4s
 ⠿ Container task1-adminer-1     Removed                                                                                                       0.5s
 ⠿ Network task1_default         Removed                                                                                                       0.2s
[frolls@mainframe task1]$ docker ps -a
CONTAINER ID   IMAGE     COMMAND   CREATED   STATUS    PORTS     NAMES
```

Но volume-то остались! ) Вот:

```bash
[frolls@mainframe task1]$ docker volume ls
DRIVER    VOLUME NAME
local     pg_backup
local     pg_project
```

Запускаем новый пустой контейнер:

```bash
[frolls@mainframe task1]$ docker run --rm -d --name some-postgres -v pg_backup:/backups -e POSTGRES_DB=test_db -e POSTGRES_PASSWORD=passwd -d postgres:12
6ee22f68507055b82397d99e850167972e56a8db0a871feef26a41e177ed9498
[frolls@mainframe task1]$ docker ps -a
CONTAINER ID   IMAGE         COMMAND                  CREATED          STATUS          PORTS      NAMES
6ee22f685070   postgres:12   "docker-entrypoint.s…"   43 seconds ago   Up 42 seconds   5432/tcp   some-postgres
```

Восстанавливаем из бэкапа:

```bash
[frolls@mainframe devops-netology]$ docker exec -it some-postgres bash
root@6ee22f685070:/# psql -U postgres -W test_db < /backups/test_db.dump
Password:
SET
SET
SET
SET
SET
 set_config
------------

(1 row)

SET
SET
SET
SET
SET
SET
CREATE TABLE
ALTER TABLE
CREATE SEQUENCE
ALTER TABLE
ALTER SEQUENCE
CREATE TABLE
ALTER TABLE
CREATE SEQUENCE
ALTER TABLE
ALTER SEQUENCE
ALTER TABLE
ALTER TABLE
COPY 5
COPY 5
 setval
--------
      5
(1 row)

 setval
--------
      5
(1 row)

ALTER TABLE
ALTER TABLE
CREATE INDEX
ALTER TABLE
ERROR:  role "test-admin-user" does not exist
ERROR:  role "test-simple-user" does not exist
ERROR:  role "test-admin-user" does not exist
ERROR:  role "test-simple-user" does not exist
```

Роли куда-то подевались.. ((

Кто знает, может их нужно бэкапить отдельно?

Проверим, что все хорошо:

```
root@6ee22f685070:/# psql -U postgres test_db

test_db=# \l
                                 List of databases
   Name    |  Owner   | Encoding |  Collate   |   Ctype    |   Access privileges
-----------+----------+----------+------------+------------+-----------------------
 postgres  | postgres | UTF8     | en_US.utf8 | en_US.utf8 |
 template0 | postgres | UTF8     | en_US.utf8 | en_US.utf8 | =c/postgres          +
           |          |          |            |            | postgres=CTc/postgres
 template1 | postgres | UTF8     | en_US.utf8 | en_US.utf8 | =c/postgres          +
           |          |          |            |            | postgres=CTc/postgres
 test_db   | postgres | UTF8     | en_US.utf8 | en_US.utf8 |
(4 rows)


test_db=# \d orders
                                    Table "public.orders"
    Column    |       Type        | Collation | Nullable |              Default
--------------+-------------------+-----------+----------+------------------------------------
 id           | integer           |           | not null | nextval('orders_id_seq'::regclass)
 наименование | character varying |           |          |
 цена         | integer           |           |          |
Indexes:
    "orders_pkey" PRIMARY KEY, btree (id)
Referenced by:
    TABLE "clients" CONSTRAINT "fk_заказ" FOREIGN KEY ("заказ") REFERENCES orders(id)

test_db=# \d clients
                                       Table "public.clients"
      Column       |       Type        | Collation | Nullable |               Default
-------------------+-------------------+-----------+----------+-------------------------------------
 id                | integer           |           | not null | nextval('clients_id_seq'::regclass)
 фамилия           | character varying |           |          |
 страна проживания | character varying |           |          |
 заказ             | integer           |           |          |
Indexes:
    "clients_pkey" PRIMARY KEY, btree (id)
    "city" btree ("страна проживания")
Foreign-key constraints:
    "fk_заказ" FOREIGN KEY ("заказ") REFERENCES orders(id)


test_db=# SELECT * FROM orders;
 id | наименование | цена
----+--------------+------
  1 | Шоколад      |   10
  2 | Принтер      | 3000
  3 | Книга        |  500
  4 | Монитор      | 7000
  5 | Гитара       | 4000
(5 rows)


test_db=# SELECT * FROM clients;
 id |       фамилия        | страна проживания | заказ
----+----------------------+-------------------+-------
  4 | Ронни Джеймс Дио     | Russia            |
  5 | Ritchie Blackmore    | Russia            |
  1 | Иванов Иван Иванович | USA               |     3
  2 | Петров Петр Петрович | Canada            |     4
  3 | Иоганн Себастьян Бах | Japan             |     5
(5 rows)
```
