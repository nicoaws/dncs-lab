export DEBIAN_FRONTEND=noninteractive
# Startup commands go here
sudo su
apt-get update
ip addr add 172.168.7.1/24 dev enp0s8 
ip link set dev enp0s8 up
ip route add default via 172.168.7.2