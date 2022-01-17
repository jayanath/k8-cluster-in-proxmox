# etcd backup and restore process
```sudo apt install etcd-client

ETCDCTL_API=3 etcdctl version
Output should looks like:
    etcdctl version: 3.2.26
    API version: 3.2

Find trusted-ca-file, cert-file and key-file
From /etc/kubernetes/manifests/etcd.yaml OR using kubectl describe pod etcd-master.example.com -n kube-system

From https://kubernetes.io/docs/tasks/administer-cluster/configure-upgrade-etcd/
ETCDCTL_API=3 etcdctl --endpoints=https://127.0.0.1:2379 \
  --cacert=<trusted-ca-file> --cert=<cert-file> --key=<key-file> \
  snapshot save <backup-file-location>

sudo ETCDCTL_API=3 etcdctl member list \
--cacert=/etc/kubernetes/pki/etcd/ca.crt \
--cert=/etc/kubernetes/pki/etcd/server.crt \
--key=/etc/kubernetes/pki/etcd/server.key \
--endpoints=https://127.0.0.1:2379 \
--write-out=table

sudo ETCDCTL_API=3 etcdctl \
--endpoints=https://127.0.0.1:2379 \
--cacert=/etc/kubernetes/pki/etcd/ca.crt \
--cert=/etc/kubernetes/pki/etcd/server.crt \
--key=/etc/kubernetes/pki/etcd/server.key \
snapshot save /tmp/snapshotdb

sudo ETCDCTL_API=3 etcdctl --write-out=table snapshot status /tmp/snapshotdb

## Rename the static pod files at /etc/kubernetes/manifests
sudo mv kube-apiserver.yaml kube-apiserver.yaml.back
sudo mv kube-controller-manager.yaml kube-controller-manager.yaml.back
sudo mv kube-scheduler.yaml kube-scheduler.yaml.back

sudo ETCDCTL_API=3 etcdctl \
snapshot restore /tmp/snapshotdb \
--endpoints=https://127.0.0.1:2379 \
--cacert=/etc/kubernetes/pki/etcd/ca.crt \
--cert=/etc/kubernetes/pki/etcd/server.crt \
--key=/etc/kubernetes/pki/etcd/server.key \
--data-dir="/var/lib/etcd-from-backup" \
--initial-advertise-peer-urls="https://127.0.0.1:2380" \
--initial-cluster="master.example.com=https://127.0.0.1:2380" \
--initial-cluster-token="etcd-cluster-1" \
--name="master.example.com" \
--skip-hash-check=true

Update etcd.yaml file with proper data_dir value

sudo mv kube-apiserver.yaml.back kube-apiserver.yaml
sudo mv kube-controller-manager.yaml.back kube-controller-manager.yaml
sudo mv kube-scheduler.yaml.back kube-scheduler.yaml


