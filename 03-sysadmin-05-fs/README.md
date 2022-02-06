### Решение домашнего задания к занятию "3.5. Файловые системы"

1. Узнайте о [sparse](https://ru.wikipedia.org/wiki/%D0%A0%D0%B0%D0%B7%D1%80%D0%B5%D0%B6%D1%91%D0%BD%D0%BD%D1%8B%D0%B9_%D1%84%D0%B0%D0%B9%D0%BB) 
(разряженных) файлах.

Почитал, знал. Полезная штука.

1. Могут ли файлы, являющиеся жесткой ссылкой на один объект, иметь разные права доступа и владельца? Почему?

Нет, жесткие ссылки, в отличие от симлинков, имеют ту же информацию inode и набор разрешений, что и у исходного
файла. 

Приведу пример:
```bash
vagrant@vagrant:~$ mkdir links
vagrant@vagrant:~$ cd links/
vagrant@vagrant:~/links$ touch file
vagrant@vagrant:~/links$ ls
file
vagrant@vagrant:~/links$ ln -P file hard_link
vagrant@vagrant:~/links$ ls -li
total 0
131106 -rw-rw-r-- 2 vagrant vagrant 0 Feb  6 13:18 file
131106 -rw-rw-r-- 2 vagrant vagrant 0 Feb  6 13:18 hard_link
vagrant@vagrant:~/links$ 
```

Inode и права доступа идентичны.

Чмокнем жесткую ссылку:
```bash
vagrant@vagrant:~/links$ chmod 777 hard_link 
vagrant@vagrant:~/links$ ls -li
total 0
131106 -rwxrwxrwx 2 vagrant vagrant 0 Feb  6 13:18 file
131106 -rwxrwxrwx 2 vagrant vagrant 0 Feb  6 13:18 hard_link
```

Здорово, правда? Есть подозрение, что жесткая ссылка это обычный файл ) 

1. Сделайте `vagrant destroy` на имеющийся инстанс Ubuntu. Замените содержимое Vagrantfile следующим:

    ```bash
    Vagrant.configure("2") do |config|
      config.vm.box = "bento/ubuntu-20.04"
      config.vm.provider :virtualbox do |vb|
        lvm_experiments_disk0_path = "/tmp/lvm_experiments_disk0.vmdk"
        lvm_experiments_disk1_path = "/tmp/lvm_experiments_disk1.vmdk"
        vb.customize ['createmedium', '--filename', lvm_experiments_disk0_path, '--size', 2560]
        vb.customize ['createmedium', '--filename', lvm_experiments_disk1_path, '--size', 2560]
        vb.customize ['storageattach', :id, '--storagectl', 'SATA Controller', '--port', 1, '--device', 0, '--type', 'hdd', '--medium', lvm_experiments_disk0_path]
        vb.customize ['storageattach', :id, '--storagectl', 'SATA Controller', '--port', 2, '--device', 0, '--type', 'hdd', '--medium', lvm_experiments_disk1_path]
      end
    end
    ```

    Данная конфигурация создаст новую виртуальную машину с двумя дополнительными неразмеченными дисками по 2.5 Гб.

