# Решение домашнего задания к занятию "08.02 Работа с Playbook"

## Подготовка к выполнению

1. Создайте свой собственный (или используйте старый) публичный репозиторий на github с произвольным именем.
2. Скачайте [playbook](./playbook/) из репозитория с домашним заданием и перенесите его в свой репозиторий.
3. Подготовьте хосты в соответствии с группами из предподготовленного playbook.
4. Скачайте дистрибутив [java](https://www.oracle.com/java/technologies/javase-jdk11-downloads.html) и положите его в директорию `playbook/files/`.

**Решение**

_Подготовьте хосты в соответсвии с группами из предподготовленного playbook_ -- запилил [docker-compose манифест](docker/stack.yml) (дико полюбил эту штуку из-за простоты и скорости)

_Скачайте дистрибутив [java](https://www.oracle.com/java/technologies/javase-jdk11-downloads.html) и положите его в директорию `playbook/files/`._ -- сделано!

## Основная часть

1. Приготовьте свой собственный inventory файл `prod.yml`.
2. Допишите playbook: нужно сделать ещё один play, который устанавливает и настраивает kibana.
3. При создании tasks рекомендую использовать модули: `get_url`, `template`, `unarchive`, `file`.
4. Tasks должны: скачать нужной версии дистрибутив, выполнить распаковку в выбранную директорию, сгенерировать конфигурацию с параметрами.
5. Запустите `ansible-lint site.yml` и исправьте ошибки, если они есть.
6. Попробуйте запустить playbook на этом окружении с флагом `--check`.
7. Запустите playbook на `prod.yml` окружении с флагом `--diff`. Убедитесь, что изменения на системе произведены.
8. Повторно запустите playbook с флагом `--diff` и убедитесь, что playbook идемпотентен.
9. Подготовьте README.md файл по своему playbook. В нём должно быть описано: что делает playbook, какие у него есть параметры и теги.
10. Готовый playbook выложите в свой репозиторий, в ответ предоставьте ссылку на него.

**Решение**

1. **Приготовьте свой собственный inventory файл `prod.yml`.**

Подготовил:

```yml
---
elasticsearch:
  hosts:
    container_elasticsearch:
      ansible_connection: docker
kibana:
  hosts:
    container_kibana:
      ansible_connection: docker
```

2. **Допишите playbook: нужно сделать ещё один play, который устанавливает и настраивает kibana.**
3. **При создании tasks рекомендую использовать модули: `get_url`, `template`, `unarchive`, `file`.**
4. **Tasks должны: скачать нужной версии дистрибутив, выполнить распаковку в выбранную директорию, сгенерировать конфигурацию с параметрами.**

Вариант решения:

```yml
- name: Install Kibana
  hosts: kibana
  tasks:
    - name: Upload tar.gz Kibana from remote URL
      get_url:
        url: "https://artifacts.elastic.co/downloads/kibana/kibana-{{ kibana_version }}-linux-x86_64.tar.gz"
        dest: "/tmp/kibana-{{ kibana_version }}-linux-x86_64.tar.gz"
        mode: 0755
        timeout: 60
        force: true
        validate_certs: false
      register: get_kibana
      until: get_kibana is succeeded
      tags: kibana
    - name: Create directrory for Kibana
      file:
        state: directory
        path: "{{ kibana_home }}"
        mode: 0755
      tags: kibana
    - name: Extract Kibana in the installation directory
      unarchive:
        copy: false
        src: "/tmp/kibana-{{ kibana_version }}-linux-x86_64.tar.gz"
        dest: "{{ kibana_home }}"
        extra_opts: [--strip-components=1]
        creates: "{{ kibana_home }}/bin/kibana"
      tags:
        - kibana
    - name: Set environment Kibana
      template:
        src: templates/kib.sh.j2
        dest: /etc/profile.d/kib.sh
        mode: 0755
      tags: kibana
```

5. **Запустите `ansible-lint site.yml` и исправьте ошибки, если они есть.**

```bash
[frolls@mainframe playbook]$ ansible-lint site.yml
WARNING  Overriding detected file kind 'yaml' with 'playbook' for given positional argument: site.yml
WARNING  Listing 27 violation(s) that are fatal
fqcn-builtins: Use FQCN for builtin actions.
site.yml:5 Task/Handler: Set facts for Java 11 vars

fqcn-builtins: Use FQCN for builtin actions.
site.yml:9 Task/Handler: Upload .tar.gz file containing binaries from local storage

risky-file-permissions: File permissions unset or incorrect.
site.yml:9 Task/Handler: Upload .tar.gz file containing binaries from local storage

fqcn-builtins: Use FQCN for builtin actions.
site.yml:16 Task/Handler: Ensure installation dir exists

risky-file-permissions: File permissions unset or incorrect.
site.yml:16 Task/Handler: Ensure installation dir exists

yaml: missing starting space in comment (yaml[comments])
site.yml:17

fqcn-builtins: Use FQCN for builtin actions.
site.yml:22 Task/Handler: Extract java in the installation directory

yaml: missing starting space in comment (yaml[comments])
site.yml:23

fqcn-builtins: Use FQCN for builtin actions.
site.yml:32 Task/Handler: Export environment variables

risky-file-permissions: File permissions unset or incorrect.
site.yml:32 Task/Handler: Export environment variables

yaml: missing starting space in comment (yaml[comments])
site.yml:33

fqcn-builtins: Use FQCN for builtin actions.
site.yml:41 Task/Handler: Upload tar.gz Elasticsearch from remote URL

fqcn-builtins: Use FQCN for builtin actions.
site.yml:52 Task/Handler: Create directrory for Elasticsearch

risky-file-permissions: File permissions unset or incorrect.
site.yml:52 Task/Handler: Create directrory for Elasticsearch

fqcn-builtins: Use FQCN for builtin actions.
site.yml:57 Task/Handler: Extract Elasticsearch in the installation directory

yaml: missing starting space in comment (yaml[comments])
site.yml:58

fqcn-builtins: Use FQCN for builtin actions.
site.yml:67 Task/Handler: Set environment Elastic

risky-file-permissions: File permissions unset or incorrect.
site.yml:67 Task/Handler: Set environment Elastic

yaml: missing starting space in comment (yaml[comments])
site.yml:68

fqcn-builtins: Use FQCN for builtin actions.
site.yml:77 Task/Handler: Upload tar.gz Elasticsearch from remote URL

fqcn-builtins: Use FQCN for builtin actions.
site.yml:88 Task/Handler: Create directrory for Kibana

risky-file-permissions: File permissions unset or incorrect.
site.yml:88 Task/Handler: Create directrory for Kibana

fqcn-builtins: Use FQCN for builtin actions.
site.yml:93 Task/Handler: Extract Kibana in the installation directory

yaml: missing starting space in comment (yaml[comments])
site.yml:94

fqcn-builtins: Use FQCN for builtin actions.
site.yml:103 Task/Handler: Set environment Kibana

risky-file-permissions: File permissions unset or incorrect.
site.yml:103 Task/Handler: Set environment Kibana

yaml: missing starting space in comment (yaml[comments])
site.yml:104

You can skip specific rules or tags by adding them to your configuration file:
# .config/ansible-lint.yml
warn_list:  # or 'skip_list' to silence them completely
  - experimental  # all rules tagged as experimental
  - fqcn-builtins  # Use FQCN for builtin actions.
  - yaml  # Violations reported by yamllint.

Finished with 20 failure(s), 7 warning(s) on 1 files.
```

Ошибки, связанные с написанием комментариев, пробелами, правами доступа к файлам. Но больше всего удивили ошибки `fqcn-builtins: Use FQCN for builtin actions`..

Файл `.config/ansible-lint.yml` не создавал, если правильно понял, то теперь это дефолтное поведение линтера.

Пришлось править.. ) Ах, да, поменял имя плэйбука на `playbook`. 

После этого линтер успокоился окончательно:

```bash
[frolls@mainframe playbook]$ ansible-lint playbook.yml
```

6. **Попробуйте запустить playbook на этом окружении с флагом `--check`**

Пробую, и получаю такой выхлоп:

```bash
[frolls@mainframe playbook]$ ansible-playbook -i inventory/prod.yml playbook.yml --check

PLAY [Install Java] *********************************************************************************************************************************************************************************

TASK [Gathering Facts] ******************************************************************************************************************************************************************************
ok: [container_elasticsearch]
ok: [container_kibana]

TASK [Set facts for Java 11 vars] *******************************************************************************************************************************************************************
ok: [container_elasticsearch]
ok: [container_kibana]

TASK [Upload .tar.gz file containing binaries from local storage] ***********************************************************************************************************************************
changed: [container_elasticsearch]
changed: [container_kibana]

TASK [Ensure installation dir exists] ***************************************************************************************************************************************************************
changed: [container_elasticsearch]
changed: [container_kibana]

TASK [Extract java in the installation directory] ***************************************************************************************************************************************************
An exception occurred during task execution. To see the full traceback, use -vvv. The error was: NoneType: None
fatal: [container_elasticsearch]: FAILED! => {"changed": false, "msg": "dest '/opt/jdk/11.0.16' must be an existing dir"}
An exception occurred during task execution. To see the full traceback, use -vvv. The error was: NoneType: None
fatal: [container_kibana]: FAILED! => {"changed": false, "msg": "dest '/opt/jdk/11.0.16' must be an existing dir"}

PLAY RECAP ******************************************************************************************************************************************************************************************
container_elasticsearch    : ok=4    changed=2    unreachable=0    failed=1    skipped=0    rescued=0    ignored=0   
container_kibana           : ok=4    changed=2    unreachable=0    failed=1    skipped=0    rescued=0    ignored=0   
```

7. **Запустите playbook на `prod.yml` окружении с флагом `--diff`. Убедитесь, что изменения на системе произведены.**

Да, изменения на системе произведены:

```diff
[frolls@mainframe playbook]$ ansible-playbook -i inventory/prod.yml playbook.yml --diff

PLAY [Install Java] *********************************************************************************************************************************************************************************

TASK [Gathering Facts] ******************************************************************************************************************************************************************************
ok: [container_elasticsearch]
ok: [container_kibana]

TASK [Set facts for Java 11 vars] *******************************************************************************************************************************************************************
ok: [container_elasticsearch]
ok: [container_kibana]

TASK [Upload .tar.gz file containing binaries from local storage] ***********************************************************************************************************************************
diff skipped: source file size is greater than 104448
changed: [container_elasticsearch]
diff skipped: source file size is greater than 104448
changed: [container_kibana]

TASK [Ensure installation dir exists] ***************************************************************************************************************************************************************
--- before
+++ after
@@ -1,4 +1,4 @@
 {
     "path": "/opt/jdk/11.0.16",
-    "state": "absent"
+    "state": "directory"
 }

changed: [container_elasticsearch]
--- before
+++ after
@@ -1,4 +1,4 @@
 {
     "path": "/opt/jdk/11.0.16",
-    "state": "absent"
+    "state": "directory"
 }

changed: [container_kibana]

TASK [Extract java in the installation directory] ***************************************************************************************************************************************************
changed: [container_elasticsearch]
changed: [container_kibana]

TASK [Export environment variables] *****************************************************************************************************************************************************************
--- before
+++ after: /home/frolls/.ansible/tmp/ansible-local-42624vq2o8ufy/tmpj3m_auo5/jdk.sh.j2
@@ -0,0 +1,5 @@
+# Warning: This file is Ansible Managed, manual changes will be overwritten on next playbook run.
+#!/usr/bin/env bash
+
+export JAVA_HOME=/opt/jdk/11.0.16
+export PATH=$PATH:$JAVA_HOME/bin
\ No newline at end of file

changed: [container_elasticsearch]
--- before
+++ after: /home/frolls/.ansible/tmp/ansible-local-42624vq2o8ufy/tmpxcjfh_1e/jdk.sh.j2
@@ -0,0 +1,5 @@
+# Warning: This file is Ansible Managed, manual changes will be overwritten on next playbook run.
+#!/usr/bin/env bash
+
+export JAVA_HOME=/opt/jdk/11.0.16
+export PATH=$PATH:$JAVA_HOME/bin
\ No newline at end of file

changed: [container_kibana]

PLAY [Install Elasticsearch] ************************************************************************************************************************************************************************

TASK [Gathering Facts] ******************************************************************************************************************************************************************************
ok: [container_elasticsearch]

TASK [Upload tar.gz Elasticsearch from remote URL] **************************************************************************************************************************************************
changed: [container_elasticsearch]

TASK [Create directrory for Elasticsearch] **********************************************************************************************************************************************************
--- before
+++ after
@@ -1,4 +1,4 @@
 {
     "path": "/opt/elastic/7.10.1",
-    "state": "absent"
+    "state": "directory"
 }

changed: [container_elasticsearch]

TASK [Extract Elasticsearch in the installation directory] ******************************************************************************************************************************************
changed: [container_elasticsearch]

TASK [Set environment Elastic] **********************************************************************************************************************************************************************
--- before
+++ after: /home/frolls/.ansible/tmp/ansible-local-42624vq2o8ufy/tmp8ay6vfax/elk.sh.j2
@@ -0,0 +1,5 @@
+# Warning: This file is Ansible Managed, manual changes will be overwritten on next playbook run.
+#!/usr/bin/env bash
+
+export ES_HOME=/opt/elastic/7.10.1
+export PATH=$PATH:$ES_HOME/bin
\ No newline at end of file

changed: [container_elasticsearch]

PLAY [Install Kibana] *******************************************************************************************************************************************************************************

TASK [Gathering Facts] ******************************************************************************************************************************************************************************
ok: [container_kibana]

TASK [Upload tar.gz Kibana from remote URL] *********************************************************************************************************************************************************
changed: [container_kibana]

TASK [Create directrory for Kibana] *****************************************************************************************************************************************************************
--- before
+++ after
@@ -1,4 +1,4 @@
 {
     "path": "/opt/kibana/8.3.3",
-    "state": "absent"
+    "state": "directory"
 }

changed: [container_kibana]

TASK [Extract Kibana in the installation directory] *************************************************************************************************************************************************
changed: [container_kibana]

TASK [Set environment Kibana] ***********************************************************************************************************************************************************************
--- before
+++ after: /home/frolls/.ansible/tmp/ansible-local-42624vq2o8ufy/tmp_vfqfsvc/kib.sh.j2
@@ -0,0 +1,5 @@
+# Warning: This file is Ansible Managed, manual changes will be overwritten on next playbook run.
+#!/usr/bin/env bash
+
+export KIB_HOME=/opt/kibana/8.3.3
+export PATH=$PATH:$KIB_HOME/bin
\ No newline at end of file

changed: [container_kibana]

PLAY RECAP ******************************************************************************************************************************************************************************************
container_elasticsearch    : ok=11   changed=8    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
container_kibana           : ok=11   changed=8    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
```

8. **Повторно запустите playbook с флагом `--diff` и убедитесь, что playbook идемпотентен.**

Действительно, изменений нет:

```diff
[frolls@mainframe playbook]$ ansible-playbook -i inventory/prod.yml playbook.yml --diff

PLAY [Install Java] *********************************************************************************************************************************************************************************

TASK [Gathering Facts] ******************************************************************************************************************************************************************************
ok: [container_elasticsearch]
ok: [container_kibana]

TASK [Set facts for Java 11 vars] *******************************************************************************************************************************************************************
ok: [container_elasticsearch]
ok: [container_kibana]

TASK [Upload .tar.gz file containing binaries from local storage] ***********************************************************************************************************************************
ok: [container_elasticsearch]
ok: [container_kibana]

TASK [Ensure installation dir exists] ***************************************************************************************************************************************************************
ok: [container_elasticsearch]
ok: [container_kibana]

TASK [Extract java in the installation directory] ***************************************************************************************************************************************************
skipping: [container_kibana]
skipping: [container_elasticsearch]

TASK [Export environment variables] *****************************************************************************************************************************************************************
ok: [container_elasticsearch]
ok: [container_kibana]

PLAY [Install Elasticsearch] ************************************************************************************************************************************************************************

TASK [Gathering Facts] ******************************************************************************************************************************************************************************
ok: [container_elasticsearch]

TASK [Upload tar.gz Elasticsearch from remote URL] **************************************************************************************************************************************************
ok: [container_elasticsearch]

TASK [Create directrory for Elasticsearch] **********************************************************************************************************************************************************
ok: [container_elasticsearch]

TASK [Extract Elasticsearch in the installation directory] ******************************************************************************************************************************************
skipping: [container_elasticsearch]

TASK [Set environment Elastic] **********************************************************************************************************************************************************************
ok: [container_elasticsearch]

PLAY [Install Kibana] *******************************************************************************************************************************************************************************

TASK [Gathering Facts] ******************************************************************************************************************************************************************************
ok: [container_kibana]

TASK [Upload tar.gz Kibana from remote URL] *********************************************************************************************************************************************************
ok: [container_kibana]

TASK [Create directrory for Kibana] *****************************************************************************************************************************************************************
ok: [container_kibana]

TASK [Extract Kibana in the installation directory] *************************************************************************************************************************************************
skipping: [container_kibana]

TASK [Set environment Kibana] ***********************************************************************************************************************************************************************
ok: [container_kibana]

PLAY RECAP ******************************************************************************************************************************************************************************************
container_elasticsearch    : ok=9    changed=0    unreachable=0    failed=0    skipped=2    rescued=0    ignored=0   
container_kibana           : ok=9    changed=0    unreachable=0    failed=0    skipped=2    rescued=0    ignored=0   
```

9. **Подготовьте README.md файл по своему playbook. В нём должно быть описано: что делает playbook, какие у него есть параметры и теги.**

Подготовил и схоронил [здесь](playbook/README.md)