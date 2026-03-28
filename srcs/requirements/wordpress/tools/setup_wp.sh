#!/bin/bash
set -e

cd /var/www/inception

DB_PASSWORD=$(cat /run/secrets/db_password)
WP_ADMIN_PASSWORD=$(cat /run/secrets/wp_admin_password)

until mysqladmin ping -h"$DB_HOST" -u"$DB_USER" --password="$DB_PASSWORD" --silent; do
	sleep 2
done

if [ ! -f wp-config.php ]; then

	wp core download --allow-root

	wp config create \
		--dbname="$DB_NAME" \
		--dbuser="$DB_USER" \
		--dbpass="$DB_PASSWORD" \
		--dbhost="$DB_HOST" \
		--allow-root

	wp core install \
		--url="https://${DOMAIN_NAME}" \
		--title="$WP_TITLE" \
		--admin_user="$WP_ADMIN_USER" \
		--admin_password="$WP_ADMIN_PASSWORD" \
		--admin_email="$WP_ADMIN_EMAIL" \
		--skip-email \
		--allow-root

	wp user create "$WP_USER" "$WP_EMAIL" \
		--role=subscriber \
		--user_pass="$WP_PASSWORD" \
		--allow-root

	chown -R www-data:www-data /var/www/inception
fi

exec php-fpm8.2 -F
