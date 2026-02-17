#!/bin/bash
set -e

DB_PASSWORD=$(cat /run/secrets/db_password)

# Espera MariaDB ficar disponível
until mysqladmin ping -h"$DB_HOST" -u"$DB_USER" --password="$DB_PASSWORD" --silent; do
	sleep 1
done

# Instala WordPress apenas se não existir
if [ ! -f /var/www/inception/wp-config.php ]; then
	echo "Installing WordPress..."

	wget https://wordpress.org/latest.tar.gz
	tar -xzf latest.tar.gz
	cp -r wordpress/* .
	rm -rf wordpress latest.tar.gz

	cp wp-config-sample.php wp-config.php

	sed -i "s/database_name_here/${DB_NAME}/" wp-config.php
	sed -i "s/username_here/${DB_USER}/" wp-config.php
	sed -i "s/password_here/${DB_PASSWORD}/" wp-config.php
	sed -i "s/localhost/${DB_HOST}/" wp-config.php

	chown -R www-data:www-data /var/www/inception
fi

exec php-fpm8.2 -F
