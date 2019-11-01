export DEBIAN_FRONTEND=noninteractive
# Startup commands go here

sudo su
apt update
apt install apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable"
apt update
apt install -y docker-ce

docker pull dustnic82/nginx-test

mkdir /www
echo -e '<!DOCTYPE html>\n<html>\n<head>\n    <meta charset="UTF-8">\n    <title>DNCS LAB PROJECT</title>\n</head>\n<body>\n    <h1>DNCS LAB</h1>\n    <h3>Student: Giovanna Nart</h3>\n    <h3>Immatriculation number: 194958</h3>\n</body>\n</html>' > /www/index.html

docker run --name nginx -v /www:/usr/share/nginx/html -d -p 80:80 dustnic82/nginx-test

ip addr add 192.168.1.1/23 dev enp0s8
ip link set dev enp0s8 up
ip route del default
ip route add 192.168.0.0/16 via 192.168.1.2
