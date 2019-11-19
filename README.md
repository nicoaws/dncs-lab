# DNCS-LAB ASSIGNMENT FOR A.Y. 2019/20

## Index
- [Assignment and Design Requirments](#assignment-and-design-requirements)
- [IP addresses](#ip-addresses)
- [Routing](#routing)
- [Vlans](#vlans)
- [Web Server](#web-server)
- [Vagrantfile changes](vagrantfile-changes)
- [Testing](#testing)

# Assignment and Design Requirments 
The project is assigned by Nicola Arnoldi, and it's one of the two projects required for "Progettazione di reti e sistemi di comunicazione" at the faculty of Information and Comunication Engeneering, at the University of Trento.
The requirments are the following:
- Hosts 1-a and 1-b are in two subnets (*Hosts-A* and *Hosts-B*) that must be able to scale up to respectively 384 and 198 usable addresses
- Host 2-c is in a subnet (*Hub*) that needs to accommodate up to 483 usable addresses
- Host 2-c must run a docker image (dustnic82/nginx-test) which implements a web-server that must be reachable from Host-1-a and Host-1-b
- No dynamic routing can be used
- Routes must be as generic as possible
- The lab setup must be portable and executed just by launching the `vagrant up` command

# IP addresses
For the given network topology we'll need 4 subnets: Host-A, Host-B, Hub and the subnet that includes the enp0s9 interfaces of router-1 and router-2, that I'll call Y for semplicity. We must calculate how many ips each subnet needs, considering that every subnet has 2 ip addresses that are reserved, so Host-A will need 384+2=386 ip addresses, corresponding to log_2⁡(386)=8.59⟹9 bits for host identification and 32-9=23 bits of network prefix. We can extend the reasoning for the other subnets, and then we decide 4 IP addresses arbitrary choosed from ipv4 reserved private ranges of addresses.


|  Subnet  |  Address  |   Subnet Mask  | 
|----------|-----------|----------------|
|**Host-A**|192.168.4.0|  255.255.254.0 | 
|**Host-B**|192.168.6.0|  255.255.255.0 |
| **Hub**  |192.168.8.0|  255.255.254.0 |
|  **Y**   |192.168.2.0| 255.255.255.252|

I gave an IP to every interface of routers, Host-A, Host-B and Host-C according to the subnet's IP I chose above, as it's shown in the scheme below:

        +---------------------------------------------------------+
        |                                                         |
        |                                                         |eth0
        +--+--+                +------------+                 +------------+
        |     |                |          enp0s9           enp0s9          |
        |     |            eth0|       192.168.2.1/30     192.168.2.2/30   |
        |     |                |            |                 |            |
        |     +----------------+  router-1  +-----------------+  router-2  |
        |     |                |            |                 |            |
        |     |                |            |                 |            |
        |     |                +------------+                 +------------+
        |  M  |                      |enp0s8                   enp0s8|192.168.8.2/23
        |  A  |                      |                               |
        |  N  |              enp0s8.1|192.168.4.2/23                 |
        |  A  |              enp0s8.2|192.168.6.2/24           enp0s8|192.168.8.1/23
        |  G  |                      |                         +-----+----+
        |  E  |                      |enp0s8                   |          |
        |  M  |            +-------------------+               |          |
        |  E  |        eth0|                   |               |  host-c  |
        |  N  +------------+      SWITCH       |               |          |-
        |  T  |            |                   |               |          |
        |     |            +-------------------+               +----------+
        |  V  |               |enp0s9       |enp0s10                 |eth0
        |  A  |               |             |                        |
        |  G  |               |             |                        | 
        |  R  | enp0s8-192.168.4.1/23   enp0s8-192.168.6.1/24        |
        |  A  |        +----------+     +----------+                 |
        |  N  |        |          |     |          |                 |
        |  T  |    eth0|          |     |          |                 |
        |     +--------+  host-a  |     |  host-b  |                 |
        |     |        |          |     |          |                 |
        |     |        |          |     |          |                 |
        ++-+--+        +----------+     +----------+                 |
        | |                              |eth0                       |
        | |                              |                           |
        | +------------------------------+                           |
        |                                                            |
        |                                                            |
        +------------------------------------------------------------+


# Routing
I gave Host-A, Host-B and Host-C the respective default gateway, and I added in router-1 and router-2 the necessary commands to tell the routers which subnets are reachable from which interface.

|  Subnet  |Default Gateway|
|----------|---------------|
|**Host-A**|192.168.4.2    |
|**Host-B**|192.168.6.2    |
| **Hub**  |192.168.8.2    |

- router-1.sh
```
21 ip route add 192.168.8.0/23 via 192.168.2.2
```

- router-2.sh
```
15 ip route add 192.168.4.0/23 via 192.168.2.1 
16 ip route add 192.168.6.0/24 via 192.168.2.1
```
## Routing Tables
The following are the routing tables of the components of the network, that I visualized using the command ```route -n```.

- Host-A   

| Destination |  Gateway|   Subnet Mask    |   
|-------------|-----------|----------------|
|   0.0.0.0   |192.168.4.2|   0.0.0.0      | 
|  10.0.2.0   |  0.0.0.0  | 255.255.255.0  |
|  10.0.2.2   |  0.0.0.0  |255.255.255.255 |
| 192.168.4.0 |  0.0.0.0  | 255.255.254.0  |

- Host-B    

| Destination |  Gateway|   Subnet Mask    |   
|-------------|-----------|----------------|
|   0.0.0.0   |192.168.6.2|   0.0.0.0      | 
|  10.0.2.0   |  0.0.0.0  | 255.255.255.0  |
|  10.0.2.2   |  0.0.0.0  |255.255.255.255 |
| 192.168.6.0 |  0.0.0.0  | 255.255.255.0  |

- Host-C      

| Destination |  Gateway|   Subnet Mask    |   
|-------------|-----------|----------------|
|   0.0.0.0   |192.168.8.2|   0.0.0.0      | 
|  10.0.2.0   |  0.0.0.0  | 255.255.255.0  |
|  10.0.2.2   |  0.0.0.0  |255.255.255.255 |
| 172.17.0.0  |  0.0.0.0  |  255.255.0.0   |
| 192.168.8.0 |  0.0.0.0  | 255.255.254.0  |

- router-1                

| Destination |  Gateway|   Subnet Mask    |   
|-------------|-----------|----------------|
|   0.0.0.0   | 10.0.2.2  |   0.0.0.0      | 
|  10.0.2.0   |  0.0.0.0  | 255.255.255.0  |
|  10.0.2.2   |  0.0.0.0  |255.255.255.255 |
| 192.168.2.0 |  0.0.0.0  | 255.255.255.252|
| 192.168.4.0 |  0.0.0.0  | 255.255.254.0  |
| 192.168.6.0 |  0.0.0.0  |  255.255.255.0 |
| 192.168.8.0 |192.168.2.2|  255.255.254.0 |

- router-2                             

| Destination |  Gateway|   Subnet Mask    |   
|-------------|-----------|----------------|
|   0.0.0.0   |  10.0.2.2 |   0.0.0.0      | 
|   10.0.2.0  |  0.0.0.0  | 255.255.255.0  |
|   10.0.2.2  |  0.0.0.0  |255.255.255.255 |
| 192.168.2.0 |  0.0.0.0  |255.255.255.252 |
| 192.168.4.0 |192.168.2.1|255.255.254.0   |
| 192.168.6.0 |192.168.2.1|255.255.255.0   |
| 192.168.8.0 |  0.0.0.0  |255.255.254.0   |


# VLANs
To achieve the task, we must configure Host-A and Host-B as virtual LANs. This means that we must split the switch's broadcast domain because Host-A and Host-B would be in the same collision domain. In this way, even if the two subnets are phisically linked, they become virtually separated. This can be done by adding 2 tagged ports to the switch and telling router-1 to add interfaces enp0s8.1 and enp0s8.2 respectively referred to tag 1 and tag 2.

| VLAN |tag|
|------|---|
|Host-A|1  |
|Host-B|2  |

- switch.sh
```
9  ovs-vsctl add-port switch enp0s9 tag=1
10 ovs-vsctl add-port switch enp0s10 tag=2
```
- router-1.sh
```

9  ip link add link enp0s8 name enp0s8.1 type vlan id 1
10 ip link add link enp0s8 name enp0s8.2 type vlan id 2
```

# Web Server
Host-C must run a docker image, so we need to install docker in Host-C and then pull dustnic82/nginx-test image (as specified in the requirments). This has been done in lines 5 to 10 in hostc.sh file:
```
5  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
6  add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable"
7  apt update
8  apt install -y docker-ce
9
10 docker pull dustnic82/nginx-test
```
In lines 12 to 24 I implement a simple web server configuration in html that will be downloaded in the command at line 26 ```docker run --name nginx -v /www:/usr/share/nginx/html -d -p 80:80 dustnic82/nginx-test ```
```
12 mkdir /www
13 echo -e 
14 ' <!DOCTYPE html>
15 <html> 
16     <head>
17         <title>DNCS LAB PROJECT A.Y. 2019/2020</title> </head>
18     <body>
19         <h1>DNCS LAB</h1>   
20         <h3>Student: Giovanna Nart</h3>
21         <h3>Badge number: 194958</h3>
22         <p> This is just a simple testing page</p>
23    </body>
24    </html> ' > /www/index.html
```


# Vagrantfile changes
While I worked at the project I had the necessity to expand the RAM of Host-C from 256 to 512 MB. Furthermore I modified the Vagrantfile because I put the specific scripts that I created instead of the generic "common.sh", in the path of each virtual machine. The change I've for router-2's VM is shown below.
- Vagrantfile
```
 ...
 34 router2.vm.provision "shell", path: "router2.sh"
 ...
 ```

# Testing 
The status of the VMs can be verified with the command ```vagrant status ``` 
 that should give an output like
```
Current machine states:

router-1                  running (virtualbox)
router-2                  running (virtualbox)
switch                    running (virtualbox)
host-a                    running (virtualbox)
host-b                    running (virtualbox)
host-c                    running (virtualbox)

This environment represents multiple VMs. The VMs are all listed
above with their current state. For more information about a specific
VM, run `vagrant status NAME`.
```

Connectivity between the subnets can be checked using the command ping. We verify that there is connection between Host-A and Host-B, Host-A and Host-C, Host-B and Host-C  trying to ping from one to the other.
The following is an example of connectivity check between Host-B and Host-C
```
vagrant ssh host-b
ping 192.168.8.1
```

obtaining something like
```
vagrant@host-b:~$ ping 192.168.8.1
PING 192.168.8.1 (192.168.8.1) 56(84) bytes of data.
64 bytes from 192.168.8.1: icmp_seq=1 ttl=62 time=2.45 ms
64 bytes from 192.168.8.1: icmp_seq=2 ttl=62 time=1.72 ms
64 bytes from 192.168.8.1: icmp_seq=3 ttl=62 time=1.34 ms
64 bytes from 192.168.8.1: icmp_seq=4 ttl=62 time=1.51 ms
64 bytes from 192.168.8.1: icmp_seq=5 ttl=62 time=1.57 ms
...
--- 192.168.8.1 ping statistics ---
19 packets transmitted, 19 received, 0% packet loss, time 18039ms
rtt min/avg/max/mdev = 1.165/1.713/2.458/0.299 ms
```
To test the reachability of the web server implemented in Host-C from Host-A and Host-B, we use the command curl. Since we are still in Host-B, we only have to type  ```curl 192.168.8.1```

to obtain 
```
vagrant@host-b:~$ curl 192.168.8.1
<!DOCTYPE html>
<html> 
    <head>
        <title>DNCS LAB PROJECT A.Y. 2019/2020</title> </head>
    <body>
        <h1>DNCS LAB</h1>   
        <h3>Student: Giovanna Nart</h3>
        <h3>Badge number: 194958</h3>
        <p> This is just a simple testing page</p>
    </body>
    </html> 
```
 