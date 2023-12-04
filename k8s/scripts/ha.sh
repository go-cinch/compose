#!/bin/bash

if [ "$NODE_TYPE" = "" ]; then
  echo "NODE_TYPE is empty"
  exit 1
fi
if [ "$NODE_TYPE" != "master" ] && [ "$NODE_TYPE" != "master.join" ]; then
  exit 0
fi
if [ "$VIP" = "" ]; then
  echo "VIP is empty"
  exit 1
fi
if [ "$SRC_IP" = "" ]; then
  IPS=($(hostname -I))
  SRC_IP="${IPS[0]}"
  echo "get src ip: $SRC_IP"
fi
if [ "$TARGET_IP" = "" ]; then
  echo "TARGET_IP is empty"
  exit 1
fi
for ip in $TARGET_IP; do
  IP+="$ip"$'\n'$'\t'
done 
if [ "$STATE" = "" ]; then
  echo "STATE is empty(MASTER or BACKUP)"
  exit 1
fi
if [ "$PRIORITY" = "" ]; then
  echo "PRIORITY is empty(recommend: MASTER > BACKUP1 > BACKUP2 > BACKUPn)"
  exit 1
fi
if [ "$INTERFACE" = "" ]; then
  INTERFACE="eth0"
fi
if [ "$ROUTER_ID" = "" ]; then
  ROUTER_ID="51"
fi
if [ "$AUTH_PASS" = "" ]; then
  AUTH_PASS="abcdefg"
fi
if [ "$APISERVER_SRC_PORT" = "" ]; then
  APISERVER_SRC_PORT="6443"
fi
if [ "$APISERVER_DEST_PORT" = "" ]; then
  APISERVER_DEST_PORT="6443"
fi
BACKEND+="server server-$SRC_IP $SRC_IP:$APISERVER_SRC_PORT check"$'\n'$'\t'
for ip in $TARGET_IP; do
  BACKEND+="server server-$ip $ip:$APISERVER_SRC_PORT check"$'\n'$'\t'
done
apt-get update
apt-get install -y keepalived haproxy
if [ -n "$ENABLE_TEST" ]; then
  apt-get install -y lighttpd 
  cat << EOF | tee /var/www/html/index.html
  $SRC_IP
EOF
  echo "curl SRC_IP"
  curl $SRC_IP
  echo "curl VIP"
  curl $VIP
fi

cat << EOF | tee /etc/keepalived/keepalived.conf
! /etc/keepalived/keepalived.conf
! Configuration File for keepalived
global_defs {
    router_id LVS_DEVEL
}
vrrp_script check_apiserver {
  script "/etc/keepalived/check_apiserver.sh"
  interval 3
  weight -2
  fall 10
  rise 2
}

vrrp_instance VI_1 {
    state ${STATE}
    interface ${INTERFACE}
    virtual_router_id ${ROUTER_ID}
    priority ${PRIORITY}
    authentication {
        auth_type PASS
        auth_pass ${AUTH_PASS}
    }
    unicast_src_ip ${SRC_IP}
    unicast_peer {
        ${IP}
    }
    virtual_ipaddress {
        ${VIP}
    }
    track_script {
        check_apiserver
    }
}
EOF

cat << EOF | tee /etc/keepalived/check_apiserver.sh
#!/bin/sh

errorExit() {
    echo "*** $*" 1>&2
    exit 1
}

curl --silent --max-time 2 --insecure https://localhost:${APISERVER_DEST_PORT}/ -o /dev/null || errorExit "Error GET https://localhost:${APISERVER_DEST_PORT}/"
if ip addr | grep -q ${VIP}; then
    curl --silent --max-time 2 --insecure https://${VIP}:${APISERVER_DEST_PORT}/ -o /dev/null || errorExit "Error GET https://${VIP}:${APISERVER_DEST_PORT}/"
fi
EOF

cat << EOF | tee /etc/haproxy/haproxy.cfg
# /etc/haproxy/haproxy.cfg
#---------------------------------------------------------------------
# Global settings
#---------------------------------------------------------------------
global
    log /dev/log local0
    log /dev/log local1 notice
    daemon

#---------------------------------------------------------------------
# common defaults that all the 'listen' and 'backend' sections will
# use if not designated in their block
#---------------------------------------------------------------------
defaults
    mode                    http
    log                     global
    option                  httplog
    option                  dontlognull
    option http-server-close
    option forwardfor       except 127.0.0.0/8
    option                  redispatch
    retries                 1
    timeout http-request    10s
    timeout queue           20s
    timeout connect         5s
    timeout client          20s
    timeout server          20s
    timeout http-keep-alive 10s
    timeout check           10s

#---------------------------------------------------------------------
# apiserver frontend which proxys to the control plane nodes
#---------------------------------------------------------------------
frontend apiserver
    bind *:${APISERVER_DEST_PORT}
    mode tcp
    option tcplog
    default_backend apiserverbackend

#---------------------------------------------------------------------
# round robin balancing for apiserver
#---------------------------------------------------------------------
backend apiserverbackend
    option httpchk GET /healthz
    http-check expect status 200
    mode tcp
    option ssl-hello-chk
    balance     roundrobin
        ${BACKEND}
EOF

systemctl enable haproxy --now
systemctl enable keepalived --now