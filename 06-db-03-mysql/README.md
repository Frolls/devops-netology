# Решение домашнего задания к занятию "6.3. MySQL"

## Задача 1

Используя docker поднимите инстанс MySQL (версию 8). Данные БД сохраните в volume.

Изучите [бэкап БД](https://github.com/netology-code/virt-homeworks/tree/master/06-db-03-mysql/test_data) и
восстановитесь из него.

Перейдите в управляющую консоль `mysql` внутри контейнера.

Используя команду `\h` получите список управляющих команд.

Найдите команду для выдачи статуса БД и **приведите в ответе** из ее вывода версию сервера БД.

Подключитесь к восстановленной БД и получите список таблиц из этой БД.

**Приведите в ответе** количество записей с `price` > 300.

В следующих заданиях мы будем продолжать работу с данным контейнером.

**Решение**

Docker-compose манифест [тут](/06-db-03-mysql/task1/stack.yml)

`test_dump.sql` заранее заботливо положил в директорию `test_data`, которую забиндил в манифесте.

Далее:

- выполняем команду `docker-compose -f stack.yml up`;
- ждем, когда всё создастся;
- заходим в контейнер командой `docker exec -it mysql_container bash`.

Проверяем, что все хорошо:

```bash
root@ead998539b06:/# ls /backup/
test_dump.sql
```

Пока что все идёт по плану )

При помощи `cat` посмотрел бэкап. Создается и заполняется табличка `orders`. Буквально пять записей.

Что ж, пора восстановиться из бэкапа.. Для этого:

- выполним команду `mysql -u root -p` и введем пароль;
- в шелле выполним создание БД, ведь для восстановления необходимо сначала ее создать:

```sql
mysql> CREATE DATABASE test_db;
Query OK, 1 row affected (0.01 sec)
```

- выходим из шелла и восстанавливаем базу из бэкапа: `mysql -u root -p test_db < /backup/test_dump.sql`
- снова заходим в шелл и убеждаемся, что все на месте:

```
mysql> SHOW DATABASES;
+--------------------+
| Database           |
+--------------------+
| information_schema |
| mysql              |
| performance_schema |
| sys                |
| test_db            |
+--------------------+
5 rows in set (0.00 sec)
```

Команда для вывода статуса `\s` подсказала версию сервера БД: `Server version: 8.0.29 MySQL Community Server - GPL`

Посмотрим список таблиц восстановленной БД:

```
mysql> USE test_db;
Reading table information for completion of table and column names
You can turn off this feature to get a quicker startup with -A

Database changed

mysql> SHOW TABLES;
+-------------------+
| Tables_in_test_db |
+-------------------+
| orders            |
+-------------------+
1 row in set (0.00 sec)
```

Количество записей с `price` > 300:

```
mysql> SELECT COUNT(*) FROM orders WHERE price > 300;
+----------+
| COUNT(*) |
+----------+
|        1 |
+----------+
1 row in set (0.00 sec)
```

Такая запись всего одна.

## Задача 2

Создайте пользователя test в БД c паролем test-pass, используя:

- плагин авторизации mysql_native_password
- срок истечения пароля - 180 дней
- количество попыток авторизации - 3
- максимальное количество запросов в час - 100
- аттрибуты пользователя:
  - Фамилия "Pretty"
  - Имя "James"

Предоставьте привелегии пользователю `test` на операции SELECT базы `test_db`.

Используя таблицу INFORMATION_SCHEMA.USER_ATTRIBUTES получите данные по пользователю `test` и
**приведите в ответе к задаче**.

**Решение**

Создание пользователя:

```sql
CREATE USER 'test'@'localhost' IDENTIFIED WITH mysql_native_password BY 'test-pass'
    WITH MAX_QUERIES_PER_HOUR 100
    PASSWORD EXPIRE INTERVAL 180 DAY
    FAILED_LOGIN_ATTEMPTS 3
    ATTRIBUTE '{"fname": "James", "lname": "Pretty"}';
```

Предоставление привилегий:

```sql
GRANT SELECT ON test_db.* TO 'test'@'localhost';
```

Данные по пользователю `test`:

```sql
mysql> SELECT * FROM INFORMATION_SCHEMA.USER_ATTRIBUTES WHERE USER='test' AND HOST='localhost';
+------+-----------+---------------------------------------+
| USER | HOST      | ATTRIBUTE                             |
+------+-----------+---------------------------------------+
| test | localhost | {"fname": "James", "lname": "Pretty"} |
+------+-----------+---------------------------------------+
1 row in set (0.00 sec)
```

## Задача 3

Установите профилирование `SET profiling = 1`.
Изучите вывод профилирования команд `SHOW PROFILES;`.

Исследуйте, какой `engine` используется в таблице БД `test_db` и **приведите в ответе**.

Измените `engine` и **приведите время выполнения и запрос на изменения из профайлера в ответе**:

- на `MyISAM`
- на `InnoDB`

**Решение**

Посмотрим, какой движок используется:

```sql
mysql> SHOW TABLE STATUS\G;
*************************** 1. row ***************************
           Name: orders
         Engine: InnoDB
        Version: 10
     Row_format: Dynamic
           Rows: 5
 Avg_row_length: 3276
    Data_length: 16384
Max_data_length: 0
   Index_length: 0
      Data_free: 0
 Auto_increment: 6
    Create_time: 2022-06-09 15:52:26
    Update_time: NULL
     Check_time: NULL
      Collation: utf8mb4_0900_ai_ci
       Checksum: NULL
 Create_options:
        Comment:
1 row in set (0.01 sec)
```

Используется `InnoDB`.

Изменим движок на `MyISAM`:

```sql
mysql> ALTER TABLE orders ENGINE = MyISAM;
Query OK, 5 rows affected (0.07 sec)
Records: 5  Duplicates: 0  Warnings: 0
```

Вот что показывает профайлер:

```sql
mysql> SHOW PROFILE FOR QUERY 9;
+--------------------------------+----------+
| Status                         | Duration |
+--------------------------------+----------+
| starting                       | 0.000123 |
| Executing hook on transaction  | 0.000013 |
| starting                       | 0.000035 |
| checking permissions           | 0.000013 |
| checking permissions           | 0.000012 |
| init                           | 0.000021 |
| Opening tables                 | 0.000529 |
| setup                          | 0.000251 |
| creating table                 | 0.001342 |
| waiting for handler commit     | 0.000021 |
| waiting for handler commit     | 0.007581 |
| After create                   | 0.000740 |
| System lock                    | 0.000022 |
| copy to tmp table              | 0.000206 |
| waiting for handler commit     | 0.000023 |
| waiting for handler commit     | 0.000029 |
| waiting for handler commit     | 0.000062 |
| rename result table            | 0.000121 |
| waiting for handler commit     | 0.021195 |
| waiting for handler commit     | 0.000027 |
| waiting for handler commit     | 0.006564 |
| waiting for handler commit     | 0.000021 |
| waiting for handler commit     | 0.019825 |
| waiting for handler commit     | 0.000022 |
| waiting for handler commit     | 0.004278 |
| end                            | 0.009539 |
| query end                      | 0.002872 |
| closing tables                 | 0.000020 |
```

Вернём как было:

```sql
mysql> ALTER TABLE orders ENGINE = InnoDB;
Query OK, 5 rows affected (0.11 sec)
Records: 5  Duplicates: 0  Warnings: 0
```

Выхлоп профайлера:

```sql
mysql> SHOW PROFILES;
+----------+------------+------------------------------------+
| Query_ID | Duration   | Query                              |
+----------+------------+------------------------------------+
|      ... |        ... |                                ... |
|        9 | 0.07563475 | ALTER TABLE orders ENGINE = MyISAM |
|       10 | 0.10772075 | ALTER TABLE orders ENGINE = InnoDB |
+----------+------------+------------------------------------+
10 rows in set, 1 warning (0.00 sec)

mysql> SHOW PROFILE FOR QUERY 10;
+--------------------------------+----------+
| Status                         | Duration |
+--------------------------------+----------+
| starting                       | 0.000116 |
| Executing hook on transaction  | 0.000012 |
| starting                       | 0.000034 |
| checking permissions           | 0.000013 |
| checking permissions           | 0.000013 |
| init                           | 0.000022 |
| Opening tables                 | 0.000349 |
| setup                          | 0.000099 |
| creating table                 | 0.000179 |
| After create                   | 0.055841 |
| System lock                    | 0.000030 |
| copy to tmp table              | 0.000169 |
| rename result table            | 0.001825 |
| waiting for handler commit     | 0.000025 |
| waiting for handler commit     | 0.007575 |
| waiting for handler commit     | 0.000021 |
| waiting for handler commit     | 0.025216 |
| waiting for handler commit     | 0.000023 |
| waiting for handler commit     | 0.007319 |
| waiting for handler commit     | 0.000023 |
| waiting for handler commit     | 0.004938 |
| end                            | 0.000878 |
| query end                      | 0.002853 |
| closing tables                 | 0.000020 |
| waiting for handler commit     | 0.000046 |
| freeing items                  | 0.000039 |
| cleaning up                    | 0.000045 |
+--------------------------------+----------+
27 rows in set, 1 warning (0.00 sec)
```

## Задача 4

Изучите файл `my.cnf` в директории /etc/mysql.

Измените его согласно ТЗ (движок InnoDB):

- Скорость IO важнее сохранности данных
- Нужна компрессия таблиц для экономии места на диске
- Размер буффера с незакомиченными транзакциями 1 Мб
- Буффер кеширования 30% от ОЗУ
- Размер файла логов операций 100 Мб

Приведите в ответе измененный файл `my.cnf`.

**Решение**

- **Скорость IO важнее сохранности данных**: `innodb_flush_log_at_trx_commit = 2`
- **Нужна компрессия таблиц для экономии места на диске**: `innodb_file_per_table = 1`. Могу ошибаться, но с какой-то версии MySQL этот параметр включен по умолчанию.
- **Размер буффера с незакомиченными транзакциями 1 Мб**: `innodb_log_buffer_size = 1M`
- **Буффер кеширования 30% от ОЗУ**: `innodb_buffer_pool_size = 8192M`
- **Размер файла логов операций 100 Мб**: `innodb_log_file_size = 100M`. Следует учесть, что файлов два и их размер одинаковый. Значением параметра задается размер одного файла.

Измененный файл:

```ini
# Copyright (c) 2017, Oracle and/or its affiliates. All rights reserved.
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; version 2 of the License.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301 USA

#
# The MySQL  Server configuration file.
#
# For explanations see
# http://dev.mysql.com/doc/mysql/en/server-system-variables.html

[mysqld]
pid-file        = /var/run/mysqld/mysqld.pid
socket          = /var/run/mysqld/mysqld.sock
datadir         = /var/lib/mysql
secure-file-priv= NULL

innodb_flush_log_at_trx_commit = 2
innodb_file_per_table = 1
innodb_log_buffer_size = 1M
innodb_buffer_pool_size = 8192M
innodb_log_file_size = 100M

# Custom config should go here
!includedir /etc/mysql/conf.d/
```
