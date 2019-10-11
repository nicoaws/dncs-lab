export DEBIAN_FRONTEND=noninteractive
# Startup commands go here
sudo su
apt-get update
sysctl -w net.ipv4.ip_forward=1
ip link set dev enp0s8 up
ip link add link enp0s8 name enp0s8.1 type vlan id 1
ip link add link enp0s8 name enp0s8.2 type vlan id 2
ip link set dev enp0s8 up
ip link set dev enp0s8.1 up
ip link set dev enp0s8.2 up
ip add add 192.172.3.2/23 dev enp0s8.1
ip add add 172.168.7.2/24 dev enp0s8.2