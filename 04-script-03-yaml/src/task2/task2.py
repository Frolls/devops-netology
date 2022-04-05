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
