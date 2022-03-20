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
