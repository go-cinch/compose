# K8S cluster

## Init HA cluster

### Before start

1. prepare these servers:

* virtual ip: 172.18.1.15
* master1, 2C2G, internal ip: 172.18.1.51
* master2, 2C2G, internal ip: 172.18.1.52
* master3, 2C2G, internal ip: 172.18.1.53
* worker1, 2C8G, internal ip: 172.18.55.121
* worker2, 2C8G, internal ip: 172.18.55.122
* worker3, 2C8G, internal ip: 172.18.55.123

> tip: use one worker for test also ok, up to u.

2. clone repo:

```shell
git clone https://github.com/go-cinch/compose
```

### Init control plane

exec command on master server.

#### on master1

```shell
cd compose/k8s/scripts
export VIP=172.18.1.15
# export SRC_IP="172.18.1.51"
export TARGET_IP="172.18.1.52 172.18.1.53"
export STATE=MASTER
export PRIORITY=100
export NODE_TYPE=master
export NODE_NAME=master1
make all
```

init output:

```shell
You can now join any number of the control-plane node running the following command on each as root:

kubeadm join 172.18.1.15:6443 --token gn9u9l.t0o3asqet6q7r5ki \
    --discovery-token-ca-cert-hash sha256:e86812218d77f52ef59f549124f2fdc319c230d1b2ebcf60a2107e7bc5229047 \
    --control-plane --certificate-key 789adfca045dccb66fad788b27a9a2444a30fdf75d097bfb8bffd87256335d51
```

u need save them:

* token: gn9u9l.t0o3asqet6q7r5ki
* hash: e86812218d77f52ef59f549124f2fdc319c230d1b2ebcf60a2107e7bc5229047
* key: 789adfca045dccb66fad788b27a9a2444a30fdf75d097bfb8bffd87256335d51

#### on master2

```shell
cd compose/k8s/scripts
export VIP=172.18.1.15
# export SRC_IP="172.18.1.52"
export TARGET_IP="172.18.1.51 172.18.1.53"
export STATE=BACKUP
export PRIORITY=99
export NODE_TYPE=master.join
export NODE_NAME=master2
export JOIN_TOKEN=gn9u9l.t0o3asqet6q7r5ki
export JOIN_HASH=e86812218d77f52ef59f549124f2fdc319c230d1b2ebcf60a2107e7bc5229047
export JOIN_KEY=789adfca045dccb66fad788b27a9a2444a30fdf75d097bfb8bffd87256335d51
make all
```

#### on master3

```shell
cd compose/k8s/scripts
export VIP=172.18.1.15
# export SRC_IP="172.18.1.53"
export TARGET_IP="172.18.1.51 172.18.1.52"
export STATE=BACKUP
export PRIORITY=98
export NODE_TYPE=master.join
export NODE_NAME=master3
export JOIN_TOKEN=gn9u9l.t0o3asqet6q7r5ki
export JOIN_HASH=e86812218d77f52ef59f549124f2fdc319c230d1b2ebcf60a2107e7bc5229047
export JOIN_KEY=789adfca045dccb66fad788b27a9a2444a30fdf75d097bfb8bffd87256335d51
make all
```

#### show nodes

```shell
kubectl get node -o wide

# NAME      STATUS   ROLES           AGE     VERSION   INTERNAL-IP    EXTERNAL-IP   OS-IMAGE             KERNEL-VERSION      CONTAINER-RUNTIME
# master1   Ready    control-plane   3m22s   v1.27.8   172.18.1.51   <none>        Ubuntu 22.04.3 LTS   5.15.0-86-generic   containerd://1.6.25
# master2   Ready    control-plane   86s     v1.27.8   172.18.1.52   <none>        Ubuntu 22.04.3 LTS   5.15.0-86-generic   containerd://1.6.25
# master3   Ready    control-plane   36s     v1.27.8   172.18.1.53   <none>        Ubuntu 22.04.3 LTS   5.15.0-86-generic   containerd://1.6.25
```

### Add worker node(s)

exec command on worker server.

#### on worker1

```shell
cd compose/k8s/scripts
export VIP=172.18.1.15
export NODE_TYPE=worker
export NODE_NAME=worker1
export JOIN_TOKEN=gn9u9l.t0o3asqet6q7r5ki
export JOIN_HASH=e86812218d77f52ef59f549124f2fdc319c230d1b2ebcf60a2107e7bc5229047
make all
```

#### on worker2

```shell
cd compose/k8s/scripts
export VIP=172.18.1.15
export NODE_TYPE=worker
export NODE_NAME=worker2
export JOIN_TOKEN=gn9u9l.t0o3asqet6q7r5ki
export JOIN_HASH=e86812218d77f52ef59f549124f2fdc319c230d1b2ebcf60a2107e7bc5229047
make all
```

#### on worker3

```shell
cd compose/k8s/scripts
export VIP=172.18.1.15
export NODE_TYPE=worker
export NODE_NAME=worker3
export JOIN_TOKEN=gn9u9l.t0o3asqet6q7r5ki
export JOIN_HASH=e86812218d77f52ef59f549124f2fdc319c230d1b2ebcf60a2107e7bc5229047
make all
```

#### show nodes

```shell
kubectl get node -o wide

NAME      STATUS   ROLES           AGE   VERSION   INTERNAL-IP     EXTERNAL-IP   OS-IMAGE             KERNEL-VERSION      CONTAINER-RUNTIME
master1   Ready    control-plane   32m   v1.27.8   172.18.1.51     <none>        Ubuntu 22.04.3 LTS   5.15.0-86-generic   containerd://1.6.25
master2   Ready    control-plane   26m   v1.27.8   172.18.1.52     <none>        Ubuntu 22.04.3 LTS   5.15.0-86-generic   containerd://1.6.25
master3   Ready    control-plane   25m   v1.27.8   172.18.1.53     <none>        Ubuntu 22.04.3 LTS   5.15.0-86-generic   containerd://1.6.25
worker1   Ready    <none>          21m   v1.27.8   172.18.55.121   <none>        Ubuntu 22.04.3 LTS   5.15.0-86-generic   containerd://1.6.25
worker2   Ready    <none>          56s   v1.27.8   172.18.55.122   <none>        Ubuntu 22.04.3 LTS   5.15.0-86-generic   containerd://1.6.25
worker3   Ready    <none>          10s   v1.27.8   172.18.55.123   <none>        Ubuntu 22.04.3 LTS   5.15.0-86-generic   containerd://1.6.25
```
