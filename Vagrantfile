# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure("2") do |config|
  config.vm.box_check_update = false
  config.vm.provider "virtualbox" do |vb|
    vb.customize ["modifyvm", :id, "--usb", "on"]
    vb.customize ["modifyvm", :id, "--usbehci", "off"]
    vb.customize ["modifyvm", :id, "--nicpromisc2", "allow-all"]
    vb.customize ["modifyvm", :id, "--nicpromisc3", "allow-all"]
    vb.customize ["modifyvm", :id, "--nicpromisc4", "allow-all"]
    vb.customize ["modifyvm", :id, "--nicpromisc5", "allow-all"]
    vb.memory = 256
    vb.cpus = 1
  end
  config.vm.define "router" do |router|
    router.vm.box = "minimal/trusty64"
    router.vm.hostname = "router"
    router.vm.network "private_network", virtualbox__intnet: "broadcast_router", auto_config: false
  end
  config.vm.define "switch" do |switch|
    switch.vm.box = "minimal/trusty64"
    switch.vm.hostname = "switch"
    switch.vm.network "private_network", virtualbox__intnet: "broadcast_router", auto_config: false
    switch.vm.network "private_network", virtualbox__intnet: "broadcast_host_a", auto_config: false
    switch.vm.network "private_network", virtualbox__intnet: "broadcast_host_b", auto_config: false
  end
  config.vm.define "host-a" do |hosta|
    hosta.vm.box = "minimal/trusty64"
    hosta.vm.hostname = "host-a"
    hosta.vm.network "private_network", virtualbox__intnet: "broadcast_host_a", auto_config: false
  end
  config.vm.define "host-b" do |hostb|
    hostb.vm.box = "minimal/trusty64"
    hostb.vm.hostname = "host-b"
    hostb.vm.network "private_network", virtualbox__intnet: "broadcast_host_b", auto_config: false
  end
  config.vm.provision "shell", inline: <<-SHELL
    export DEBIAN_FRONTEND=noninteractive
    apt-get update
    apt-get install -y tcpdump --assume-yes
    apt-get install -y openvswitch-common openvswitch-switch apt-transport-https ca-certificates curl software-properties-common
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
    add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
    apt-get update
    apt-get install -y docker-ce
    echo "alias dncs='sudo ip netns exec dncs'" >> /home/vagrant/.bashrc
  SHELL
end
