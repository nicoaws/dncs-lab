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
