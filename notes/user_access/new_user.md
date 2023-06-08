# Create a new admin user
This is to access cluster from laptop.
Also the new context can be used to setup https://app.k8slens.dev/subscribe
1. Make sure to remove old records from known hosts `~/.ssh/known_hosts`
2. `ssh jay@192.168.193.20`
3. Create a private key following instructions here https://kubernetes.io/docs/reference/access-authn-authz/certificate-signing-requests/#normal-user
```
openssl genrsa -out jay-proxmox.key 2048
openssl req -new -key jay-proxmox.key -out jay-proxmox.csr
```
4. Create a CSR, request and approve
```
apiVersion: certificates.k8s.io/v1
kind: CertificateSigningRequest
metadata:
  name: jay-proxmox
spec:
  request: "<output of cat jay-proxmox.csr | base64 | tr -d "\n">
  signerName: kubernetes.io/kube-apiserver-client
  expirationSeconds: 31557600  # one year
  usages:
  - client auth
```
```
kubectl certificate approve jay-proxmox
```

5. Export the signed cert
```
kubectl get csr jay-proxmox -o jsonpath='{.status.certificate}'| base64 -d > jay-proxmox.crt
```
6. Create a `clusterrolebinding` to existing `admin` clusterrole
```
kubectl create clusterrolebinding admin-binding-jay --clusterrole=cluster-admin --user=jay-proxmox
```
7. Update the kubeconfig and context
```
kubectl config set-credentials jay-proxmox --client-key=jay-proxmox.key --client-certificate=jay-proxmox.crt --embed-certs=true
```
```
kubectl config set-context jay-proxmox --cluster=kubernetes --user=jay-proxmox
```
8. Update the kube config on the laptop with the new config data