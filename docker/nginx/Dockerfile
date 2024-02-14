FROM nginx:stable

ARG WORDPRESS_DIR=/var/www/html
ARG HTTPS=0
ARG FORWARDED_HTTPS_PORT=443
ARG FORWARDED_HTTP_PORT=80
ARG PHPFPM_PORT=9000
ARG PHPFPM_SERVICE_NAME
ARG SHARED_USER=swarm-user
ARG SHARED_GROUP=swarm-user
ARG SHARED_UID=1333
ARG SHARED_GID=1333

RUN apt-get update
RUN apt-get install -y procps
RUN groupadd --gid ${SHARED_GID} ${SHARED_GROUP}
RUN useradd --no-log-init --uid ${SHARED_UID} --gid ${SHARED_GID} -M -N ${SHARED_USER}
RUN usermod -a -G www-data ${SHARED_USER}
RUN <<EOF
#!/bin/bash
echo "user ${SHARED_USER};
worker_processes auto;
error_log /var/log/nginx/error.log warn;
pid /var/run/nginx.pid;
events {
    worker_connections 1024;
}
http {
    include /etc/nginx/mime.types;
    default_type application/octet-stream;
    log_format main '\$remote_addr - \$remote_user [\$time_local] \"\$request\" '
    '\$status \$body_bytes_sent \"\$http_referer\" '
    '\"\$http_user_agent\" \"\$http_x_forwarded_for\"';
    access_log /var/log/nginx/access.log main;
    sendfile on;
    keepalive_timeout 65;
    client_max_body_size 0;
    include /etc/nginx/conf.d/*.conf;
}" > /etc/nginx/nginx.conf
if [[ ${HTTPS} == "true" ]]; then
    echo "server {
        listen ${FORWARDED_HTTPS_PORT} http2 ssl;
        listen [::]:${FORWARDED_HTTPS_PORT} http2 ssl;
        ssl_certificate /etc/nginx/ssl/certs/server.crt;
        ssl_certificate_key /etc/nginx/ssl/certs/server.key;
        ssl_prefer_server_ciphers off;
        root ${WORDPRESS_DIR};
        index index.php index.html;
        error_log  /var/log/nginx/error.log;
        access_log /var/log/nginx/access.log;
        client_max_body_size 32M;
        location / {
            try_files \$uri \$uri/ /index.php?\$query_string;
        }
        location ~ \.php$ {
            proxy_read_timeout 300;
            fastcgi_read_timeout 300;
            fastcgi_pass   ${PHPFPM_SERVICE_NAME}:${PHPFPM_PORT};
            fastcgi_index  index.php;
            include        fastcgi_params;
            fastcgi_split_path_info ^(.+\.php)(/.+)$;
            fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
            fastcgi_param PATH_INFO \$fastcgi_path_info;
        }
    }" > /etc/nginx/conf.d/default.conf
else
    echo "server {
    listen ${FORWARDED_HTTP_PORT};
    index index.php index.html;
    error_log  /var/log/nginx/error.log;
    access_log /var/log/nginx/access.log;
    root ${WORDPRESS_DIR};
    location ~ \.php$ {
        try_files \$uri =404;
        fastcgi_split_path_info ^(.+\.php)(/.+)$;
        fastcgi_pass ${PHPFPM_SERVICE_NAME}:${PHPFPM_PORT};
        fastcgi_index index.php;
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        fastcgi_param PATH_INFO \$fastcgi_path_info;
        fastcgi_read_timeout 600;
    }
    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
        gzip_static on;
    }
}" > /etc/nginx/conf.d/default.conf
fi
EOF
CMD [ "nginx", "-g", "daemon off;" ]
