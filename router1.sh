export DEBIAN_FRONTEND=noninteractive
sudo su
apt-get update
apt-get install -y tcpdump --assume-yes
apt install -y curl --assume-yes

sysctl -w net.ipv4.ip_forward=1

ip link add link enp0s8 name enp0s8.1 type vlan id 1
ip link add link enp0s8 name enp0s8.2 type vlan id 2

ip link set dev enp0s8 up
ip link set dev enp0s8.1 up
ip link set dev enp0s8.2 up
ip link set dev enp0s9 up

ip add add 192.168.4.2/23 dev enp0s8.1
ip add add 192.168.6.2/24 dev enp0s8.2
ip add add 192.168.2.1/30 dev enp0s9

ip route add 192.168.8.0/23 via 192.168.2.2