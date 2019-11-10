export DEBIAN_FRONTEND=noninteractive

sudo su
apt-get update
apt-get install -y tcpdump --assume-yes
apt install -y curl --assume-yes
ip addr add 192.168.4.1/23 dev enp0s8
ip link set dev enp0s8 up
ip route del default
ip route add default via 192.168.4.2