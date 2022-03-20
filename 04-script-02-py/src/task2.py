import os

path = "~/netology/sysadm-homeworks"
full_path = os.path.normpath(os.path.abspath(os.path.expanduser(path)))

print("*" * 8, " Полный путь к папке ", "*" * 8)
print(full_path)

bash_command = [f"cd {full_path}", "git status"]
result_os = os.popen(' && '.join(bash_command)).read()

'''
is_change = False
print("\n", "*"*7, " Новые файлы ", "*"*7)
for result in result_os.split('\n'):
    if result.find('new') != -1:
        prepare_result = result.replace('\tnew:   ', '')
        print(prepare_result)
    else:
        if not is_change:
            print("Новые файлы отсутствуют")
            is_change = True
'''

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
