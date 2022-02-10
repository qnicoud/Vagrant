#!/bin/bash

motdp='password'
hostn='controller'
addrip='10.0.0.11'

sudo yum install mariadb mariadb-server python2-PyMySQL -y
cat << EOF | sudo tee -a /etc/my.cnf.d/openstack.cnf
[mysqld]
bind-address = 10.0.0.11

default-storage-engine = innodb
innodb_file_per_table = on
max_connections = 4096
collation-server = utf8_general_ci
character-set-server = utf8
EOF

sudo systemctl enable mariadb
sudo systemctl start mariadb
sudo echo -e "\n\npassword\npassword\n\n\n\n\n" | mysql_secure_installation
sudo dnf  -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm
sudo yum -y update
sudo yum install rabbitmq-server -y
sudo systemctl enable --now rabbitmq-server
sudo rabbitmqctl add_user openstack password
sudo rabbitmqctl set_permissions openstack ".*" ".*" ".*"
sudo yum install memcached python3-memcached -y
sudo sed -i 's/::1/&,controller/' /etc/sysconfig/memcached
sudo systemctl enable --now memcached.service
sudo yum install -y etcd
sudo mv /etc/etcd/etcd.conf /etc/etcd/etcd.conf.bak
cat << EOF | sudo tee -a /etc/etcd/etcd.conf
#[Member]
ETCD_DATA_DIR="/var/lib/etcd/default.etcd"
ETCD_LISTEN_PEER_URLS="http://10.0.0.11:2380"
ETCD_LISTEN_CLIENT_URLS="http://10.0.0.11:2379"
ETCD_NAME="controller"
#[Clustering]
ETCD_INITIAL_ADVERTISE_PEER_URLS="http://10.0.0.11:2380"
ETCD_ADVERTISE_CLIENT_URLS="http://10.0.0.11:2379"
ETCD_INITIAL_CLUSTER="controller=http://10.0.0.11:2380"
ETCD_INITIAL_CLUSTER_TOKEN="etcd-cluster-01"
ETCD_INITIAL_CLUSTER_STATE="new"
EOF
sudo systemctl enable --now etcd

sudo mysql -u root -ppassword -e "CREATE DATABASE keystone;"
sudo mysql -u root -ppassword -e "CREATE USER 'keystone'@'%' IDENTIFIED BY 'password';"
sudo mysql -u root -ppassword -e "GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'%';"
sudo yum install openstack-keystone httpd python3-mod_wsgi -y
sudo sed -i 's/\#connection = <None>/connection = mysql+pymysql:\/\/keystone:password@controller\/keystone/' /etc/keystone/keystone.conf
sudo sed -i '/^\[token\]/a provider = fernet' /etc/keystone/keystone.conf
sudo chmod a+r /etc/keystone/keystone.conf
sudo su -s /bin/bash -c "keystone-manage db_sync" keystone
sudo keystone-manage fernet_setup --keystone-user keystone --keystone-group keystone
sudo keystone-manage credential_setup --keystone-user keystone --keystone-group keystone
sudo keystone-manage bootstrap --bootstrap-password password --bootstrap-admin-url http://controller:5000/v3/ --bootstrap-internal-url http://controller:5000/v3/ --bootstrap-public-url http://controller:5000/v3/ --bootstrap-region-id RegionOne

sudo sed -i '/^#ServerName/a ServerName controller' /etc/httpd/conf/httpd.conf
sudo ln -s /usr/share/keystone/wsgi-keystone.conf /etc/httpd/conf.d/
sudo systemctl enable httpd.service
sudo systemctl start httpd.service

cat << EOF | sudo tee -a admincreds.sh
export OS_USERNAME=admin
export OS_PASSWORD=password
export OS_PROJECT_NAME=admin
export OS_USER_DOMAIN_NAME=Default
export OS_PROJECT_DOMAIN_NAME=Default
export OS_AUTH_URL=http://controller:5000/v3
export OS_IDENTITY_API_VERSION=3
EOF

source admincreds.sh