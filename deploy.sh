#!/bin/bash

# https://getcomposer.org/doc/faqs/how-to-install-composer-programmatically.md
if [ ! -f "composer.phar" ]
then
    EXPECTED_SIGNATURE=$(wget -q -O - https://composer.github.io/installer.sig)
    php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
    ACTUAL_SIGNATURE=$(php -r "echo hash_file('SHA384', 'composer-setup.php');")

    if [ "$EXPECTED_SIGNATURE" != "$ACTUAL_SIGNATURE" ]
    then
        >&2 echo 'ERROR: Invalid installer signature'
        rm composer-setup.php
        exit 1
    fi

    php composer-setup.php --quiet
    RESULT=$?
    rm composer-setup.php
fi

flag=$1

if [[ $1 == "--prod" ]]
then
    git pull origin master
else
    git pull origin develop
fi

# Get dependencies and handle actual deployment
export SYMFONY_ENV=prod
./composer.phar install --no-dev --optimize-autoloader
