#### Решение домашнего задания к занятию "4.3. Языки разметки JSON и YAML"


1. Мы выгрузили JSON, который получили через API запрос к нашему сервису:
	```
    { "info" : "Sample JSON output from our service\t",
        "elements" :[
            { "name" : "first",
            "type" : "server",
            "ip" : 7175 
            },
            { "name" : "second",
            "type" : "proxy",
            "ip : 71.78.22.43
            }
        ]
    }
	```
  Нужно найти и исправить все ошибки, которые допускает наш сервис

   - `"ip : 71.78.22.43` --> `"ip": "71.78.22.43"`
   - `"elements" :[` --> `"elements": [`
   - `"ip" : 7175 ` --> валидно, возможно, могут возникнуть нюансы при обработке
   - отформатировал по вкусу

Вот так получилось на выходе:
```json

{
    "info": "Sample JSON output from our service\t",
    "elements": [
        {
            "name": "first",
            "type": "server",
            "ip": 7175
        },
        {
            "name": "second",
            "type": "proxy",
            "ip": "71.78.22.43"
        }
    ]
}
```

2. В прошлый рабочий день мы создавали скрипт, позволяющий опрашивать веб-сервисы и получать их IP. К уже 
реализованному функционалу нам нужно добавить возможность записи JSON и YAML файлов, описывающих наши сервисы. 
Формат записи JSON по одному сервису: { "имя сервиса" : "его IP"}. 
Формат записи YAML по одному сервису: - имя сервиса: его IP. Если в момент исполнения скрипта меняется IP у 
сервиса - он должен так же поменяться в yml и json файле.


```python

import socket
import json
import yaml

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
            with open("./hosts.json", 'w+') as hosts_json, open("./hosts.yaml", 'w+') as hosts_yaml:
                hosts_json.write(json.dumps(hosts, indent=2))
                hosts_yaml.write(yaml.dump(hosts, explicit_start=True, explicit_end=True))
        else:
            print("{} - {}".format(host, ip))
```