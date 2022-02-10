# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrant multi-machine sample setup


Vagrant.configure("2") do |config|
  
  (1..2).each do |i|
    config.vm.define "managed-#{i}" do |managed|
      managed.vm.provider "virtualbox" do |vb|
        vb.memory = 2048
        vb.cpus = 2
      end
      managed.vm.network "private_network", ip: "192.168.56.12#{i}"
      managed.vm.hostname = "managed#{i}"
      managed.vm.box = "ubuntu/focal64"
    end
  end
  
  config.vm.define "controller" do |controller|
    controller.vm.provider "virtualbox" do |vb|
      vb.memory = 2048
      vb.cpus = 2
    end

    controller.vm.provision "shell", path: "ansible_controller.sh"
    controller.vm.provision "file", source:"./myplaybook.yml", destination: "ansible_playbook.yml"

    controller.vm.network "private_network", ip: "192.168.56.120"
    controller.vm.hostname = "controller"
    controller.vm.box = "ubuntu/focal64"
  end
end