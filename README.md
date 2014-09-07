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
2. Install the vagrant-omnibus plugin: `vagrant plugin install vagrant-omnibus`
3. Download and install Virtualbox from https://www.virtualbox.org/wiki/Downloads
4. Make sure you are syncing the Company Shared Folder in box.com to a local drive, which contains database dumps. The database dumps should be in "~/Box\ Sync/Company\ Shared\ Folder/database"
5. Have a recent version of ruby installed. I used ruby 1.9.3p484 installed via macports.
6. In the parent directory of your just-pikd working copy, `git clone git@github.com:jklein/just-pikd-chef.git`
7. In the just-pikd working copy, type `vagrant up` to start the VM. The first time you do this it will take longer since it needs to download the VM image.
8. `sudo npm install -g` to install npm globals like gulp
9. `npm install` to get all of the dependencies for the project.
10. `sudo gem update --system` and `sudo gem install compass` to get [compass](http://compass-style.org/).
11. `curl -sS https://getcomposer.org/installer | php` install composer
12. `sudo mv composer.phar /usr/local/bin/composer` move composer to a bin directory so you can just run `composer`
13. `cd app && composer install && cd -` - This will install all PHP dependencies and generate the autoload file
14. `gulp` - This will build all JS/CSS and start watching the filesystem for changes.
15. localhost:8080 on the host machine will be forwarded to the VM's port 80, so hit localhost:8080 in a web browser to validate that things got set up properly.
16. You can ssh to the VM using `vagrant ssh` as well.
17. Your git working copy is automatically mapped to `/usr/share/nginx/html` as a shared directory, so you should be able to edit code and see the changes right away.

Changing Development server configuration:
-------------
1. Small changes can be tested via `vagrant ssh` (the user has sudo access)
2. To do it properly, edit the chef cookbooks in the `cookbooks/` directory of the just-pikd-chef repo, and if you need to add a cookbook or recipe edit the Vagrantfile in this repo as well (we should add roles for this later and an environment flag).
3. Run `vagrant provision` to automatically run chef-solo against the running VM. If you are just editing the Vagrantfile this is enough, but if you edit the cookbooks themselves you'll need to reload first to get those changes onto the VM. `vagrant reload --provision` will take care of that.

Updating Database:
-------------
1. Feel free to edit the dev database directly as much as you want.
2. To save changes to the data file, run the pg_dump utility against the
   database, e.g. `pg_dump -h localhost -U postgres -d product -W -Fc >
   /mnt/database/product.dump`
3. To update the schema files in schema/, run the dump_schema.php file: `php
   -f /usr/share/nginx/html/schema/dump_schema.php`
4. commit and push your changes for schema. The DB dump should sync to Box automatically.