Just Pikd
=========

Rules:
-------------
* All request params should be fetched in route files, sanitized, and safely passed into controllers
* Route files should be feature specific
* Dependency injection is good

Development Setup:
-------------
1. Download and install Vagrant from https://www.vagrantup.com/downloads.html
2. Download and install Virtualbox from https://www.virtualbox.org/wiki/Downloads
3. Have a recent version of ruby installed. I used ruby 1.9.3p484 installed via macports.
4. In the git working copy, type `vagrant up` to start the VM. The first time you do this it will take longer since it needs to download the VM image.
5. localhost:8080 on the host machine will be forwarded to the VM's port 80, so hit localhost:8080 in a web browser to validate that things got set up properly.
6. You can ssh to the VM using `vagrant ssh` as well.
7. Your git working copy is automatically mapped to `/usr/share/nginx/html` as a shared directory, so you should be able to edit code and see the changes right away.

Changing Development server configuration:
-------------
1. Small changes can be tested via `vagrant ssh` (the user has sudo access)
2. To do it properly, edit the chef cookbooks in the `cookbooks/` directory, and if you need to add a cookbook edit the Vagrantfile as well (we should add roles for this later and an environment flag).
3. Run `vagrant provision` to automatically run chef-solo against the running VM. You usually need to `vagrant reload` to sync changes to the cookbooks first.
