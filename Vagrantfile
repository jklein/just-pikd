# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  # All Vagrant configuration is done here. The most common configuration
  # options are documented and commented below. For a complete reference,
  # please see the online documentation at vagrantup.com.

  # Every Vagrant virtual environment requires a box to build off of.
  config.vm.box = "opscode-ubuntu-1204"

  # The url from where the 'config.vm.box' box will be fetched if it
  # doesn't already exist on the user's system.
  config.vm.box_url = "https://opscode-vm.s3.amazonaws.com/vagrant/boxes/opscode-ubuntu-12.04.box"

  # Fix DNS on the VM, because it is totally busted otherwise
  # http://askubuntu.com/questions/238040/how-do-i-fix-name-service-for-vagrant-client
  config.vm.provider "virtualbox" do |v|
      v.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
  end

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine. In the example below,
  # accessing "localhost:8080" will access port 80 on the guest machine.
  config.vm.network "forwarded_port", guest: 80, host: 8080

  #provision the VM with chef_solo, which uses cookbooks in the cookbooks/ directory
  config.vm.provision "chef_solo" do |chef|
     chef.add_recipe "memcached"
     #add roles later
     #chef.roles_path = "roles"
     #chef.add_role("dev")
  end
  #commenting out these things for now, we should do all of these via chef instead
  #config.vm.provision "shell", inline: "sudo service iptables stop"
  #config.vm.provision "shell", inline: "sudo service nginx start"
  #config.vm.provision "shell", inline: "sudo service php-fpm start"
  #config.vm.provision "shell", inline: "sudo service mysql start"
  config.vm.synced_folder ".", "/usr/share/nginx/html"
end
