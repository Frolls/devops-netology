#### Решение домашнего задания к занятию "Использование Python для решения типовых DevOps задач"

1. Есть скрипт:
    ```python
    #!/usr/bin/env python3
    a = 1
    b = '2'
    c = a + b
    ```
* Какое значение будет присвоено переменной c? 

Ответ: никакое)) Словим исключение типа `TypeError`. Python не знает, как сложить целочисленное значение и строку.

* Как получить для переменной c значение 12?

```python
c = str(a) + b  # для строки `12`
c = int(str(a) + b)  # для числа 12
```

* Как получить для переменной c значение 3?

```python
c = a + int(b)  # для числа 3
```

1. Мы устроились на работу в компанию, где раньше уже был DevOps Engineer. Он написал скрипт, позволяющий узнать, какие 
файлы модифицированы в репозитории, относительно локальных изменений. Этим скриптом недовольно начальство, потому что 
в его выводе есть не все изменённые файлы, а также непонятен полный путь к директории, где они находятся. 
Как можно доработать скрипт ниже, чтобы он исполнял требования вашего руководителя?

    ```python
    #!/usr/bin/env python3

    import os

    bash_command = ["cd ~/netology/sysadm-homeworks", "git status"]
    result_os = os.popen(' && '.join(bash_command)).read()
    is_change = False
    for result in result_os.split('\n'):
        if result.find('modified') != -1:
            prepare_result = result.replace('\tmodified:   ', '')
            print(prepare_result)
            break

    ```

Исправленный скрипт:
```python
import os

path = "~/netology/sysadm-homeworks"
full_path = os.path.normpath(os.path.abspath(os.path.expanduser(path)))

print("*" * 8, " Полный путь к папке ", "*" * 8)
print(full_path)

bash_command = [f"cd {full_path}", "git status"]
result_os = os.popen(' && '.join(bash_command)).read()

is_change = False
print("\n", "*" * 7, " Измененные файлы ", "*" * 7)
for result in result_os.split('\n'):
    if result.find('modified') != -1:
        prepare_result = result.replace('\tmodified:   ', '')
        print(prepare_result)
    else:
        if not is_change:
            print("Измененные файлы отсутствуют")
            is_change = True
```

Примечание: скрипт не отслеживает новые, а также удаленные файлы. Скрипт не будет работать в других локалях.

1. Доработать скрипт выше так, чтобы он мог проверять не только локальный репозиторий в текущей директории, а также умел 
воспринимать путь к репозиторию, который мы передаём как входной параметр. Мы точно знаем, что начальство коварное и 
будет проверять работу этого скрипта в директориях, которые не являются локальными репозиториями.

```python
import os
import sys

if len(sys.argv) > 1:
    path = sys.argv[1]
    full_path = os.path.normpath(os.path.abspath(os.path.expanduser(path)))

    if os.path.exists(full_path):
        print("Папка '{}' не существует".format(path))
else:
    tmp = input("Попробуем указать путь к репозиторию? (Y\\N | Д\\н | Q\\q | В\\в)?")
    if tmp in 'Y' 'y' 'Д' 'д':
        path = input("Укажите путь к папке")
    elif tmp in 'N' 'n' 'Н' 'н':
        print("Продолжаю работу в текущей папке")
        path = os.getcwd()
    elif tmp in 'Q' 'q' 'В' 'в':
        print("Выход")
        exit(0)
    else:
        print("\nНе могу распарсить ответ типа '{}'. Продолжаю работу в текущей папке".format(tmp))
        path = os.getcwd()

print("\n", "*" * 7, " Измененные файлы в директории '", path, "'", "*" * 7)

full_path = os.path.normpath(os.path.abspath(os.path.expanduser(path)))

bash_command = [f"cd {full_path}", "git status"]
result_os = os.popen(' && '.join(bash_command)).read()

is_change = False

if result_os == "":
    print("Папка '{}' не содержит репозитория git".format(path))
    exit(128)

for result in result_os:
    if result.find('modified') != -1:
        prepare_result = result.replace('\tmodified:   ', '')
        print(prepare_result)
    else:
        if not is_change:
            print("Измененные файлы отсутствуют")
            is_change = True
```

1. Наша команда разрабатывает несколько веб-сервисов, доступных по http. Мы точно знаем, что на их стенде нет 
никакой балансировки, кластеризации, за DNS прячется конкретный IP сервера, где установлен сервис. Проблема в том, 
что отдел, занимающийся нашей инфраструктурой очень часто меняет нам сервера, поэтому IP меняются примерно раз в 
неделю, при этом сервисы сохраняют за собой DNS имена. Это бы совсем никого не беспокоило, если бы несколько раз 
сервера не уезжали в такой сегмент сети нашей компании, который недоступен для разработчиков. Мы хотим написать 
скрипт, который опрашивает веб-сервисы, получает их IP, выводит информацию в стандартный вывод в виде: 
<URL сервиса> - <его IP>. Также, должна быть реализована возможность проверки текущего IP сервиса c его IP из 
предыдущей проверки. Если проверка будет провалена - оповестить об этом в стандартный вывод сообщением: 
[ERROR] <URL сервиса> IP mismatch: <старый IP> <Новый IP>. Будем считать, что наша разработка реализовала сервисы: 
drive.google.com, mail.google.com, google.com.

Вариант решения:

```python
import socket

hosts = {"drive.google.com": "192.168.0.1",
         "mail.google.com": "172.16.0.1",
         "google.com": "10.0.0.1", }

while True:
    for host in hosts.keys():
        ip = hosts[host]
        new_ip = socket.gethostbyname(host)
        if new_ip != ip:
            print("[ERROR] {} IP mismatch: {} {}".format(host, ip, new_ip))
            hosts[host] = new_ip
        else:
            print("{} - {}".format(host, ip))
```