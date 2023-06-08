### https://docs.cilium.io/en/stable/gettingstarted/k8s-install-default/

## Install Cilium CLI
```
wget https://github.com/cilium/cilium-cli/releases/latest/download/cilium-linux-amd64.tar.gz

sudo tar xzvfC cilium-linux-amd64.tar.gz /usr/local/bin

```

## Install Cilium
```
cilium install
```

## Verify
```
cilium status
```
