import os
import sys

# в условии не сказано, как коварное начальство будет передавать входной параметр..

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
