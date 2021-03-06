### Решение домашнего задания к занятию "3.3. Операционные системы, лекция 1"

1. Какой системный вызов делает команда `cd`? В прошлом ДЗ мы выяснили, что `cd` не является самостоятельной программой, 
это `shell builtin`, поэтому запустить `strace` непосредственно на `cd` не получится. Тем не менее, вы можете запустить 
`strace` на `/bin/bash -c 'cd /tmp'`. В этом случае вы увидите полный список системных вызовов, которые делает сам `bash`
при старте. Вам нужно найти тот единственный, который относится именно к `cd`.

В прошлом ДЗ я ответил на этот вопрос, но шёл другим путём, куря маны. Попробую через `strace`, сохранив вывод в 
файл `log`:
```
vagrant@vagrant:~$ strace -o log /bin/bash -c 'cd /tmp'
```

Грепать не буду, хочу спокойно с чашечкой кофе изучить содержимое файла `log` и ближе к концу файла увидеть тот 
единственный `chdir("/tmp")`  :-)


2. Попробуйте использовать команду `file` на объекты разных типов на файловой системе. Например:
```
vagrant@netology1:~$ file /dev/tty
/dev/tty: character special (5/0)
vagrant@netology1:~$ file /dev/sda
/dev/sda: block special (8/0)
vagrant@netology1:~$ file /bin/bash
/bin/bash: ELF 64-bit LSB shared object, x86-64
```
Используя strace выясните, где находится база данных `file` на основании которой она делает свои догадки.

Выполнил по очереди `strace file /dev/tty`, `strace file /dev/sda`, `strace file /bin/bash`. Везде упоминаются пути 
типа
```
openat(AT_FDCWD, "/etc/magic", O_RDONLY) = 3
fstat(3, {st_mode=S_IFREG|0644, st_size=111, ...}) = 0
read(3, "# Magic local data for file(1) c"..., 4096) = 111
read(3, "", 4096)                       = 0
close(3)                                = 0
openat(AT_FDCWD, "/usr/share/misc/magic.mgc", O_RDONLY) = 3
fstat(3, {st_mode=S_IFREG|0644, st_size=5811536, ...}) = 0
mmap(NULL, 5811536, PROT_READ|PROT_WRITE, MAP_PRIVATE, 3, 0) = 0x7f993a239000
close(3) 
```

Поиск проводится и по другим путям, но там, в основном, ругань, типа нет такого файла или каталога.

Т.о., это `/etc/magic` и `/usr/share/misc/magic.mgc`. 
 
Дальнейший просмотр показал, что на 146% это `/usr/share/misc/magic.mgc`, т.к. `/etc/magic` пуст, в отличие от 
`/usr/share/misc/magic.mgc`.

3. Предположим, приложение пишет лог в текстовый файл. Этот файл оказался удален (deleted в lsof), однако возможности 
сигналом сказать приложению переоткрыть файлы или просто перезапустить приложение – нет. Так как приложение продолжает 
писать в удаленный файл, место на диске постепенно заканчивается. Основываясь на знаниях о перенаправлении потоков 
предложите способ обнуления открытого удаленного файла (чтобы освободить место на файловой системе).

Интересная задачка :-) Рассмотрим ее на примере. Перенаправим вывод команды `yes` в файл и сразу удалим его:
```
vagrant@vagrant:~$ yes 'hello' >> log & rm log
[1] 1059
```

Что это? Подозрительно напоминает PID.. Проверим:
```
vagrant@vagrant:~$ ps
    PID TTY          TIME CMD
    918 pts/0    00:00:00 bash
   1059 pts/0    00:00:37 yes
   1063 pts/0    00:00:00 ps
```

Ну и как теперь с этим жить? Глянем наверняка:
```
vagrant@vagrant:~$ lsof -p 1059
COMMAND  PID    USER   FD   TYPE DEVICE    SIZE/OFF   NODE NAME
yes     1059 vagrant  cwd    DIR  253,0        4096 131074 /home/vagrant
yes     1059 vagrant  rtd    DIR  253,0        4096      2 /
yes     1059 vagrant  txt    REG  253,0       39256 524717 /usr/bin/yes
yes     1059 vagrant  mem    REG  253,0     5699248 535133 /usr/lib/locale/locale-archive
yes     1059 vagrant  mem    REG  253,0     2029224 527432 /usr/lib/x86_64-linux-gnu/libc-2.31.so
yes     1059 vagrant  mem    REG  253,0      191472 527389 /usr/lib/x86_64-linux-gnu/ld-2.31.so
yes     1059 vagrant    0u   CHR  136,0         0t0      3 /dev/pts/0
yes     1059 vagrant    1w   REG  253,0 32709791744 131092 /home/vagrant/log (deleted)
yes     1059 vagrant    2u   CHR  136,0         0t0      3 /dev/pts/0
```

WTF!? Не успел -- процесс съел все место на диске)) Это прекрасно:
```
vagrant@vagrant:~$ yes: standard output: No space left on device
lsof -p 1059
[1]+  Exit 1 
```

Запустил заново, теперь PID == 1183:
```
vagrant@vagrant:~$ yes 'hello' >> log & rm log
[1] 1183
```

Что же нам теперь делать дальше??

Один из способов обновления файла -- команда `truncate`, которая уменьшает или увеличивает размер файла до заданного 
размера:
```
vagrant@vagrant:~$ truncate -s 0 /proc/1183/fd/1
```

Доказательство:
```
vagrant@vagrant:~$ df
Filesystem                 1K-blocks     Used Available Use% Mounted on
udev                          472572        0    472572   0% /dev
tmpfs                         100012      648     99364   1% /run
/dev/mapper/vgvagrant-root  64284292 11726956  49262104  20% /
tmpfs                         500052        0    500052   0% /dev/shm
tmpfs                           5120        0      5120   0% /run/lock
tmpfs                         500052        0    500052   0% /sys/fs/cgroup
/dev/sda1                     523248        4    523244   1% /boot/efi
tmpfs                         100008        0    100008   0% /run/user/1000
```

Можно сделать "в лоб": `echo '' > /proc/1183/fd/1`
Чтобы забыть об этом навсегда, можно на коленке написать скрипт типа
```
while true ; do echo '' > /proc/1183/fd/1 ; done &
```
или
```
while true ; do  truncate -s 0 /proc/1183/fd/1 ; done &
```

Но это не тру-метод. Мы же будем использовать перенаправление потоков.

#### Шаманство с перенаправлением потоков для решения задачи

Установим отладчик `gdb`: 
```
vagrant@vagrant:~$ sudo apt install gdb
```

Подключимся к процессу c PID == 1183 через `gdb`:
```
vagrant@vagrant:~$ sudo gdb -p 1183
GNU gdb (Ubuntu 9.2-0ubuntu1~20.04.1) 9.2
Copyright (C) 2020 Free Software Foundation, Inc.
License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>
This is free software: you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law.
Type "show copying" and "show warranty" for details.
This GDB was configured as "x86_64-linux-gnu".
Type "show configuration" for configuration details.
For bug reporting instructions, please see:
<http://www.gnu.org/software/gdb/bugs/>.
Find the GDB manual and other documentation resources online at:
    <http://www.gnu.org/software/gdb/documentation/>.

For help, type "help".
Type "apropos word" to search for commands related to "word".
Attaching to process 1183
Reading symbols from /usr/bin/yes...
(No debugging symbols found in /usr/bin/yes)
Reading symbols from /lib/x86_64-linux-gnu/libc.so.6...
Reading symbols from /usr/lib/debug//lib/x86_64-linux-gnu/libc-2.31.so...
Reading symbols from /lib64/ld-linux-x86-64.so.2...
(No debugging symbols found in /lib64/ld-linux-x86-64.so.2)
0x00007f6f435f41e7 in __GI___libc_write (fd=1, buf=0x5589ab258440, nbytes=8190)
    at ../sysdeps/unix/sysv/linux/write.c:26
26      ../sysdeps/unix/sysv/linux/write.c: No such file or directory.
```

Продолжим. Смотрим открытые файл дескрипторы:
```
(gdb) shell ls -lah /proc/1183/fd/
total 0
dr-x------ 2 vagrant vagrant  0 Jan 25 13:42 .
dr-xr-xr-x 9 vagrant vagrant  0 Jan 25 13:41 ..
lrwx------ 1 vagrant vagrant 64 Jan 25 13:42 0 -> /dev/pts/0
l-wx------ 1 vagrant vagrant 64 Jan 25 13:44 1 -> '/home/vagrant/log (deleted)'
lrwx------ 1 vagrant vagrant 64 Jan 25 13:44 2 -> /dev/pts/0
```

Запускаем системный вызов из `gdb` для создания файла от имени нашего процесса:
```
(gdb) call open("/dev/null", 00001101, 0666)
$1 = 3
```

Отлично! Мы получили новый файл дескриптор с номером 3 и новый открытый файл `/dev/null`, проверяем:
```
(gdb) shell ls -lah /proc/1183/fd/
total 0
dr-x------ 2 vagrant vagrant  0 Jan 25 13:42 .
dr-xr-xr-x 9 vagrant vagrant  0 Jan 25 13:41 ..
lrwx------ 1 vagrant vagrant 64 Jan 25 13:42 0 -> /dev/pts/0
l-wx------ 1 vagrant vagrant 64 Jan 25 13:44 1 -> '/home/vagrant/log (deleted)'
lrwx------ 1 vagrant vagrant 64 Jan 25 13:44 2 -> /dev/pts/0
l-wx------ 1 vagrant vagrant 64 Jan 25 13:53 3 -> /dev/null
```

Есть такой системный вызов, который меняет файл дескрипторы, называется `dup2`. Попробуем его применить:
```
(gdb) call (int)dup2(3,1)
$1 = 1
```

Смотрим, что из этого получилось:
```
(gdb) shell ls -lah /proc/1183/fd
total 0
dr-x------ 2 vagrant vagrant  0 Jan 25 14:08 .
dr-xr-xr-x 9 vagrant vagrant  0 Jan 25 14:07 ..
lrwx------ 1 vagrant vagrant 64 Jan 25 14:08 0 -> /dev/pts/0
l-wx------ 1 vagrant vagrant 64 Jan 25 14:08 1 -> /dev/null
lrwx------ 1 vagrant vagrant 64 Jan 25 14:08 2 -> /dev/pts/0
l-wx------ 1 vagrant vagrant 64 Jan 25 14:08 3 -> /dev/null
```

Файл дескриптор 3 нам больше не нужен, закроем его и проверим, что получилось:
```
(gdb) call close (3)
$2 = 0
(gdb) shell ls -lah /proc/1183/fd
total 0
dr-x------ 2 vagrant vagrant  0 Jan 25 14:08 .
dr-xr-xr-x 9 vagrant vagrant  0 Jan 25 14:07 ..
lrwx------ 1 vagrant vagrant 64 Jan 25 14:08 0 -> /dev/pts/0
l-wx------ 1 vagrant vagrant 64 Jan 25 14:08 1 -> /dev/null
lrwx------ 1 vagrant vagrant 64 Jan 25 14:08 2 -> /dev/pts/0
```

Супер! Теперь вызодим из `gdb`:
```
(gdb) q
A debugging session is active.

        Inferior 1 [process 1183] will be detached.

Quit anyway? (y or n) y
Detaching from program: /usr/bin/yes, process 1183
[Inferior 1 (process 1183) detached]
```

Проверим, что процесс жив:
```
vagrant@vagrant:~$ ps 1183
    PID TTY      STAT   TIME COMMAND
   1183 pts/0    R      3:56 yes hello

```

А место даже освободилось:
```
vagrant@vagrant:~$ df
Filesystem                 1K-blocks    Used Available Use% Mounted on
udev                          472572       0    472572   0% /dev
tmpfs                         100012     656     99356   1% /run
/dev/mapper/vgvagrant-root  64284292 2352316  58636744   4% /
tmpfs                         500052       0    500052   0% /dev/shm
tmpfs                           5120       0      5120   0% /run/lock
tmpfs                         500052       0    500052   0% /sys/fs/cgroup
/dev/sda1                     523248       4    523244   1% /boot/efi
tmpfs                         100008       0    100008   0% /run/user/1000
```

5. Занимают ли зомби-процессы какие-то ресурсы в ОС (CPU, RAM, IO)?

Zombie-процессы освобождают свои ресурсы, не занимая память. Они всего лишь занимают место в таблице процессов, что
потенциально может привести к невозможности запустить новые процессы. Вроде как-то так.

5. В `iovisor` BCC есть утилита `opensnoop`:
```
root@vagrant:~# dpkg -L bpfcc-tools | grep sbin/opensnoop
/usr/sbin/opensnoop-bpfcc
```

На какие файлы вы увидели вызовы группы open за первую секунду работы утилиты? Воспользуйтесь пакетом bpfcc-tools для 
Ubuntu 20.04. Дополнительные сведения по установке.

Выполнил `sudo apt-get install bpfcc-tools linux-headers-$(uname -r)`, установил пакет `bcc-tools`.

Далее запустил:
```
vagrant@vagrant:~$ dpkg -L bpfcc-tools | grep sbin/opensnoop
/usr/sbin/opensnoop-bpfcc
```

Что такое `/usr/sbin/opensnoop-bpfcc`? Предлагаю выполнить!
```
vagrant@vagrant:~$ /usr/sbin/opensnoop-bpfcc 
bpf: Failed to load program: Operation not permitted

Traceback (most recent call last):
  File "/usr/sbin/opensnoop-bpfcc", line 181, in <module>
    b.attach_kprobe(event="do_sys_open", fn_name="trace_entry")
  File "/usr/lib/python3/dist-packages/bcc/__init__.py", line 654, in attach_kprobe
    fn = self.load_func(fn_name, BPF.KPROBE)
  File "/usr/lib/python3/dist-packages/bcc/__init__.py", line 391, in load_func
    raise Exception("Need super-user privileges to run")
Exception: Need super-user privileges to run
```

Ой, нужно sudo и указать duration:
```
vagrant@vagrant:~$ sudo /usr/sbin/opensnoop-bpfcc -d 1
PID    COMM               FD ERR PATH
771    vminfo              6   0 /var/run/utmp
579    dbus-daemon        -1   2 /usr/local/share/dbus-1/system-services
579    dbus-daemon        18   0 /usr/share/dbus-1/system-services
579    dbus-daemon        -1   2 /lib/dbus-1/system-services
579    dbus-daemon        18   0 /var/lib/snapd/dbus-1/system-services/
```

Как-то так :-)

6. Какой системный вызов использует `uname -a`? Приведите цитату из man по этому системному вызову, где описывается 
альтернативное местоположение в `/proc`, где можно узнать версию ядра и релиз ОС.

`strace` указывает, что системный вызов так и называется `uname` ).

Выполним `man 2 uname` и получим:
```
Part of the utsname information is also accessible via /proc/sys/kernel/{ostype, hostname, osrelease, version, 
domainname}.
```

Можно проверить, например:
```
vagrant@vagrant:~$ cat /proc/sys/kernel/version 
#90-Ubuntu SMP Fri Jul 9 22:49:44 UTC 2021
vagrant@vagrant:~$ cat /proc/sys/kernel/osrelease 
5.4.0-80-generic
```

Вызов `uname -a`:
```
vagrant@vagrant:~$ uname -a
Linux vagrant 5.4.0-80-generic #90-Ubuntu SMP Fri Jul 9 22:49:44 UTC 2021 x86_64 x86_64 x86_64 GNU/Linux
```

7. Чем отличается последовательность команд через `;` и через `&&` в bash? Например:
```
root@netology1:~# test -d /tmp/some_dir; echo Hi
Hi
root@netology1:~# test -d /tmp/some_dir && echo Hi
root@netology1:~#
```
Есть ли смысл использовать в bash `&&`, если применить `set -e`?

- **;** -- команды, разделенные `;` выполняются последовательно; командный интерпретатор ждет поочередно завершения 
каждой из команд. Статус возврата списка в этом случае совпадает со статусом возврата последней выполненной команды. 
Строка 236 в `man bash`;
- **&&** -- управляющий оператор для И-списка. Например, `команда1 && команда2` ==> `команда2` выполнится только если 
`команда1` вернула статус выхода `0`. Строка 242 в `man bash`.

Поиск команды `set` в `man bash` (строка 4014) показал, что `set -e` позволяет немедленно завершать работу, если 
команда выполнится с ненулевым статусом выхода. Проверил, меня даже из сессии терминала выкинуло )) Далее в мане 
написано, что работа командного интерпретатора не завершается, если закончившаяся неудачно команда является частью 
цикла `until` или `while`, частью оператора `if`, частью списка `&&` или `||`, или если к статусу выхода команды 
применяется отрицание с помощью оператора `!`. 

Смысл использовать в bash `&&`, если применить `set -e`, может и есть, но что-то не могу придумать пример, зачем это
может пригодиться..

8. Из каких опций состоит режим `bash set -euxo pipefail` и почему его хорошо было бы использовать в сценариях?

В мануале `man bash` ищем и находим описание опций:
- **e** -- позволяет немедленно завершать работу, если команда выполнится с ненулевым статусом выхода. Выше описывал;
- **u** -- при подстановке значений параметров рассматривать не установленную переменную как ошибку. При попытке 
подстановки значения не существующей переменной командный интерпретатор выдает сообщение об ошибке и, если он - не 
интерактивный, завершает работу с ненулевым статусом выхода;
- **x** --  после подстановок в каждой простой команде выдавать значение переменной **PS4**, а затем - команду с 
результатами подстановок в аргументах. Выводим подробный лог :-);
- **o pipefail** -- если установлено, то возвращаемым значением конвейера является значение последней (крайней правой) 
команды, выходящей с ненулевым статусом, или ноль, если все команды в конвейере выходят успешно. По умолчанию эта 
опция отключена.

В итоге, вся эта конструкция для детального лога и завершении сценария в случае ошибок на любом этапе (кроме последней
команды).

9. Используя `-o stat` для `ps`, определите, какой наиболее часто встречающийся статус у процессов в системе. 
В `man ps` ознакомьтесь (`/PROCESS STATE CODES`) что значат дополнительные к основной заглавной буквы статуса процессов. 
Его можно не учитывать при расчете (считать S, Ss или Ssl равнозначными).

Команда `ps -A o stat` вывалила кучу букв). Самые популярные: Ss, I. 

Ман говорит, что это в основном ожидающие и бездействующие процессы.

Шпаргалка:
```
    R : процесс выполняется в данный момент;
    S : процесс ожидает (т.е. спит менее 20 секунд);
    I : процесс бездействует (т.е. спит больше 20 секунд);
    D : процесс ожидает ввода-вывода (или другого недолгого события), непрерываемый;
    Z : zombie или defunct процесс, то есть завершившийся процесс, код возврата которого пока не считан родителем;
    T : процесс остановлен;
    W : процесс в свопе;
    < : процесс в приоритетном режиме;
    N : процесс в режиме низкого приоритета;
    L : real-time процесс, имеются страницы, заблокированные в памяти;
    s : лидер сессии
    l : is multi-threaded (using CLONE_THREAD, like NPTL pthreads do)
    + : is in the foreground process group
```
