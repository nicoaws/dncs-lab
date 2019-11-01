export DEBIAN_FRONTEND=noninteractive
# Startup commands go here
sudo su
apt-get update
apt-get install -y tcpdump --assume-yes
apt install -y curl --assume-yes
ip addr add 192.168.6.1/24 dev enp0s8 
ip link set dev enp0s8 up
ip route del default
ip route add default via 192.168.6.2