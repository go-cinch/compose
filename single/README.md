# Single server

```bash
git clone https://github.com/go-cinch/compose
cd compose/single
```

## Init mysql and redis

```bash
# 1. set env
export REDIS_PASSWORD=redispwd
export MYSQL_USER=cinch
export MYSQL_PASSWORD=mysqlpwd
export MYSQL_DATABASE=cinch
export MYSQL_ROOT_PASSWORD=mysqlrootpwd
# or
source myenv

# 2. run
docker-compose -f docker-compose.db.yml rm -sf redis mysql
docker-compose -f docker-compose.db.yml up -d redis mysql
# low cpu and memory
docker-compose -f docker-compose.db.yml rm -sf redis mysql
docker-compose --compatibility -f docker-compose.db.yml up -d redis mysql
```

## Init auth

```bash
# 1. set tag
# u should replace tag to build image uri
export AUTH_TAG=tag

# 2. set env
export AUTH_DATA_DATABASE_DSN="cinch:mysqlpwd@tcp(mysql:3306)/cinch?charset=utf8mb4&collation=utf8mb4_general_ci&parseTime=True&loc=UTC&timeout=10000ms"
export AUTH_DATA_REDIS_DSN=redis://:redispwd@redis:6379/0
# or
source myenv

# 3. run
docker-compose -f docker-compose.auth.yml rm -sf auth
docker-compose -f docker-compose.auth.yml up -d auth

docker-compose -f docker-compose.auth.yml rm -sf auth
docker-compose --compatibility -f docker-compose.auth.yml up -d auth
```

## Init pc-vue3

```bash
# 1. set tag
# u should replace tag to build image uri
export PC_VUE3_TAG=tag

# 2. set env
# u should replace server_ip to server ip address
export LOCAL_IP=server_ip
export NGINX_HOST=$LOCAL_IP
export NGINX_PORT=80
export AUTH_HOST=auth
export AUTH_PORT=6060
# or
source myenv

# 3. run
docker-compose -f docker-compose.pc-vue3.yml rm -sf pc-vue3
docker-compose -f docker-compose.pc-vue3.yml up -d pc-vue3

docker-compose -f docker-compose.pc-vue3.yml rm -sf pc-vue3
docker-compose --compatibility -f docker-compose.pc-vue3.yml up -d pc-vue3
```

## Init pc-react

```bash
# 1. set tag
# u should replace tag to build image uri
export PC_REACT_TAG=tag

# 2. set env
# u should replace server_ip to server ip address
export LOCAL_IP=server_ip
export NGINX_HOST=$LOCAL_IP
export NGINX_PORT=80
export AUTH_HOST=auth
export AUTH_PORT=6060
# or
source myenv

# 3. run
docker-compose -f docker-compose.pc-react.yml rm -sf pc-react
docker-compose -f docker-compose.pc-react.yml up -d pc-react

docker-compose -f docker-compose.pc-react.yml rm -sf pc-react
docker-compose --compatibility -f docker-compose.pc-react.yml up -d pc-react
```