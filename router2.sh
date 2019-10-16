export DEBIAN_FRONTEND=noninteractive
# Startup commands go here
sudo su
apt-get update
sysctl -w net.ipv4.ip_forward=1
ip link set dev enp0s8 up
ip add add 192.150.168.2/23 dev enp0s8 