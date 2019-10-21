export DEBIAN_FRONTEND=noninteractive
# Startup commands go here
sudo su
apt-get update
apt-get install -y tcpdump --assume-yes
apt install -y curl --assume-yes

sysctl -w net.ipv4.ip_forward=1
ip link set dev enp0s8 up
ip add add 192.150.168.2/23 dev enp0s8 
ip add add 172.110.128.2/30 dev enp0s9
ip link set dev enp0s9 up
ip route add 192.172.2.0/23 via 172.110.128.1
ip route add 172.168.7.0/24 via 172.110.128.1