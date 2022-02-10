# Update packages and install usefull ones
apt-get update
apt-get install -y sudo git vim mlocate curl python3-pip
# Add vagrant to the sudoers
usermod -aG sudo vagrant

# Add ll alias because f*cking usefull
echo 'alias ll="ls -la --color=auto"' >> /home/vagrant/.bashrc

# Generate ssh keys for vagrant user
su vagrant -c ssh-keygen <<EOF


EOF
# Copy the keys to managed vms
su vagrant -c ssh-copy-id vagrant@192.168.56.121
su vagrant -c ssh-copy-id vagrant@192.168.56.122

# Install ansible
python3 -m pip install ansible

# Generate host list
mkdir /etc/ansible
cat << EOF >> /etc/ansible/hosts
[ansible_test]
192.168.56.121
192.168.56.122
EOF