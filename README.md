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
4. In the parent directory of your just-pikd working copy, `git clone git@github.com:jklein/just-pikd-chef.git`
4. In the just-pikd working copy, type `vagrant up` to start the VM. The first time you do this it will take longer since it needs to download the VM image.
5. `sudo npm install -g` to install npm globals like gulp
6. `npm install` to get all of the dependencies for the project.
7. `sudo gem update --system` and `sudo gem install compass` to get [compass](http://compass-style.org/).
8. `curl -sS https://getcomposer.org/installer | php` install composer
9. `sudo mv composer.phar /usr/local/bin/composer` move composer to a bin directory so you can just run `composer`
10. `cd app && composer install && cd -` - This will install all PHP dependencies and generate the autoload file
11. `gulp` - This will build all JS/CSS and start watching the filesystem for changes.
12. localhost:8080 on the host machine will be forwarded to the VM's port 80, so hit localhost:8080 in a web browser to validate that things got set up properly.
13. You can ssh to the VM using `vagrant ssh` as well.
14. Your git working copy is automatically mapped to `/usr/share/nginx/html` as a shared directory, so you should be able to edit code and see the changes right away.

Changing Development server configuration:
-------------
1. Small changes can be tested via `vagrant ssh` (the user has sudo access)
2. To do it properly, edit the chef cookbooks in the `cookbooks/` directory of the just-pikd-chef repo, and if you need to add a cookbook or recipe edit the Vagrantfile in this repo as well (we should add roles for this later and an environment flag).
3. Run `vagrant provision` to automatically run chef-solo against the running VM. If you are just editing the Vagrantfile this is enough, but if you edit the cookbooks themselves you'll need to reload first to get those changes onto the VM. `vagrant reload --provision` will take care of that.
