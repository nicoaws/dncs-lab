export DEBIAN_FRONTEND=noninteractive
sudo su
apt update
apt install apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable"
apt update
apt install -y docker-ce

docker pull dustnic82/nginx-test

mkdir /www
echo -e 
' <!DOCTYPE html>
<html> 
    <head>
        <title>DNCS LAB PROJECT A.Y. 2019/2020</title> </head>
    <body>
        <h1>DNCS LAB</h1>   
        <h3>Student: Giovanna Nart</h3>
        <h3>Badge number: 194958</h3>
        <p> This is just a simple testing page</p>
    </body>
    </html> ' > /www/index.html

docker run --name nginx -v /www:/usr/share/nginx/html -d -p 80:80 dustnic82/nginx-test

ip addr add 192.168.8.1/23 dev enp0s8
ip link set dev enp0s8 up
ip route del default
ip route add default via 192.168.8.2

