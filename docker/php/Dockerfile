FROM php:8.1-fpm
ARG WORDPRESS_DIR="/var/www/html"
ARG SHARED_USER=swarm-user
ARG SHARED_GROUP=swarm-user
ARG SHARED_UID=1333
ARG SHARED_GID=1333
ARG DEBUG=false
ARG PHPFPM_MAX_CHILDREN=5
ARG PHPFPM_PM=static
ARG PHP_MEMORY_LIMIT=64M
ARG PHP_MAX_EXECUTION_TIME=60
ARG PHP_UPLOAD_MAX_FILESIZE=8M
ARG PHP_MAX_INPUT_TIME=300
ARG PHP_POST_MAX_SIZE=2M
WORKDIR ${WORDPRESS_DIR}
RUN apt-get update
RUN apt-get install -y curl build-essential procps
RUN apt-get install -y libjpeg-dev libpng-dev zlib1g-dev libfreetype-dev libjpeg62-turbo-dev libzip-dev
RUN docker-php-ext-configure gd --with-freetype --with-jpeg
RUN docker-php-ext-install -j$(nproc) gd
RUN docker-php-ext-install -j$(nproc) mysqli
RUN docker-php-ext-install -j$(nproc) opcache
RUN docker-php-ext-install -j$(nproc) zip
RUN groupadd --gid ${SHARED_GID} ${SHARED_GROUP}
RUN useradd --no-log-init --uid ${SHARED_UID} --gid ${SHARED_GID} -M -N ${SHARED_USER}
RUN usermod -a -G www-data ${SHARED_USER}
RUN <<EOF
#!/bin/bash
echo 'opcache.memory_consumption=256
opcache.interned_strings_buffer=8
opcache.max_accelerated_files=4000
opcache.revalidate_freq=2
opcache.fast_shutdown=1
opcache.enable_cli=1' > /usr/local/etc/php/conf.d/opcache-recommended.ini
echo "
user = ${SHARED_USER}
group = ${SHARED_GROUP}
pm = ${PHPFPM_PM}
pm.max_children = ${PHPFPM_MAX_CHILDREN}
" >> /usr/local/etc/php-fpm.d/www.conf
echo "
file_uploads = On
upload_max_filesize = ${PHP_UPLOAD_MAX_FILESIZE}
post_max_size = ${PHP_POST_MAX_SIZE}
memory_limit = ${PHP_MEMORY_LIMIT}
max_execution_time = ${PHP_MAX_EXECUTION_TIME}
max_input_time = ${PHP_MAX_INPUT_TIME}
log_errors = On
" >> /usr/local/etc/php/php.ini
if [[ ${DEBUG} == "true" ]]; then
    echo "
    php_flag[display_errors] = on
    php_admin_flag[log_errors] = on
    " >> /usr/local/etc/php-fpm.d/www.conf
    echo "
    error_reporting = E_ALL
    display_errors = On
    " >> /usr/local/etc/php/php.ini
else
    echo "
    php_flag[display_errors] = off
    php_admin_flag[log_errors] = off
    " >> /usr/local/etc/php-fpm.d/www.conf
    echo "
    error_reporting = E_ERROR
    display_errors = Off
    " >> /usr/local/etc/php/php.ini
fi
EOF
RUN chown -R $SHARED_USER:$SHARED_GROUP .
RUN chmod -R 755 .
CMD [ "php-fpm" ]