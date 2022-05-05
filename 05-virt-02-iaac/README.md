# Решение домашнего задания к занятию "5.2. Применение принципов IaaC в работе с виртуальными машинами"

## Задача 1

- **Опишите своими словами основные преимущества применения на практике IaaC паттернов.** Основные преимущества применения на практике IaaC паттернов: "из коробки" все преимущества CI/CD, стабильность среды, отслеживание изменений ==> ускорение производства и вывод на рынок качественного продукта
- **Какой из принципов IaaC является основополагающим?** Основополагающий принцип IaaC: идемпотентность. Результат какого-либо действия одинаков, независимо от количества повторений этого действия (при количестве больше нуля)))


## Задача 2

- **Чем Ansible выгодно отличается от других систем управление конфигурациями?** Много модулей, не нужна установка на целевые системы, испоьлзование SSH для доступа
- **Какой, на ваш взгляд, метод работы систем конфигурации более надёжный push или pull?** Думаю, что все-таки push. Я могу полностью контролировать, какую конфигурацию в какой момент времени разворачиваю. Использование pull может быть непредсказуемым, особенно если кто-то внес изменения в конфигурацию и не оповестил должным образом об этом..

## Задача 3

Установить на личный компьютер:

- VirtualBox
- Vagrant
- Ansible

_Приложить вывод команд установленных версий каждой из программ, оформленный в markdown._

**Результат**

```bash
[frolls@mainframe ~]$ virtualbox --help
Oracle VM VirtualBox VM Selector v6.1.32
(C) 2005-2022 Oracle Corporation
All rights reserved.

No special options.

If you are looking for --startvm and related options, you need to use VirtualBoxVM.

[frolls@mainframe ~]$ vagrant -v
Vagrant 2.2.19

[frolls@mainframe ~]$ ansible --version
ansible [core 2.12.4]
  config file = /etc/ansible/ansible.cfg
  configured module search path = ['/home/frolls/.ansible/plugins/modules', '/usr/share/ansible/plugins/modules']
  ansible python module location = /usr/lib/python3.10/site-packages/ansible
  ansible collection location = /home/frolls/.ansible/collections:/usr/share/ansible/collections
  executable location = /usr/bin/ansible
  python version = 3.10.4 (main, Mar 23 2022, 23:05:40) [GCC 11.2.0]
  jinja version = 3.0.3
  libyaml = True
```

## Задача 4 (\*)

Воспроизвести практическую часть лекции самостоятельно.

- Создать виртуальную машину.
- Зайти внутрь ВМ, убедиться, что Docker установлен с помощью команды

```
docker ps
```

**Результат**

Для успешного запуска пришлось создать конфиг в /etc/vbox/networks.conf и добавить туда строку `* 192.168.192.0/24`.

Вот что получилось:

```bash
vagrant@server1:~$ docker ps
CONTAINER ID   IMAGE     COMMAND   CREATED   STATUS    PORTS     NAMES
```
