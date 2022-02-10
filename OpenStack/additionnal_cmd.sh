sudo dnf --enablerepo=centos-openstack-victoria,powertools,epel -y install openstack-glance
sudo yum install openstack-glance -y

sudo sed -i 's/\#connection = <None>/connection = mysql+pymysql:\/\/glance:password@controller\/glance/' /etc/glance/glance-api.conf
sudo sed -i '/^\[keystone_authtoken\]/a www_authenticate_uri  = http:\/\/controller:5000\nauth_url = http:\/\/controller:5000\nmemcached_servers = controller:11211\nauth_type = password\nproject_domain_name = Default\nuser_domain_name = Default\nproject_name = service\nusername = glance\npassword = password' /etc/glance/glance-api.conf
sudo sed -i '/^\[paste_deploy\]/a flavor = keystone' /etc/glance/glance-api.conf
sudo sed -i '/^\[glance_store\]/a stores = file,http\ndefault_store = file\nfilesystem_store_datadir = /var/lib/glance/images/ ' /etc/glance/glance-api.conf