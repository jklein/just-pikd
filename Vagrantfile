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

  #provision the VM with chef_solo, which uses cookbooks in the cookbooks/ directory
  config.vm.provision "chef_solo" do |chef|
    chef.cookbooks_path = "../just-pikd-chef/cookbooks"
    chef.add_recipe "apt"
    chef.add_recipe "memcached"
    chef.add_recipe "openssl"
    chef.add_recipe "build-essential"
    chef.add_recipe "postgresql"
    chef.add_recipe "postgresql::server"
    chef.add_recipe "postgresql::contrib"
    chef.add_recipe "php"
    chef.add_recipe "php::module_memcached"
    chef.add_recipe "ohai"
    chef.add_recipe "nginx::source"
    chef.add_recipe "rabbitmq"
    chef.add_recipe "vim"
    chef.add_recipe "jp_app"
    chef.json = {
      :postgresql =>  {
        :version => "9.3",
        :enable_pgdg_apt => "true",
        :config => {
         :ssl => "false"
        },
        :contrib => {
          :extensions => ['dblink']
        },
        :password => {
          #the password is "justpikd", this hash is generated by this command in psql:
          #select 'md5'||md5('justpikd'||'postgres');
          :postgres => "md59138933b1a3f118cd65ed7d62808e67b"
        },
        :pg_hba => [
          {:type => 'host', :db => 'all', :user => 'postgres', :addr => 'localhost', :method => 'md5'},
          {:type => 'host', :db => 'all', :user => 'jp_readwrite', :addr => 'localhost', :method => 'md5'}
        ]
      },
      :php => {
        :directives => {
          :auto_prepend_file               => "/usr/share/nginx/html/app/src/auto_prepend.php",
          :"date.timezone"                 => "America/New_York",
          :default_charset                 => "utf-8",
          :default_mimetype                => "text/html",
          :default_socket_timeout          => 60,
          :zend_extension                  => "opcache.so",
          :"opcache.memory_consumption"    => 512,
          :"opcache.max_accelerated_files" => 50000,
          :"opcache.revalidate_freq"       => 0,
          :"opcache.consistency_checks"    => 1
        }
      }
     }
     #add roles later
     #chef.roles_path = "roles"
     #chef.add_role("dev")
  end
  config.vm.provision "shell", inline: "sudo service nginx start"
  config.vm.provision "shell", inline: "sudo service php-fpm restart"
  config.vm.provision "shell", inline: "sudo service postgresql start"
  config.vm.provision "shell", inline: "sudo service rabbitmq-server start"
  config.vm.synced_folder ".", "/usr/share/nginx/html"
end
