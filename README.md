# DNCS-LAB

This repository contains the Vagrant files required to run the virtual lab environment used in the DNCS course.
```


     MANAGEMENT
      VAGRANT
      +-----+                +------------+
      |     |                |            |
      |     |            eth0|            |
      |     +----------------+   ROUTER   |
      |     |                |            |
      |     |                |            |
      |     |                +------------+
      |     |                      |eth1
      |     |                      |
      |     |                      |
      |     |                      |
      |     |                      |eth1
      |     |            +---------v---------+
      |     |        eth0|                   |
      |     +------------+      SWITCH       |
      |     |            |                   |
      |     |            +-------------------+
      |     |               |eth2         |eth3
      |     |               |             |
      |     |               |             |
      |     |               |eth1         |eth1
      |     |        +------v---+     +---v------+
      |     |        |          |     |          |
      |     |    eth0|          |     |          |
      |     +--------+  HOST-A  |     |  HOST-B  |
      |     |        |          |     |          |
      |     |        |          |     |          |
      +-----+        +----------+     +----------+
         |                              |eth0
         |                              |
         +------------------------------+


```

# Requirements
 - 10GB disk storage
 - 2GB free RAM
 - Virtualbox
 - Vagrant (https://www.vagrantup.com)
 - Internet

# How-to
 - Install Virtualbox and Vagrant
 - Clone this repository
`git clone https://github.com/dustnic/dncs-lab`
 - You should be able to launch the lab from within the cloned repo folder.
```
cd dncs-lab
[~/dncs-lab] vagrant up
```
Once you launch the vagrant script, it may take a while for the entire topology to become available.
 - Verify the status of the 4 VMs
 ```
 [dncs-lab]$ vagrant status                                                                                                                                                                
Current machine states:

router                    running (virtualbox)
switch                    running (virtualbox)
host-a                    running (virtualbox)
host-b                    running (virtualbox)
```
- Once all the VMs are running verify you can log into all of them:
`vagrant ssh router`
`vagrant ssh switch`
`vagrant ssh host-a`
`vagrant ssh host-b`
