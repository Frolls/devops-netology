## Описание Playbook`a

Краткое описание происходящего

### Что делает playbook

На хостах, описанных в файле реестра [prod.yml](inventory/prod.yml), playbook установит:
- jdk -- на всех хостах
- elasticsearch -- на хостах, входящих в группу `elastic`
- kibana -- на хостах, входящих в группу `kibana`

Необходимо заранее скачать архив дистрибутива JDK в формате `.tar.gz` в папку `playbook/files`.

Elasticsearch и Kibana скачаются при запуске playbook.

### Какие у него есть параметры 

Для playbook возможно пригодятся следующие параметры:

- имена docker-контейнеров в файле реестра [prod.yml](inventory/prod.yml)
- версия JDK в [group_vars/all](group_vars/all/vars.yml)
- версия Elasticsearch в [group_vars/elasticsearch](group_vars/elasticsearch/vars.yml)
- версия Kibana из [group_vars/kibana](group_vars/kibana/vars.yml)

### Какие у него есть теги

- `java`
- `elastic`
- `kibana`