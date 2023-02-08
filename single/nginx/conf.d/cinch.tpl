server {
  listen ${NGINX_PORT};
  server_name ${NGINX_HOST};

  if ($request_method = HEAD) {
    return 200;
  }

  location / {
    alias /usr/share/nginx/html/;
    index index.html index.htm;
    try_files $uri $uri/ /index.html;
  }

  location ^~ /api/auth/ {
    proxy_redirect     off;
    proxy_set_header   X-Real-IP $remote_addr;
    proxy_set_header   X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header   X-Forwarded-Proto $scheme;
    proxy_set_header   Host $http_host;
    proxy_set_header   X-NginX-Proxy true;
    proxy_set_header   Upgrade $http_upgrade;
    proxy_set_header   Connection 'upgrade';
    proxy_http_version 1.1;
    proxy_pass         http://${AUTH_HOST}:${AUTH_PORT}/;
  }
}