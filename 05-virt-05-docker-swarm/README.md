# Решение домашнего задания к занятию "5.5. Оркестрация кластером Docker контейнеров на примере Docker Swarm"

## Задача 1

Дайте письменые ответы на следующие вопросы:

- **В чём отличие режимов работы сервисов в Docker Swarm кластере: replication и global?** Режим `replicated` говорит о том, что задачи или контейнеры сервиса расположены на каких-то конкретных нодах кластера. Режим `global` означает, что на каждой ноде кластера существует как минимум один контейнер, который выполняется в рамках этого сервиса.
- **Какой алгоритм выбора лидера используется в Docker Swarm кластере?** Raft
- **Что такое Overlay Network?** Логическая сеть, создаваемая поверх другой сети. Пример: VPN

## Задача 2

Создать ваш первый Docker Swarm кластер в Яндекс.Облаке

Для получения зачета, вам необходимо предоставить скриншот из терминала (консоли), с выводом команды:
```
docker node ls
```

**Результат**

```bash
[root@node01 ~]# docker node ls
ID                            HOSTNAME             STATUS    AVAILABILITY   MANAGER STATUS   ENGINE VERSION
ug2ylrmtrbpxwl5dt9o6ecopl *   node01.netology.yc   Ready     Active         Leader           20.10.16
2gj4ev505d53l70tc91tlbro6     node02.netology.yc   Ready     Active         Reachable        20.10.16
kivvhgboepjnel9srsg7bi6fx     node03.netology.yc   Ready     Active         Reachable        20.10.16
i6ly839xu68wgwyv5jm1lxeee     node04.netology.yc   Ready     Active                          20.10.16
4xxurievj8s44556h05wang9o     node05.netology.yc   Ready     Active                          20.10.16
5wni7f5pqd6tthief2eb5qs5v     node06.netology.yc   Ready     Active                          20.10.16
```

## Задача 3

Создать ваш первый, готовый к боевой эксплуатации, кластер мониторинга, состоящий из стека микросервисов.

Для получения зачета, вам необходимо предоставить скриншот из терминала (консоли), с выводом команды:
```
docker service ls
```

**Результат**

```bash
[root@node01 ~]# docker service ls
ID             NAME                                MODE         REPLICAS   IMAGE                                          PORTS
dpbsrvj7rraw   swarm_monitoring_alertmanager       replicated   1/1        stefanprodan/swarmprom-alertmanager:v0.14.0    
ott11kxuptl2   swarm_monitoring_caddy              replicated   0/1        stefanprodan/caddy:latest                      *:3000->3000/tcp, *:9090->9090/tcp, *:9093-9094->9093-9094/tcp
t37uqc3j6km9   swarm_monitoring_cadvisor           global       6/6        google/cadvisor:latest                         
xsk5otl4eaa5   swarm_monitoring_dockerd-exporter   global       6/6        stefanprodan/caddy:latest                      
cdix1k1wgk0o   swarm_monitoring_grafana            replicated   0/1        stefanprodan/swarmprom-grafana:5.3.4           
4dkgjfwdbcgl   swarm_monitoring_node-exporter      global       5/6        stefanprodan/swarmprom-node-exporter:v0.16.0   
yh2s8wv2amvb   swarm_monitoring_prometheus         replicated   0/1        stefanprodan/swarmprom-prometheus:v2.5.0       
mndlmypwh001   swarm_monitoring_unsee              replicated   1/1        cloudflare/unsee:v0.8.0                        
```

## Задача 4 (*)

Выполнить на лидере Docker Swarm кластера команду (указанную ниже) и дать письменное описание её функционала, что она делает и зачем она нужна:
```
# см.документацию: https://docs.docker.com/engine/swarm/swarm_manager_locking/
docker swarm update --autolock=true
```

**Результат**

```bash
[root@node01 ~]# docker swarm update --autolock=true
Swarm updated.
To unlock a swarm manager after it restarts, run the `docker swarm unlock`
command and provide the following key:

    SWMKEY-1-Eeg4jzijPIYYqL2tDis2nvm/o8wBzlFo7RKKJsQ17Q4

Please remember to store this key in a password manager, since without it you
will not be able to restart the manager.
```

Команда включает функцию автоблокировки и заставит вводить ключ разблокировки после перезапуска менеджеров.

Используется для защиты конфигурации и данных сервиса от злоумышленников, которым стал доступен журнал Raft.