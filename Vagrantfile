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
    vb.customize ["modifyvm", :id, "--cpuexecutioncap", "25"]
    vb.memory = 128
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
  config.vm.define "host_a" do |host_a|
    host_a.vm.box = "minimal/trusty64"
    host_a.vm.hostname = "host_a"
    host_a.vm.network "private_network", virtualbox__intnet: "broadcast_host_a", auto_config: false
  end
  config.vm.define "host_b" do |host_b|
    host_b.vm.box = "minimal/trusty64"
    host_b.vm.hostname = "host_a"
    host_b.vm.network "private_network", virtualbox__intnet: "broadcast_host_b", auto_config: false
  end
  config.vm.provision "shell", inline: <<-SHELL
    apt-get update
    ip netns add dncs
    apt-get install -y tcpdump openvswitch-common openvswitch-switch
    echo "alias dncs='sudo ip netns exec dncs'" >> /home/vagrant/.bashrc
  SHELL
end
