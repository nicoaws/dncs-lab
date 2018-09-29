#!/bin/sh -e
ip netns add mgmt
ip link set eth0 netns mgmt
ip netns exec mgmt dhclient
ip netns exec mgmt /usr/sbin/sshd
exit 0
