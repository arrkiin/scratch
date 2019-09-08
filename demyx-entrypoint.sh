#!/bin/bash

if [[ ! -d /var/www/html/wp-admin ]]; then
	echo "WordPress is missing, installing now."
	cp -R /usr/src/wordpress/* /var/www/html

	if [[ "$WORDPRESS_DB_NAME" ]] && [[ "$WORDPRESS_DB_USER" ]] && [[ "$WORDPRESS_DB_PASSWORD" ]] && [[ "$WORDPRESS_DB_HOST" ]]; then
		mv /var/www/html/wp-config-sample.php /var/www/html/wp-config.php
		sed -i "s/database_name_here/$WORDPRESS_DB_NAME/g" /var/www/html/wp-config.php
		sed -i "s/username_here/$WORDPRESS_DB_USER/g" /var/www/html/wp-config.php
		sed -i "s/password_here/$WORDPRESS_DB_PASSWORD/g" /var/www/html/wp-config.php
		sed -i "s/localhost/$WORDPRESS_DB_HOST/g" /var/www/html/wp-config.php 
		SALT=$(curl -L https://api.wordpress.org/secret-key/1.1/salt/)
		printf '%s\n' "g/put your unique phrase here/d" a "$SALT" . w | ed -s /var/www/html/wp-config.php
		sed -i "s/$table_prefix = 'wp_';/$table_prefix = 'wp_';\n\n\/\/ If we're behind a proxy server and using HTTPS, we need to alert Wordpress of that fact\n\/\/ see also http:\/\/codex.wordpress.org\/Administration_Over_SSL#Using_a_Reverse_Proxy\nif (isset($\_SERVER['HTTP_X_FORWARDED_PROTO']) \&\& $\_SERVER['HTTP_X_FORWARDED_PROTO'] === 'https') {\n\t$\_SERVER['HTTPS'] = 'on';\n}\n/g" /var/www/html/wp-config.php
	fi
fi

# Domain replacement
if [[ -n "$WORDPRESS_DOMAIN" ]]; then
	sed -i "s|/var/log/demyx/demyx|/var/log/demyx/$WORDPRESS_DOMAIN|g" /etc/php7/php-fpm.d/www.conf
fi

# PHP Upload limit
if [[ -n "$WORDPRESS_UPLOAD_LIMIT" ]]; then
	sed -i "s|post_max_size = 128M|post_max_size = $WORDPRESS_UPLOAD_LIMIT|g" /etc/php7/php.ini
	sed -i "s|upload_max_filesize = 128M|upload_max_filesize = $WORDPRESS_UPLOAD_LIMIT|g" /etc/php7/php.ini
fi

# PHP max memory limit
if [[ -n "$WORDPRESS_PHP_MEMORY" ]]; then
	sed -i "s|memory_limit = 256M|memory_limit = $WORDPRESS_PHP_MEMORY|g" /etc/php7/php.ini
fi

# PHP max execution time
if [[ -n "$WORDPRESS_PHP_MAX_EXECUTION_TIME" ]]; then
	sed -i "s|max_execution_time = 300|max_execution_time = $WORDPRESS_PHP_MAX_EXECUTION_TIME|g" /etc/php7/php.ini
fi

# PHP opcache
if [[ "$WORDPRESS_PHP_OPCACHE" = off ]]; then
	sed -i "s|opcache.enable=1|opcache.enable=0|g" /etc/php7/php.ini
	sed -i "s|opcache.enable_cli=1|opcache.enable_cli=0|g" /etc/php7/php.ini
fi

find /var/www/html -type d -print0 | xargs -0 chmod 0755
find /var/www/html -type f -print0 | xargs -0 chmod 0644
chown -R www-data:www-data /var/www/html

php-fpm -F
