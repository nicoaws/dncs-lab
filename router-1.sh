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
#creates a static route to reach subnet B via router-2
ip route add 172.16.2.0/24 via 172.16.3.66 dev enp0s9
