# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "debian/stretch64"

  config.vm.provider "libvirt" do |vb|
    vb.memory = "2048"
    vb.cpus = "2"
    vb.cpu_mode = 'host-passthrough'
  end

  config.vm.synced_folder ".", "/vagrant", linux__nfs_options: ['rw','no_subtree_check','no_root_squash','async']

  config.vm.provision "shell", inline: <<-SHELL
     apt-get update
     apt-get install -y ruby bundler puppet
     ruby --version
     bundler --version
     cd /vagrant
     bundle install
     bundle exec rspec
  SHELL
end
