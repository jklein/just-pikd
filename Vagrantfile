#, -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  # All Vagrant configuration is done here. The most common configuration
  # options are documented and commented below. For a complete reference,
  # please see the online documentation at vagrantup.com.

  # Make sure that chef is installed on the VM
  config.omnibus.chef_version = :latest

  # Every Vagrant virtual environment requires a box to build off of.
  config.vm.box = "opscode-ubuntu-14.04-chef11"

  config.vm.box_url = "http://opscode-vm-bento.s3.amazonaws.com/vagrant/virtualbox/opscode_ubuntu-14.04_chef-provisionerless.box" # from https://github.com/opscode/bento

  # Fix DNS on the VM, because it is totally busted otherwise
  # http://askubuntu.com/questions/238040/how-do-i-fix-name-service-for-vagrant-client
  config.vm.provider "virtualbox" do |v|
      v.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
  end

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine. In the example below,
  # accessing "localhost:8080" will access port 80 on the guest machine.
  config.vm.network "forwarded_port", guest: 80, host: 8080
  config.vm.network "forwarded_port", guest: 3000, host:3000

  #provision the VM with chef_solo, which uses cookbooks in the cookbooks/ directory
  config.vm.provision "chef_solo" do |chef|
    chef.cookbooks_path = "../just-pikd-chef/cookbooks"
    chef.roles_path = "../just-pikd-chef/roles"
    chef.add_role("Base")
  end

  #TODO remove this: monit should handle it
  config.vm.provision "shell", inline: "sudo service php-fpm restart"

  #create shared folder for code
  config.vm.synced_folder ".", "/usr/share/nginx/html"
  config.vm.synced_folder "../just-pikd-wms", "/opt/go/src/just-pikd-wms"
  #shared folder for database dumps (assumes you have Box set up)
  config.vm.synced_folder "~/Box\ Sync/Company\ Shared\ Folder/database/", "/mnt/database"
end
