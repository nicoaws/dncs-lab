export DEBIAN_FRONTEND=noninteractive

sudo su
apt-get update

#DOWNLOAD AND INSTALL DOCKER
apt-get install -y apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
apt-get update
apt-get install -y docker-ce

#RUN DOCKER IMAGE dustnic82/nginx-test
docker system prune -a # clean up any docker resources
docker run --name DNCSWebserver -p 80:80 -d dustnic82/nginx-test

#INTERFACE CONFIGURATION
#adds IP address to the interface
ip add add 172.16.2.2/24 dev enp0s8
#brings the interface up
ip link set enp0s8 up

#STATIC ROUTING
#creates a static route to reach subnet A via router-2
ip route add 172.16.0.0/23 via 172.16.2.1
#creates a static route to reach subnet B via router-2
ip route add 172.16.3.0/26 via 172.16.2.1
