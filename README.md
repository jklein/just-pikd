just-pikd
=========


Rules:
-------------
* All request params should be fetched in route files, sanitized, and safely passed into controllers
* Route files should be feature specific

Development Setup:
-------------
1. Download and install Vagrant from https://www.vagrantup.com/downloads.html
2. Download and install Virtualbox from https://www.virtualbox.org/wiki/Downloads
3. Have a recent version of ruby installed. I used ruby 1.9.3p484 installed via macports.
4. In the git working copy, type `vagrant up` to start the VM. The first time you do this it will take longer since it needs to download the VM image.
5. localhost:8080 on the host machine will be forwarded to the VM's port 80, so hit localhost:8080 in a web browser to validate that things got set up properly.
6. You can ssh to the VM using `vagrant ssh` as well.
7. Edit code via the mapped shared directory `/usr/share/nginx/html`
8. To make changes to the server's confguration, edit the chef cookbooks in the `cookbooks/` directory, and run `vagrant provision` to automatically run chef-solo against the running VM
