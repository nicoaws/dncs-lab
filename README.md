# DNCS-LAB
Design of Networks and Communication Systems

## Table of contents:
- [Assignment](#assignment)
- [Design Requirements](#design-requirements)
- [Network Map](#network-map)
- [Network Configuration](#network-configuration)
  - [Subnetting and IP address assignment](#subnetting-and-ip-address-assignment)
  - [Subnets](#subnets)
  - [VLANs](#vlans)
  - [Network map configured with IP](#network-map-configured-with-ip)
- [Implementation](#implementation)
- [How-to](#how-to)
- [Authors and acknowledgment](#authors-and-acknowledgment)

## Assignment

Design a functioning network where any host configured and attached to router-1 (through switch) can browse a webserver hosted on host-c, attached to router-2, satisfying the requirements described below.

Please see https://github.com/dustnic/dncs-lab for more details.

## Design requirements
- Hosts -a and -b are in two subnets (*Hosts-A* and *Hosts-B*) that must be able to scale up to respectively 311 and 48 usable addresses
- Host-c is in a subnet (*Hub*) that needs to accommodate up to 175 usable addresses
- Host-c must run a docker image (dustnic82/nginx-test) which implements a web-server that must be reachable from Host-a and Host-b
- No dynamic routing can be used
- Routes must be as generic as possible
- The lab setup must be portable and executed just by launching the `vagrant up` command


## Network map

```
        +-----------------------------------------------------+
        |                                                     |
        |                                                     |eth0
        +--+--+                +------------+             +------------+
        |     |                |            |             |            |
        |     |            eth0|            |eth2     eth2|            |
        |     +----------------+  router-1  +-------------+  router-2  |
        |     |                |            |             |            |
        |     |                |            |             |            |
        |  M  |                +------------+             +------------+
        |  A  |                      |eth1                       |eth1
        |  N  |                      |                           |
        |  A  |                      |                           |
        |  G  |                      |                     +-----+----+
        |  E  |                      |eth1                 |          |
        |  M  |            +-------------------+           |          |
        |  E  |        eth0|                   |           |  host-c  |
        |  N  +------------+      SWITCH       |           |          |
        |  T  |            |                   |           |          |
        |     |            +-------------------+           +----------+
        |  V  |               |eth2         |eth3                |eth0
        |  A  |               |             |                    |
        |  G  |               |             |                    |
        |  R  |               |eth1         |eth1                |
        |  A  |        +----------+     +----------+             |
        |  N  |        |          |     |          |             |
        |  T  |    eth0|          |     |          |             |
        |     +--------+  host-a  |     |  host-b  |             |
        |     |        |          |     |          |             |
        |     |        |          |     |          |             |
        ++-+--+        +----------+     +----------+             |
        | |                              |eth0                   |
        | |                              |                       |
        | +------------------------------+                       |
        |                                                        |
        |                                                        |
        +--------------------------------------------------------+
```

## Network Configuration


### Subnetting and IP address assignment

We decided to split our network in four main subnetworks:

- **SUBNET A** (*Hosts-A*): the portion of the network that contains Host-a + 311 other hosts + router-1 port (enp0s8.10)
- **SUBNET B** (*Hub*): the portion of the network that containing Host-c + 175 other hosts + router-2 port (enp0s8)
-	**SUBNET C** (*Hosts-B*): the portion containing Host-b + 48 other hosts + router-1 port (enp0s8.20)
-	**SUBNET D**: the portion of the network that contains the router-1 port (enp0s9) and the router-2 port (enp0s9)

One best practice when dealing with IP address assignment is to compute the range of allocable addresses consuming as few IP addresses as possible.

To achieve this aim we decide to assign to each of the four subnets the smallest IP address class that can accommodate the number of hosts required for each of them.

Representing with the letter **M** the number of bits dedicated to the host part, we use this formula:
<p align="center"> 2<sup>M</sup>-2

to calculate the number of IP addresses that each class can provide (taking into account that from the amount of IP address available calculated we have to subtract two dedicate IP - one for broadcast and one for the network - that cannot be assign to any host).

So, making our computation, we obtain the following pool of available IPs:

-	**SUBNET A**: **/23** network mask provides **510 addresses** (2<sup>9</sup>-2)
-	**SUBNET B**: **/24** network mask provides **254 addresses** (2<sup>8</sup>-2)
-	**SUBNET C**: **/26** network mask provides **62 addresses** (2<sup>6</sup>-2)
-	**SUBNET D**: **/30** network mask provides **2 addresses** (2<sup>2</sup>-2)

Note that we discard the approach to allocate to each of our subnet only the number of IP addresses that the design requirements requires. Even if this solution guarantees the best ratio of the total IP addresses used and all the ones available and so the smallest loss of IP address, on the other hand can cause several problem when dealing with a real network that has to scale up (in that case we have to change both the network mask and the routing rules to allow the connection of new hosts in the network that need new IP addresses reserved).

### Subnets

We decided to use a private pool of IP addresses.: we choose the 172.16.0.0/12 class of IP addresses, since there is no specification in the design requirements about the addresses to be used, bt any other private classes can be used.


we recap the addressing configuration used:


<div align="center"> Network </div> |  <div align="center"> Netmask </div>|  <div align="center"> Host/Net needed </div>	 | <div align="center"> Host/Net available </div> | <div align="center"> Address</div>| <div align="center"> Host Min </div> | <div align="center"> Host Max </div> |
:-----: | :-----------:        |  :---------:  | :----------:  | :--------------: | :-------:   | :------:      |
A	      | /23 – 255.255.254.0	 | 312	         | 510	         | 172.16.0.0/23	  | 172.16.0.1 | 172.16.1.254 |
B	      | /24 – 255.255.255.0 |	176	         | 254	         | 172.16.2.0/24	  |172.16.2.1  | 172.16.2.254 |
C       | /26 – 255.255.255.192	 | 49	         | 62	         | 172.16.3.0/26	  |172.16.3.1  | 172.16.3.62 |
D	      | /30 – 255.255.255.252|	2	           | 2	           | 172.16.3.64/30 |172.16.3.65|	172.16.3.66 |

### VLANs

There is only one link between the **router-1** and the **switch**, so we supposed that the subnet that hosts host-a and the subnet that hosts host-b must be separated in terms of broadcasts area on the switch.

We split the switch in two virtual switches setting up two distinct VLANs for the networks **A** and **B**. We assigned to the **Network A** a **VLAN TAG 10** and to the **Network B** a **VLAN TAG 20**.

We setup the link between the router and both LANs in trunk mode, to be able to manage simultaneously the traffic coming from 2 distinct VLANs on the same interface.

We briefly recap the configuration of Valns:

<div align="center"> Subnet </div> |	<div align="center"> Interface </div> |<div align="center"> Host </div> | <div align="center"> Vlan tag </div>|<div align="center"> IP </div>|
:------------------------------------:|:--------------------------------:|:-----------------------------------:|:-----------------------------:|:--------------------------------:
A	                            | enp0s8.10	                       | router-1                                |10	                  |172.16.0.1
C	                              | enp0s8.20	                       | router-1	                               | 20                  |172.16.3.1


## Network map configured with IP
Finally we can reacp all the configurations maded.

<div align="center"> Host </div> |<div align="center"> Interface </div> | <div align="center"> VLAN TAG </div> | <div align="center"> IP adress </div>| <div align="center"> Description</div> |
:------------------------------------:|:------------------------------------:|:------------------------------:|:-----------------------------------:|:---------------|
router-1                                 |enp0s8.10	                            |10                              |172.16.0.1	                         |Default gateway for network A                |
	                               |enp0s8.20	                            |20                              |172.16.3.1	                         |Default gateway for network B              |
	                               |enp0s9	                              |None                            |172.16.3.65	| Link to router-2|
                                 host-a	|enp0s8	|None |172.16.0.2 | Link with access port on the switch|
                                 host-b	|enp0s8	|None|172.16.3.2	| Link with access port on the switch|
router-2	                       |enp0s9	                              |None                            |172.16.3.66	|Link to router-1|
	                               |enp0s8	|None | 172.16.2.1	| Link to host-c|
host-c	|enp0s8	|None| 172.16.2.2	|Link to router-2|


        +----------------------------------------------------------------------+
        |                                                                      |
        |                                                                      |enp0s3
        +--+--+                  +------------+                          +------------+
        |     |                  |            |                          |            |
        |     |            enp0s3|            |enp0s9              enp0s9|            |
        |     +------------------+  router-1  +--------------------------+  router-2  |
        |     |                  |            |.65                    .66|            |
        |     |                  |            |      172.16.3.64/30      |            |
        |  M  |                  +------------+                          +------------+
        |  A  |          172.16.0.1/23  |enp0s8.10                      enp0s8 |.1
        |  N  |          172.16.3.1/26  |enp0s8.20                             |
        |  A  |                         |                                      |     
        |  G  |                         |                                      |
                                        |                        172.16.2.0/24 |
        |  E  |                         |                                      |
                                        |enp0s8                         enp0s8 |.2
        |  M  |            +--------------------------+                  +-----+----+
        |  E  |     enp0s3 |          TRUNK           |                  |          |
        |  N  +------------+         SWITCH           |                  |          |
        |  T  |            |  10                   20 |                  |  host-c  |
        |     |            +--------------------------+                  |          |
        |  V  |               |enp0s9              |enp0s10              |          |
        |  A  |               |                    |                     +----------+
        |  G  |               |                    |                           |enp0s3
        |  R  |               | 172.16.0.2/23      | 172.16.3.2/26             |
        |     |               | enp0s8             |enp0s8                     |
        |  A  |         +----------+           +----------+                    |
        |  N  |         |          |           |          |                    |
        |  T  |  enp0s3 |          |           |          |                    |
        |     +---------+  host-a  |           |  host-b  |                    |
        |     |         |          |           |          |                    |
        |     |         |          |           |          |                    |
        ++-+--+         +----------+           +----------+                    |
        | |                                        |enp0s3                     |
        | |                                        |                           |
        | +----------------------------------------+                           |
        |                                                                      |
        |                                                                      |
        +----------------------------------------------------------------------+
# Implementation

Now that we have defined the ip adresses, we configurate the interfaces and sets up the static routing for all devices.
## router-1.sh
For router-1 we set up also the vlans.
```
export DEBIAN_FRONTEND=noninteractive
sudo su
#IP FORWARDING
sysctl net.ipv4.ip_forward=1 #enables IP forwarding

#INTERFACE CONFIGURATION
#adds IP address to the interface
ip add add 172.16.3.65/30 dev enp0s9
#brings the interface up
ip link set enp0s9 up

#CREATION OF SUBINTERFACES FOR VLANS
#creates the subinterface for VLAN 10
ip link add link enp0s8 name enp0s8.10 type vlan id 10
#adds IP address to the subinterface
ip add add 172.16.0.1/23 dev enp0s8.10

#creates the subinterfaces for VLAN 20
ip link add link enp0s8 name enp0s8.20 type vlan id 20
#adds IP address to the subinterface
ip add add 172.16.3.1/26 dev enp0s8.20

#set the interface up
ip link set enp0s8 up
#set the subinterface up
ip link set enp0s8.10 up
#set the subinterface up
ip link set enp0s8.20 up

#STATIC ROUTING
#deletes the dafault gateway
ip route del default
#creates a static route to reach subnet C via router-2
ip route add 172.16.2.0/24 via 172.16.3.66 dev enp0s9
```
## router-2.sh
```
export DEBIAN_FRONTEND=noninteractive
sudo su

#IP FORWARDING
sysctl net.ipv4.ip_forward=1 #enables IP forwarding

#INTERFACE CONFIGURATION
#adds IP address to the interface
ip add add 172.16.2.1/24 dev enp0s8
#brings the interface up
ip link set enp0s8 up

#adds IP address to the interface
ip add add 172.16.3.66/30 dev enp0s9
#brings the interface up
ip link set enp0s9 up

#STATIC ROUTING
#deletes the dafault gateway
ip route del default
#creates a static route to reach subnet A via router-1
ip route add 172.16.0.0/23 via 172.16.3.65 dev enp0s9
#creates a static route to reach subnet B via router-1
ip route add 172.16.3.0/26 via 172.16.3.65 dev enp0s9
```
## switch.sh
For Switch we installed tcpdump, a simple packet sniffer, and OpenvSwitch; create the bridge and stes up the interfaces.

```
export DEBIAN_FRONTEND=noninteractive
apt-get update

# install tcpdump, a simple packet sniffer
apt-get install -y tcpdump

#download and install open vSwitch
apt-get install -y openvswitch-common openvswitch-switch apt-transport-https ca-certificates curl software-properties-common

sudo su

#BRIDGE CREATION
#creates a new bridge called brd
ovs-vsctl add-br brd

#INTERFACE CONFIGURATION
#creates a trunk port
ovs-vsctl add-port brd enp0s8
#brings the interface up
ip link set enp0s8 up

#creates an access port on VLAN 10
ovs-vsctl add-port brd enp0s9 tag=10
#brings the interface up
ip link set enp0s9 up

#creates an access port on VLAN 20
ovs-vsctl add-port brd enp0s10 tag=20
#brings the interface up
ip link set enp0s10 up
```
## host-a.sh
```
export DEBIAN_FRONTEND=noninteractive
sudo su

#INTERFACE CONFIGURATION
#set up IP address to the interface
ip add add 172.16.0.2/23 dev enp0s8
#brings the interface up
ip link set enp0s8 up

#STATIC ROUTING
#deletes the dafault gateway
ip route del default
#sets the default gateway on router-1
ip route add default via 172.16.0.1

```
## host-b.sh
```
export DEBIAN_FRONTEND=noninteractive
sudo su

#INTERFACE CONFIGURATION
#set up IP address to the interface
ip add add 172.16.3.2/26 dev enp0s8
#brings the interface up
ip link set enp0s8 up

#STATIC ROUTING
#deletes the dafault gateway
ip route del default
#sets the default gateway on router-1
ip route add default via 172.16.3.1
```
## host-c.sh
For host-c, as it have to run a docker image, we also installed docker, and modifyied the Vagrantfile increasing the memory `vb.memory = 512`.
```
export DEBIAN_FRONTEND=noninteractive
sudo su
apt-get update

#DOWNLOAD AND INSTALL DOCKER
apt-get install -y apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
apt-get update
apt-get install -y docker-ce

#RUN DOCKER IMAGE dustnic82/nginx-test
docker system prune -a # clean up any docker resources
docker run --name DNCSWebserver -p 80:80 -d dustnic82/nginx-test

#INTERFACE CONFIGURATION
#adds IP address to the interface
ip add add 172.16.2.254/24 dev enp0s8
#brings the interface up
ip link set enp0s8 up

#STATIC ROUTING
#creates a static route to reach subnet A via router-2
ip route add 172.16.0.0/23 via 172.16.2.1
#creates a static route to reach subnet C via router-2
ip route add 172.16.3.0/26 via 172.16.2.1
```
# How-to
 - Clone this repository
`git clone https://github.com/layachisara/dncs-lab`
 - You should be able to launch the lab from within the cloned repo folder.
```
cd dncs-lab
[~/dncs-lab] vagrant up
```
Once you launch the vagrant script, it may take a while for the entire topology to become available.
 - Verify the status of the 4 VMs
 ```
 [dncs-lab]$ vagrant status                                          
 Current machine states:
 router-1                  running (virtualbox)
 router-2                  running (virtualbox)
 switch                    running (virtualbox)
 host-a                    running (virtualbox)
 host-b                    running (virtualbox)
 host-c                    running (virtualbox)
```
- Once all the VMs are running verify you can log into all of them:
`vagrant ssh router`
`vagrant ssh switch`
`vagrant ssh host-a`
`vagrant ssh host-b`
`vagrant ssh host-c`

Now use `sudo su` With this command you have permissions to execute all the commands we need.

A useful commands is: `ifconfig` to have some informations about the ethernet interfaces.

- Reachability
Suppose
to ping host-a: `ping 172.16.0.2`
```
Mettere risultato
```
to ping host-b: `ping 172.16.3.2`
```
vagrant@host-a:~$ ping 172.16.3.2
PING 172.16.3.2 (172.16.3.2) 56(84) bytes of data.
64 bytes from 172.16.3.2: icmp_seq=1 ttl=63 time=1.35 ms
64 bytes from 172.16.3.2: icmp_seq=2 ttl=63 time=1.88 ms
^C
--- 172.16.3.2 ping statistics ---
2 packets transmitted, 2 received, 0% packet loss, time 1002ms
rtt min/avg/max/mdev = 1.358/1.620/1.883/0.265 ms

```
to ping host-c: `ping 172.16.2.2`
```
vagrant@host-a:~$ ping 172.16.2.2
PING 172.16.2.2 (172.16.2.2) 56(84) bytes of data.
64 bytes from 172.16.2.2: icmp_seq=1 ttl=62 time=2.48 ms
64 bytes from 172.16.2.2: icmp_seq=2 ttl=62 time=2.62 ms
^C
--- 172.16.2.2 ping statistics ---
2 packets transmitted, 2 received, 0% packet loss, time 1002ms
rtt min/avg/max/mdev = 2.489/2.557/2.626/0.085 ms
```
to send a request for "docker.html" of the webserver running on host-2-c:`curl 172.16.2.2`
```
vagrant@host-a:~$ curl 172.16.2.2
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
    body {
        width: 35em;
        margin: 0 auto;
        font-family: Tahoma, Verdana, Arial, sans-serif;
    }
</style>
</head>
<body>
<h1>Welcome to nginx!</h1>
<p>If you see this page, the nginx web server is successfully installed and
working. Further configuration is required.</p>

<p>For online documentation and support please refer to
<a href="http://nginx.org/">nginx.org</a>.<br/>
Commercial support is available at
<a href="http://nginx.com/">nginx.com</a>.</p>

<p><em>Thank you for using nginx.</em></p>
</body>
</html>
```

# Authors and acknowledgment
Layachi Sara and Neri Carlotta.

This project is powered by dustnic, that we want to thank because he permits us to fork his files and expand it as a project.
