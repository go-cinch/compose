#!/bin/bash

envsubst '${NGINX_HOST},${NGINX_PORT},${AUTH_HOST},${AUTH_PORT}' < /etc/nginx/conf.d/cinch.tpl > /etc/nginx/conf.d/cinch.conf
cat /etc/nginx/conf.d/cinch.conf

if [ $# = 0 ]
then
    exec nginx -g 'daemon off;'
else
    exec "$@"
fi