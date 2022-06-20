# Решение домашнего задания к занятию "6.4. PostgreSQL"

## Задача 1

Используя docker поднимите инстанс PostgreSQL (версию 13). Данные БД сохраните в volume.

Подключитесь к БД PostgreSQL используя `psql`.

Воспользуйтесь командой `\?` для вывода подсказки по имеющимся в `psql` управляющим командам.

**Найдите и приведите** управляющие команды для:

- вывода списка БД
- подключения к БД
- вывода списка таблиц
- вывода описания содержимого таблиц
- выхода из psql

**Решение**

Напишем Docker-compose манифест, прописав volumes: один volume для хранения данных БД + забиндим директорию с бэкапом.

Сам docker-compose манифест [тут](task1/stack.yml)

Подключился к PostgreSQL командой `psql -U postgres`. Далее из справки узнал, что существуют команды для:

- **вывода списка БД**: `\l`
- **подключения к БД**: `\conninfo`
- **вывода списка таблиц**: `\dt [PATTERN]`. Например, так можно вывести все таблицы: `\dt *.*`
- **вывода описания содержимого таблиц**: `\d[S+]  NAME`
- **выхода из psql**: `\q`

## Задача 2

Используя `psql` создайте БД `test_database`.

Изучите [бэкап БД](https://github.com/netology-code/virt-homeworks/tree/master/06-db-04-postgresql/test_data).

Восстановите бэкап БД в `test_database`.

Перейдите в управляющую консоль `psql` внутри контейнера.

Подключитесь к восстановленной БД и проведите операцию ANALYZE для сбора статистики по таблице.

Используя таблицу [pg_stats](https://postgrespro.ru/docs/postgresql/12/view-pg-stats), найдите столбец таблицы `orders`
с наибольшим средним значением размера элементов в байтах.

**Приведите в ответе** команду, которую вы использовали для вычисления и полученный результат.

**Решение**

Создадим БД и выйдем из шелла командой `\q`:

```sql
postgres=# CREATE DATABASE test_database;
CREATE DATABASE
postgres=# \q
```

Изучил бэкап. Там буквально одна табличка с 8 записями

Штош, пора восстанавливать бэкап:

```sql
root@bb511140ffb7:/# psql -U postgres -W test_database < /backup/test_dump.sql
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
ALTER TABLE
COPY 8
 setval
--------
      8
(1 row)

ALTER TABLE
```

Готово! Подключаемся и запускаем операцию ANALYZE:

```bash
root@bb511140ffb7:/# psql -U postgres test_database
psql (13.7 (Debian 13.7-1.pgdg110+1))
Type "help" for help.

test_database=# ANALYZE orders;
ANALYZE
```

Поиск столбца таблицы `orders` с наибольшим средним значением размера элементов в байтах:

```sql
test_database=# select attname from pg_stats where avg_width = (select max(avg_width) from pg_stats where tablename = 'orders');
 attname
---------
 title
(1 row)
```

Это столбец `title`.

## Задача 3

Архитектор и администратор БД выяснили, что ваша таблица orders разрослась до невиданных размеров и
поиск по ней занимает долгое время. Вам, как успешному выпускнику курсов DevOps в нетологии предложили
провести разбиение таблицы на 2 (шардировать на orders_1 - price>499 и orders_2 - price<=499).

Предложите SQL-транзакцию для проведения данной операции.

Можно ли было изначально исключить "ручное" разбиение при проектировании таблицы orders?

**Решение**

Преподаватель на лекции сказал, что в задании нужо делать не шардирование а партиционирование. Не будем перечить воле сенсея..

Для разбиения на две таблицы необходимо выполнить следующие этапы:

- переименовать таблицу
- создать две таблицы, унаследованные от `orders` и подчиняющихся правилам для добавления записей в них
- перенести данные из старой таблицы в новые
- удалить старую таблицу

```sql
begin;

alter table orders rename to orders_backup;

create table orders (
like orders_backup
including defaults
including constraints
including indexes
);

create table orders_1 ( check (price > 499) ) inherits (orders);
create table orders_2 ( check (price <= 499) ) inherits (orders);

alter table orders_1 owner to postgres;
alter table orders_2 owner to postgres;

create rule price_over_499 as on
insert to orders where (price > 499)
do instead
insert into orders_1 values(NEW.*);

create rule price_less_499 as on
insert to orders where (price <= 499)
do instead
insert into orders_2 values(NEW.*);

insert into orders (id, title, price)
select id, title, price from orders_backup;

alter table orders_backup alter id drop default;

alter sequence orders_id_seq owned by orders.id;

drop table orders_backup;

end;
```

В итоге получил две таблички с данными.

**Можно ли было изначально исключить "ручное" разбиение при проектировании таблицы orders** Думаю да, во время создания таблицы `orders`.

## Задача 4

Используя утилиту `pg_dump` создайте бекап БД `test_database`.

Как бы вы доработали бэкап-файл, чтобы добавить уникальность значения столбца `title` для таблиц `test_database`?

**Решение**

В домашнем задании `06-db-02-sql` уже делали что-то подобное.

```bash
root@326240e17719:/# pg_dump -U postgres test_database > /backup/test_database.sql
```

**Как бы вы доработали бэкап-файл, чтобы добавить уникальность значения столбца `title` для таблиц `test_database`?**

Как минимум два варианта. Первый -- определение ограничения уникальности для столбца:

```sql
CREATE TABLE public.orders (
    id integer NOT NULL,
    title character varying(80) NOT NULL UNIQUE,
    price integer DEFAULT 0
);
```

Второй -- создать ограничение для таблицы:

```sql
CREATE TABLE public.orders (
    id integer NOT NULL,
    title character varying(80) NOT NULL,
    price integer DEFAULT 0,
    UNIQUE(title)
);
```
