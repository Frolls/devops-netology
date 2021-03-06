#### Решение домашнего задания к занятию "4.1. Командная оболочка Bash: Практические навыки"

## Обязательная задача 1

Есть скрипт:
```bash
a=1
b=2
c=a+b
d=$a+$b
e=$(($a+$b))
```

Какие значения переменным c,d,e будут присвоены? Почему?

| Переменная  | Значение | Обоснование                                                                             |
| ------------- |----------|-----------------------------------------------------------------------------------------|
| `c`  | `a+b`    | отсутствует символ `$` - подстановка значения переменной                                |
| `d`  | `1+2`    | конкантекация значений переменных `a` и `b`                                             |
| `e`  | `3`      | вычисляется челочисленное выражение, заключенное между двойными круглыми скобками (( )) |
                      
Для вычисления в круглых скобках можно использовать переменные без `$` перед ними.

## Обязательная задача 2
На нашем локальном сервере упал сервис и мы написали скрипт, который постоянно проверяет его доступность, записывая 
дату проверок до тех пор, пока сервис не станет доступным (после чего скрипт должен завершиться). В скрипте допущена 
ошибка, из-за которой выполнение не может завершиться, при этом место на Жёстком Диске постоянно уменьшается. Что 
необходимо сделать, чтобы его исправить:
```bash
while ((1==1)
do
	curl https://localhost:4757
	if (($? != 0))
	then
		date >> curl.log
	fi
done
```

Не хватало закрывающейся скобки в условии для `while` и ветки `else` в случае, когда `curl` вернет положительный 
результат. Добавил код возврата и чистку файла (на всякий случай).

### Ваш скрипт:
```bash

while ((1==1)); do
  curl -s https://localhost:4757
  if (($? != 0)); then
    date >> curl.log
  else
    echo "Server up! Clean log.."
    truncate -s 0 curl.log
    exit 0
  fi
done
```

## Обязательная задача 3
Необходимо написать скрипт, который проверяет доступность трёх IP: `192.168.0.1`, `173.194.222.113`, `87.250.250.242` 
по `80` порту и записывает результат в файл `log`. Проверять доступность необходимо пять раз для каждого узла.

### Ваш скрипт:
```bash

hosts=("192.168.0.1" "173.194.222.113" "87.250.250.242")
port="80"

echo "~~ $(date) ~~" > log

for host in "${hosts[@]}"; do
  echo "scanning $host:" >> log
    for (( i=1; i <= 5; i++ )); do
      nc -zvw3 "$host" $port
      echo "$i: $?" >> log
    done
done

exit 0
```

Можно было использовать `nmap` или `telnet` вместо `nc`

## Обязательная задача 4
Необходимо дописать скрипт из предыдущего задания так, чтобы он выполнялся до тех пор, пока один из узлов не 
окажется недоступным. Если любой из узлов недоступен - IP этого узла пишется в файл error, скрипт прерывается.

### Ваш скрипт:
```bash
hosts=("192.168.0.1" "173.194.222.113" "87.250.250.242")
port="80"

echo "~~ $(date) ~~" > log

while ((1==1)); do
  for host in "${hosts[@]}"; do
    echo "scanning $host:" >> log
      for (( i=1; i <= 5; i++ )); do
        nc -zvw3 "$host" $port
        status=$?
        echo "$i: $status" >> log
        if ((status != 0)); then
          echo "$host" >> error
          echo "Host $host not available. Exiting.."
          exit 1
        fi
      done
  done
done

exit 0
```

## Дополнительное задание (со звездочкой*) - необязательно к выполнению

Мы хотим, чтобы у нас были красивые сообщения для коммитов в репозиторий. Для этого нужно написать локальный хук 
для git, который будет проверять, что сообщение в коммите содержит код текущего задания в квадратных скобках и 
количество символов в сообщении не превышает 30. Пример сообщения: \[04-script-01-bash\] сломал хук.


Вот так сразу ничего хорошего в голову не пришло, кроме как грепнуть сообщение..

Кароч, нужно создать файл в `/.git/hooks`. Назовем его `commit-msg` и чмокнем, чтобы был исполняемым. Там обычно лежит
типа `commit-msg.sample`, можно взять его за основу)

### Ваш скрипт:
```bash

# Шаблон для grep:
string_validator="\[[[:digit:]]*-[[:alpha:]]*-[[:digit:]]*-[[:alpha:]]*\] *"
# Максимальное количество символов
max_symbol_count=30

commit_format_validate(){
  tmp="$(grep -c "$string_validator" "$*")"
  if [[ "$tmp" -eq "0" ]]; then
    echo "Format error"
    return 1
  else
    return 0
  fi
}

commit_symbol_count_validate(){
  string_symbol_count="$(echo "$*" | wc -m)"
  if [[ "$string_symbol_count" -gt "$max_symbol_count" ]]; then
    echo "Long message (>30 symbols)"
    return 1
  else
    return 0
  fi
}

echo "Start commit checking.."
echo "Original format are --> $*"

if commit_format_validate "$1"; then
  if commit_symbol_count_validate "$1"; then
    echo "OK. You are beautiful!!"
    exit 0
  else
    exit 1
  fi
  else
    exit 1
fi

exit 0
```

Как-то так, в общих чертах