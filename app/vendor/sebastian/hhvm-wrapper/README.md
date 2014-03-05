# hhvm-wrapper

**hhvm-wrapper** is a convenience wrapper for [HHVM](http://github.com/facebook/hhvm/).

## Installation

### PHP Archive (PHAR)

The easiest way to obtain hhvm-wrapper is to download a [PHP Archive (PHAR)](http://php.net/phar) that has all required dependencies of hhvm-wrapper bundled in a single file:

    wget https://phar.phpunit.de/hhvm-wrapper.phar
    chmod +x hhvm-wrapper.phar
    mv hhvm-wrapper.phar /usr/local/bin/hhvm-wrapper

You can also immediately use the PHAR after you have downloaded it, of course:

    wget https://phar.phpunit.de/hhvm-wrapper.phar
    php hhvm-wrapper.phar

### Composer

Simply add a dependency on `sebastian/hhvm-wrapper` to your project's `composer.json` file if you use [Composer](http://getcomposer.org/) to manage the dependencies of your project. Here is a minimal example of a `composer.json` file that just defines a development-time dependency on hhvm-wrapper:

    {
        "require-dev": {
            "sebastian/hhvm-wrapper": "*"
        }
    }

For a system-wide installation via Composer, you can run:

    composer global require 'sebastian/hhvm-wrapper=2.0'

Make sure you have `~/.composer/vendor/bin/` in your path.

## Usage Example

### Compilation

    ➜  ~  hhvm-wrapper compile --target application.hhbc /path/to/source
    hhvm-wrapper 2.0.0 by Sebastian Bergmann.

### Static Code Analysis

    ➜  ~  hhvm-wrapper analyze --checkstyle logfile.xml /usr/local/src/code-coverage/PHP
    hhvm-wrapper 2.0.0 by Sebastian Bergmann.

    Using ruleset /usr/share/pear/data/hhvm-wrapper/ruleset.xml

    /usr/local/src/code-coverage/PHP/CodeCoverage/Filter.php
      206   Too many arguments in function or method call:
            $this->addFileToWhitelist($file, FALSE)

    Found 1 violation in 1 file (out of 21 total files).

    ➜  ~  cat logfile.xml
    <?xml version="1.0" encoding="UTF-8"?>
    <checkstyle>
     <file name="/usr/local/src/code-coverage/PHP/CodeCoverage/Filter.php">
      <error line="206"
             message="Too many arguments in function or method call:
                      $this-&gt;addFileToWhitelist($file, FALSE)"
             source="HipHop.PHP.Analysis.TooManyArgument"
             severity="error"/>
     </file>
    </checkstyle>
