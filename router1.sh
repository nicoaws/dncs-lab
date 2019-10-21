export DEBIAN_FRONTEND=noninteractive
# Startup commands go here
sudo su
apt-get update
apt-get install -y tcpdump --assume-yes
apt install -y curl --assume-yes

sysctl -w net.ipv4.ip_forward=1

ip link set dev enp0s8 up
ip link set dev enp0s8.1 up
ip link set dev enp0s8.2 up
ip link set dev enp0s9 up

ip link add link enp0s8 name enp0s8.1 type vlan id 1
ip link add link enp0s8 name enp0s8.2 type vlan id 2


ip add add 192.172.3.2/23 dev enp0s8.1
ip add add 172.168.7.2/24 dev enp0s8.2
ip add add 172.110.128.1/30 dev enp0s9

ip route add 192.150.168.0/23 via 172.110.128.2