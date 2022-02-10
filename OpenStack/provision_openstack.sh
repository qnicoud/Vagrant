#!/bin/bash

cat << EOF | sudo tee -a /etc/hosts

# srv-openstack-controler
10.0.0.11 srv-openstack-controler

# srv-openstack-network
10.0.0.21 srv-openstack-network
10.0.1.21 srv-openstack-network

# srv-openstack-compute
10.0.0.31 srv-openstack-compute
10.0.1.31 srv-openstack-compute
10.0.2.31 srv-openstack-compute

# srv-openstack-block
10.0.0.41 srv-openstack-block
10.0.2.41 srv-openstack-block

# srv-openstack-object
10.0.0.51 srv-openstack-object
10.0.2.51 srv-openstack-object
EOF

sudo yum update -y && sudo yum -y upgrade
sudo rm /etc/localtime
sudo ln -sf /usr/share/zoneinfo/Europe/Paris /etc/localtime
sudo yum install -y nano chrony centos-release-openstack-victoria
sudo yum config-manager --set-enabled PowerTools
sudo systemctl enable --now chrony
sudo yum -y upgrade
sudo yum install -y openstack-selinux python3-openstackclient