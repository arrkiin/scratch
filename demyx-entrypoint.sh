#!/bin/bash

if [[ ! -f /var/www/html/elgg-config/settings.php ]]; then
	echo "Elgg is missing, installing now."
	cp -R /usr/src/elgg/* /var/www/html
	if [[ -n "$ELGG_DOMAIN" ]] && [[ -n "$ELGG_DBUSER" ]] && [[ -n "$ELGG_DBPASSWORD" ]] && [[ -n "$ELGG_DBNAME" ]] && [[ -n "$ELGG_DBHOST" ]] && [[ -n "$ELGG_SITENAME" ]] && [[ -n "$ELGG_SITEEMAIL" ]] && [[ -n "$ELGG_WWWROOT" ]] && [[ -n "$ELGG_DISPLAYNAME" ]] && [[ -n "$ELGG_EMAIL" ]] && [[ -n "$ELGG_USERNAME" ]] && [[ -n "$ELGG_PASSWORD" ]]; then
		sed -i 's|$enabled = false|$enabled = true|g' /usr/src/git/install/cli/sample_installer.php
		sed -i "s|'dbuser' => ''|'dbuser' => '$ELGG_DBUSER'|g" /usr/src/git/install/cli/sample_installer.php
		sed -i "s|'dbpassword' => ''|'dbpassword' => '$ELGG_DBPASSWORD'|g" /usr/src/git/install/cli/sample_installer.php
		sed -i "s|'dbname' => ''|'dbname' => '$ELGG_DBNAME'|g" /usr/src/git/install/cli/sample_installer.php
		sed -i "s|'sitename' => ''|'sitename' => '$ELGG_SITENAME'|g" /usr/src/git/install/cli/sample_installer.php
		sed -i "s|'siteemail' => ''|'siteemail' => '$ELGG_SITEEMAIL'|g" /usr/src/git/install/cli/sample_installer.php
		sed -i "s|'wwwroot' => ''|'wwwroot' => '$ELGG_WWWROOT'|g" /usr/src/git/install/cli/sample_installer.php
		sed -i "s|'dataroot' => ''|'dataroot' => '/var/www/data'|g" /usr/src/git/install/cli/sample_installer.php
		sed -i "s|'displayname' => ''|'displayname' => '$ELGG_DISPLAYNAME'|g" /usr/src/git/install/cli/sample_installer.php
		sed -i "s|'email' => ''|'email' => '$ELGG_EMAIL'|g" /usr/src/git/install/cli/sample_installer.php
		sed -i "s|'username' => ''|'username' => '$ELGG_USERNAME'|g" /usr/src/git/install/cli/sample_installer.php
		sed -i "s|'password' => ''|'password' => '$ELGG_PASSWORD'|g" /usr/src/git/install/cli/sample_installer.php
		sed -i "s|];|'dbhost' => '$ELGG_DBHOST','timezone' => '$TZ'];|g" /usr/src/git/install/cli/sample_installer.php

		php /usr/src/git/install/cli/sample_installer.php
		mv /usr/src/git/elgg-config/settings.php /var/www/html/elgg-config
		rm /var/www/html/install.php
	fi
fi

sed -i "s/ELGG_DOMAIN/$ELGG_DOMAIN/g" /etc/nginx/nginx.conf

find /var/www/html -type d -print0 | xargs -0 chmod 0755
find /var/www/html -type f -print0 | xargs -0 chmod 0644
chown -R www-data:www-data /var/www/html
chown -R www-data:www-data /var/www/data

php-fpm -D
nginx -g 'daemon off;'
