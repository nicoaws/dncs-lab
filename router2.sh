export DEBIAN_FRONTEND=noninteractive
# Startup commands go here
sudo su
apt-get update
apt-get install -y tcpdump --assume-yes
apt install -y curl --assume-yes

sysctl -w net.ipv4.ip_forward=1
ip link set dev enp0s8 up
ip add add 192.168.1.2/23 dev enp0s8 
ip add add 192.168.2.2/30 dev enp0s9
ip link set dev enp0s9 up
ip route add 192.168.4.0/23 via 192.168.2.1 #anche qui è meglio generalizzare
ip route add 192.168.6.0/24 via 192.168.2.1