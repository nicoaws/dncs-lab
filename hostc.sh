export DEBIAN_FRONTEND=noninteractive
# Startup commands go here
sudo su
apt-get update
ip addr add 192.150.168.1/23 dev enp0s8
ip link set dev enp0s8 up