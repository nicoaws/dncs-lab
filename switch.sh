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
