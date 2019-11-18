# DNCS-LAB ASSIGNMENT FOR A.Y. 2019/20
## Assignment and Design Requirments 
The project is assigned from Nicola Arnoldi, and it's one of the two projects required for "Progettazione di reti e sistemi di comunicazione" at the faculty of Information and Comunication Engeneering, at the University of Trento.
The requirments are the following:
- Hosts 1-a and 1-b are in two subnets (*Hosts-A* and *Hosts-B*) that must be able to scale up to respectively 384 and 198 usable addresses
- Host 2-c is in a subnet (*Hub*) that needs to accommodate up to 483 usable addresses
- Host 2-c must run a docker image (dustnic82/nginx-test) which implements a web-server that must be reachable from Host-1-a and Host-1-b
- No dynamic routing can be used
- Routes must be as generic as possible
- The lab setup must be portable and executed just by launching the `vagrant up` command

# Design
## IP addresses
For the given network topology we'll need 4 subnets: Host-A, Host-B, Hub and the subnet that includes the enp0s9 interfaces of router-1 and router-2, that I'll call Y for semplicity. We must calculate how many ips each subnet needs, considering that every subnet has 2 ip addresses that are reserved, so Host-A will need 384+2=386 ip addresses, corresponding to log_2⁡(386)=8.59⟹9 bits for host identification and 32-9=23 bits of network prefix. We can extend the reasoning for the other subnets, and then we decide 4 ip arbitrary choosed from ipv4 reserved private ranges of addresses.


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


## Routing
I gave Host-A, Host-B and Host-C the respective default gateway, and I added in router-1 and router-2 the necessary commands to tell the routers which subnets are reachable from which interface.

|  Subnet  |Default Gateway|
|----------|---------------|
|**Host-A**|192.168.4.2    |
|**Host-B**|192.168.6.2    |
| **Hub**  |192.168.8.2    |

- router-1.sh
```
21ip route add 192.168.8.0/23 via 192.168.2.2
```

- router-2.sh
```
15 ip route add 192.168.4.0/23 via 192.168.2.1 
16 ip route add 192.168.6.0/24 via 192.168.2.1
```


## VLANs
To achieve the task, we must configure Host-A and Host-B as virtual LANs. This means that we must split the switch's broadcast domain because Host-A and Host-B would be in the same collision domain. In this way, even if the two subnets are phisically linked, they become virtually separated. This can be done adding 2 tagged ports to the switch and telling router-1 to add interfaces enp0s8.1 and enp0s8.2 respectively referred to tag 1 and tag 2.

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

## Web Server
Host-C must run a docker image, so we need to install docker in Host-C and then pull dustnic82/nginx-test image (as specified in the requirments). This has been done in lines 5 to 10 in hostc.sh file.
In lines 12 to 25 I implement a simple web server configuration in html that will be downloaded in the following command at line 27.

## Vagrantfile changes
While I worked at the project I had the necessity to expand the RAM of Host-C from 256 to 512 MB. Furthermore I modified the Vagrantfile because I put the specific scripts that I created instead of the generic "common.sh", in the path of each virtual machine.

