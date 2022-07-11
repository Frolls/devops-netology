# Решение домашнего задания к занятию "6.5. Elasticsearch"

## Задача 1

В этом задании вы потренируетесь в:

- установке elasticsearch
- первоначальном конфигурировании elastcisearch
- запуске elasticsearch в docker

Используя докер образ [centos:7](https://hub.docker.com/_/centos) как базовый и
[документацию по установке и запуску Elastcisearch](https://www.elastic.co/guide/en/elasticsearch/reference/current/targz.html):

- составьте Dockerfile-манифест для elasticsearch
- соберите docker-образ и сделайте `push` в ваш docker.io репозиторий
- запустите контейнер из получившегося образа и выполните запрос пути `/` c хост-машины

Требования к `elasticsearch.yml`:

- данные `path` должны сохраняться в `/var/lib`
- имя ноды должно быть `netology_test`

В ответе приведите:

- текст Dockerfile манифеста
- ссылку на образ в репозитории dockerhub
- ответ `elasticsearch` на запрос пути `/` в json виде

Подсказки:

- возможно вам понадобится установка пакета perl-Digest-SHA для корректной работы пакета shasum
- при сетевых проблемах внимательно изучите кластерные и сетевые настройки в elasticsearch.yml
- при некоторых проблемах вам поможет docker директива ulimit
- elasticsearch в логах обычно описывает проблему и пути ее решения

Далее мы будем работать с данным экземпляром elasticsearch.

**Решение**

- [текст Dockerfile манифеста](task1/Dockerfile)
- [ссылка на образ в репозитории dockerhub](https://hub.docker.com/repository/docker/frolls/centos_elasticsearch)
- ответ `elasticsearch` на запрос пути `/` в json виде:

```json
{
  "name": "netology_test",
  "cluster_name": "mylittle-cluster",
  "cluster_uuid": "uHGbSS0GSaa5Wzmlj_nagg",
  "version": {
    "number": "7.17.5",
    "build_flavor": "default",
    "build_type": "tar",
    "build_hash": "8d61b4f7ddf931f219e3745f295ed2bbc50c8e84",
    "build_date": "2022-06-23T21:57:28.736740635Z",
    "build_snapshot": false,
    "lucene_version": "8.11.1",
    "minimum_wire_compatibility_version": "6.8.0",
    "minimum_index_compatibility_version": "6.0.0-beta1"
  },
  "tagline": "You Know, for Search"
}
```

## Задача 2

В этом задании вы научитесь:

- создавать и удалять индексы
- изучать состояние кластера
- обосновывать причину деградации доступности данных

Ознакомтесь с [документацией](https://www.elastic.co/guide/en/elasticsearch/reference/current/indices-create-index.html)
и добавьте в `elasticsearch` 3 индекса, в соответствии со таблицей:

| Имя   | Количество реплик | Количество шард |
| ----- | ----------------- | --------------- |
| ind-1 | 0                 | 1               |
| ind-2 | 1                 | 2               |
| ind-3 | 2                 | 4               |

Получите список индексов и их статусов, используя API и **приведите в ответе** на задание.

Получите состояние кластера `elasticsearch`, используя API.

Как вы думаете, почему часть индексов и кластер находится в состоянии yellow?

Удалите все индексы.

**Важно**

При проектировании кластера elasticsearch нужно корректно рассчитывать количество реплик и шард,
иначе возможна потеря данных индексов, вплоть до полной, при деградации системы.

**Решение**

**Получите список индексов и их статусов, используя API:**

```
curl -X GET "localhost:9200/_cat/indices/ind-*?v=true&s=index&pretty"

health status index uuid                   pri rep docs.count docs.deleted store.size pri.store.size
green  open   ind-1 wOlyL33wQWe01AZKXmtqcw   1   0          0            0       226b           226b
yellow open   ind-2 j1JabVF4RZefJRUalMYbtw   2   1          0            0       452b           452b
yellow open   ind-3 xq3h0AjDSoGf1-Vdtlx7Ng   4   2          0            0       904b           904b
```

**Получите состояние кластера `elasticsearch`, используя API:**

```
curl -X GET "localhost:9200/_cluster/health?pretty"
{
  "cluster_name" : "mylittle-cluster",
  "status" : "yellow",
  "timed_out" : false,
  "number_of_nodes" : 1,
  "number_of_data_nodes" : 1,
  "active_primary_shards" : 10,
  "active_shards" : 10,
  "relocating_shards" : 0,
  "initializing_shards" : 0,
  "unassigned_shards" : 10,
  "delayed_unassigned_shards" : 0,
  "number_of_pending_tasks" : 0,
  "number_of_in_flight_fetch" : 0,
  "task_max_waiting_in_queue_millis" : 0,
  "active_shards_percent_as_number" : 50.0
}
```

**Как вы думаете, почему часть индексов и кластер находится в состоянии yellow?**

Думаю, это происходит из-за того, что для одной из шард не назначена реплика.
Если один из узлов кластера выйдет из строя, некоторые данные могут быть недоступны, пока этот узел не будет восстановлен.

**Upd:** 

*Замечание:* Не могли бы вы еще подумать над вопросом, почему кластер находится в состоянии yellow? 

Особенно в аспекте состояния кластера и его нод, опираясь на понятие что есть вообще кластер 

*Ответ:* потомучто кластер состоит из одной ноды ) Некуда реплицировать

**Удалите все индексы**

Готово!

```
curl -X GET "localhost:9200/_cat/indices/*?v=true&s=index&pretty"

health status index            uuid                   pri rep docs.count docs.deleted store.size pri.store.size
green  open   .geoip_databases g6lmPcJjRNCpj4aGgDXuIA   1   0         40            0       38mb           38mb
```

## Задача 3

В данном задании вы научитесь:

- создавать бэкапы данных
- восстанавливать индексы из бэкапов

Создайте директорию `{путь до корневой директории с elasticsearch в образе}/snapshots`.

Используя API [зарегистрируйте](https://www.elastic.co/guide/en/elasticsearch/reference/current/snapshots-register-repository.html#snapshots-register-repository)
данную директорию как `snapshot repository` c именем `netology_backup`.

**Приведите в ответе** запрос API и результат вызова API для создания репозитория.

Создайте индекс `test` с 0 реплик и 1 шардом и **приведите в ответе** список индексов.

[Создайте `snapshot`](https://www.elastic.co/guide/en/elasticsearch/reference/current/snapshots-take-snapshot.html)
состояния кластера `elasticsearch`.

**Приведите в ответе** список файлов в директории со `snapshot`ами.

Удалите индекс `test` и создайте индекс `test-2`. **Приведите в ответе** список индексов.

[Восстановите](https://www.elastic.co/guide/en/elasticsearch/reference/current/snapshots-restore-snapshot.html) состояние
кластера `elasticsearch` из `snapshot`, созданного ранее.

**Приведите в ответе** запрос к API восстановления и итоговый список индексов.

Подсказки:

- возможно вам понадобится доработать `elasticsearch.yml` в части директивы `path.repo` и перезапустить `elasticsearch`

**Решение**

Создайте директорию `{путь до корневой директории с elasticsearch в образе}/snapshots`.

Используя API зарегистрируйте данную директорию как `snapshot repository` c именем `netology_backup`.

**Приведите в ответе** запрос API и результат вызова API для создания репозитория:

```
curl -X PUT "localhost:9200/_snapshot/netology_backup?pretty" -H 'Content-Type: application/json' -d'
{
  "type": "fs",
  "settings": {
    "location": "/var/lib/elasticsearch/snapshots"
  }
}
'

{
  "acknowledged" : true
}
```

Создайте индекс `test` с 0 реплик и 1 шардом и **приведите в ответе** список индексов:

```
curl -X GET "localhost:9200/_cat/indices/*?v=true&s=index&pretty"
health status index            uuid                   pri rep docs.count docs.deleted store.size pri.store.size
green  open   .geoip_databases MpOy5_OcTdeBVDeOla7vng   1   0         40            0       38mb           38mb
green  open   test             kKP29-KVRYugSL7fY_q7aA   1   0          0            0       226b           226b
```

Создайте `snapshot` состояния кластера `elasticsearch`.

**Приведите в ответе** список файлов в директории со `snapshot`ами:

```bash
[elasticsearch@f3bb3cbd4bdd snapshots]$ ls -lah
total 60K
drwxr-xr-x 3 elasticsearch elasticsearch 4.0K Jul  5 15:58 .
drwxr-xr-x 1 elasticsearch elasticsearch 4.0K Jul  5 15:49 ..
-rw-r--r-- 1 elasticsearch elasticsearch 1.5K Jul  5 15:58 index-0
-rw-r--r-- 1 elasticsearch elasticsearch    8 Jul  5 15:58 index.latest
drwxr-xr-x 6 elasticsearch elasticsearch 4.0K Jul  5 15:58 indices
-rw-r--r-- 1 elasticsearch elasticsearch  29K Jul  5 15:58 meta-Y3ZDEG8MQfCwvqxV5Q1WGQ.dat
-rw-r--r-- 1 elasticsearch elasticsearch  721 Jul  5 15:58 snap-Y3ZDEG8MQfCwvqxV5Q1WGQ.dat
```

Удалите индекс `test` и создайте индекс `test-2`. **Приведите в ответе** список индексов:

```
curl -X GET "localhost:9200/_cat/indices/*?v=true&s=index&pretty"
health status index            uuid                   pri rep docs.count docs.deleted store.size pri.store.size
green  open   .geoip_databases MpOy5_OcTdeBVDeOla7vng   1   0         40            0       38mb           38mb
green  open   test-2           -9otOey9TTm37abP2eW7Gw   1   0          0            0       226b           226b
```

Восстановите состояние кластера `elasticsearch` из `snapshot`, созданного ранее.

**Приведите в ответе** запрос к API восстановления и итоговый список индексов.

Убедимся, что `snapshot` на месте:

```
curl -X GET "localhost:9200/_snapshot/netology_backup/*?pretty"

{
  "snapshots" : [
    {
      "snapshot" : "my_snapshot_2022.07.05",
      "uuid" : "Y3ZDEG8MQfCwvqxV5Q1WGQ",
      "repository" : "netology_backup",
      "version_id" : 7170599,
      "version" : "7.17.5",
      "indices" : [
        ".ds-.logs-deprecation.elasticsearch-default-2022.07.05-000001",
        "test",
        ".geoip_databases",
        ".ds-ilm-history-5-2022.07.05-000001"
      ],
      "data_streams" : [
        "ilm-history-5",
        ".logs-deprecation.elasticsearch-default"
      ],
      "include_global_state" : true,
      "state" : "SUCCESS",
      "start_time" : "2022-07-05T15:58:01.424Z",
      "start_time_in_millis" : 1657036681424,
      "end_time" : "2022-07-05T15:58:02.625Z",
      "end_time_in_millis" : 1657036682625,
      "duration_in_millis" : 1201,
      "failures" : [ ],
      "shards" : {
        "total" : 4,
        "failed" : 0,
        "successful" : 4
      },
      "feature_states" : [
        {
          "feature_name" : "geoip",
          "indices" : [
            ".geoip_databases"
          ]
        }
      ]
    }
  ],
  "total" : 1,
  "remaining" : 0
}
```

Супер!

Теперь можно восстановить:

```
curl -X GET "localhost:9200/_cat/indices/*?v=true&s=index&pretty"
health status index            uuid                   pri rep docs.count docs.deleted store.size pri.store.size
green  open   .geoip_databases MpOy5_OcTdeBVDeOla7vng   1   0         40            0       38mb           38mb
green  open   test             2MpU_1_5Slqav_HivHX7sQ   1   0          0            0       226b           226b
```
