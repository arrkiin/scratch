#!/bin/bash
# Demyx
# https://demyx.sh

if [[ ! -d /var/www/html/wp-admin ]]; then
    echo "WordPress is missing, installing now."
    cp -r /usr/src/wordpress/* /var/www/html

    if [[ "$WORDPRESS_DB_NAME" && "$WORDPRESS_DB_USER" && "$WORDPRESS_DB_PASSWORD" && "$WORDPRESS_DB_HOST" ]]; then
        mv /var/www/html/wp-config-sample.php /var/www/html/wp-config.php
        sed -i "s/database_name_here/$WORDPRESS_DB_NAME/g" /var/www/html/wp-config.php
        sed -i "s/username_here/$WORDPRESS_DB_USER/g" /var/www/html/wp-config.php
        sed -i "s/password_here/$WORDPRESS_DB_PASSWORD/g" /var/www/html/wp-config.php
        sed -i "s/localhost/$WORDPRESS_DB_HOST/g" /var/www/html/wp-config.php 
        SALT=$(curl -sL https://api.wordpress.org/secret-key/1.1/salt/)
        printf '%s\n' "g/put your unique phrase here/d" a "$SALT" . w | ed -s /var/www/html/wp-config.php
        sed -i "s/$table_prefix = 'wp_';/$table_prefix = 'wp_';\n\n\/\/ If we're behind a proxy server and using HTTPS, we need to alert Wordpress of that fact\n\/\/ see also http:\/\/codex.wordpress.org\/Administration_Over_SSL#Using_a_Reverse_Proxy\nif (isset($\_SERVER['HTTP_X_FORWARDED_PROTO']) \&\& $\_SERVER['HTTP_X_FORWARDED_PROTO'] === 'https') {\n\t$\_SERVER['HTTPS'] = 'on';\n}\n/g" /var/www/html/wp-config.php
    else
        echo "One or more environment variables are missing! Exiting ... "
        exit 1
    fi
fi
