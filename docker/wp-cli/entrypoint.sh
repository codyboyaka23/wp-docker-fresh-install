#!/bin/bash
set -o allexport
source /.env
set +o allexport

wp core --allow-root download --locale="${WORDPRESS_LOCALE}"
cat wp-config-sample.php > wp-config.php
wp config --allow-root set DB_NAME $WORDPRESS_DB_NAME
wp config --allow-root set DB_USER $WORDPRESS_DB_USER
wp config --allow-root set DB_PASSWORD $WORDPRESS_DB_PASSWORD
wp config --allow-root set DB_HOST $WORDPRESS_DB_HOST
yes Y | wp db --allow-root drop
wp db --allow-root create
if ! wp core --allow-root is-installed > /dev/null; then
    wp core --allow-root install --locale="${WORDPRESS_LOCALE}" --url="${WORDPRESS_URL}" --title="${WORDPRESS_TITLE}" --admin_user="${WORDPRESS_ADMIN_USER}" --admin_password="${WORDPRESS_ADMIN_PASSWORD}" --admin_email="${WORDPRESS_ADMIN_EMAIL}"
fi

chown -R $SHARED_USER:$SHARED_GROUP .
chmod -R 755 .
chmod g+s .