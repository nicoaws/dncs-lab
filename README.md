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
For the given network topology we need 4 subnet: host-a, host-b, hub and the subnet that includes the enp0s9 interfaces of router-1 and router-2, that I'll call Y for semplicity. We must calculate how many ips each subnet needs, considering that every subnet has 2 ip addresses that are reserved, so host-a will need 384+2=386 ip addresses, corresponding to log_2⁡(386)=8.59⟹9 bits for host identification and 32-9=23 bits of network prefix. We can extend the reasoning for the other subnets, and then we decide 4 ip arbitrary choosed from ipv4 reserved private ranges of addresses.

|  Subnet  |  Address  |   Subnet Mask  | 
|----------|-----------|----------------|
|**Host-A**|192.168.4.0|  255.255.254.0 | 
|**Host-B**|192.168.6.0|  255.255.255.0 |
| **Hub**  |192.168.0.0|  255.255.254.0 |
|  **Y**   |192.168.2.0| 255.255.255.252|



        +-----------------------------------------------------+
        |                                                     |
        |                                                     |eth0
        +--+--+                +------------+             +------------+
        |     |                |            |             |            |
        |     |            eth0|            |enp0s9 enp0s9|            |
        |     +----------------+  router-1  +-------------+  router-2  |
        |     |                |            |             |            |
        |     |                |            |             |            |
        |  M  |                +------------+             +------------+
        |  A  |                      |enp0s8                     |enp0s8
        |  N  |              enp0s8.1|                           |
        |  A  |              enp0s8.2|                           |enp0s8
        |  G  |                      |                     +-----+----+
        |  E  |                      |enp0s8               |          |
        |  M  |            +-------------------+           |          |
        |  E  |        eth0|                   |           |  host-c  |
        |  N  +------------+      SWITCH       |           |          |
        |  T  |            |                   |           |          |
        |     |            +-------------------+           +----------+
        |  V  |               |enp0s9       |enp0s10             |eth0
        |  A  |               |             |                    |
        |  G  |               |             |                    |
        |  R  |               |enp0s8       |enp0s8              |
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


