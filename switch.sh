export DEBIAN_FRONTEND=noninteractive
sudo su
apt-get update
apt-get install -y tcpdump
apt-get install -y openvswitch-common openvswitch-switch apt-transport-https ca-certificates curl software-properties-common

ovs-vsctl add-br switch
ovs-vsctl add-port switch enp0s8
ovs-vsctl add-port switch enp0s9 tag=1
ovs-vsctl add-port switch enp0s10 tag=2

ip link set dev enp0s8 up
ip link set dev enp0s9 up
ip link set dev enp0s10 up
ip link set dev ovs-system up