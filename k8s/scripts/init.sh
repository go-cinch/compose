#!/bin/bash

if [ "$VIP" = "" ]; then
  echo "VIP is empty"
  exit 1
fi
if [ "$NODE_TYPE" = "" ]; then
  echo "NODE_TYPE is empty"
  exit 1
fi

if [ "$SUFFIX" = "" ]; then
  SUFFIX=$(echo $RANDOM | md5sum | head -c 8);
fi
if [ "$NODE_NAME" = "" ]; then
  if [ "$NODE_TYPE" = "master" ] || [ "$NODE_TYPE" = "master.join" ]; then
    NODE_NAME="master-${SUFFIX}"
  else 
    NODE_NAME="worker-${SUFFIX}"
  fi
fi
if [ "$NODE_TYPE" = "master.join" ] || [ "$NODE_TYPE" = "worker" ]; then
  if [ "$JOIN_TOKEN" = "" ]; then
      echo -e "JOIN_TOKEN is empty, got it in control-plane by: \n kubeadm token create --print-join-command"
      exit 1
    fi
    if [ "$JOIN_HASH" = "" ]; then
      echo -e "JOIN_HASH is empty, got it in control-plane by: \n kubeadm token create --print-join-command"
      exit 1
    fi
fi
if [ "$NODE_TYPE" = "master.join" ]; then
  if [ "$JOIN_KEY" = "" ]; then
      echo -e "JOIN_KEY is empty, got it in control-plane by: \n kubeadm certs certificate-key"
      exit 1
    fi
fi

echo 'kubeadm init...'
if [ "$NODE_TYPE" = "master" ]; then
  # without coredns
  kubeadm init \
    --v=10 \
    --control-plane-endpoint=$VIP:6443 \
    --skip-phases addon/coredns \
    --upload-certs \
    --node-name $NODE_NAME \
    --service-cidr=10.25.0.0/12 \
    --pod-network-cidr=10.155.0.0/16 \
    --ignore-preflight-errors=Mem
  mkdir -p $HOME/.kube
  cp -f /etc/kubernetes/admin.conf $HOME/.kube/config
  chown $(id -u):$(id -g) $HOME/.kube/config
  # single node: https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/#control-plane-node-isolation
  # kubectl taint nodes --all node-role.kubernetes.io/control-plane-
elif [ "$NODE_TYPE" = "master.join" ]; then
  kubeadm join $VIP:6443 \
    --v=10 \
    --node-name $NODE_NAME \
    --control-plane \
    --token $JOIN_TOKEN \
    --discovery-token-ca-cert-hash sha256:$JOIN_HASH \
    --certificate-key $JOIN_KEY \
    --ignore-preflight-errors=Mem
  mkdir -p $HOME/.kube
  cp -f /etc/kubernetes/admin.conf $HOME/.kube/config
  chown $(id -u):$(id -g) $HOME/.kube/config
else
  kubeadm join $VIP:6443 \
    --v=10 \
    --node-name $NODE_NAME \
    --token $JOIN_TOKEN \
    --discovery-token-ca-cert-hash sha256:$JOIN_HASH
  mkdir -p $HOME/.kube
  cp -f /etc/kubernetes/kubelet.conf $HOME/.kube/config
  chown $(id -u):$(id -g) $HOME/.kube/config
fi

kubectl cluster-info

echo 'init or join cluster success!'
