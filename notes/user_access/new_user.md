# Create a new admin user
This is to access cluster from laptop.
Also the new context can be used to setup https://app.k8slens.dev/subscribe
1. Make sure to remove old records from known hosts `~/.ssh/known_hosts`
2. `ssh jay@192.168.193.20`
3. Create a private key following instructions here https://kubernetes.io/docs/reference/access-authn-authz/certificate-signing-requests/#normal-user
4. Create a CSR, request and approve
```
apiVersion: certificates.k8s.io/v1
kind: CertificateSigningRequest
metadata:
  name: jay-proxmox
spec:
  request: <output of cat myuser.csr | base64 | tr -d "\n">
  signerName: kubernetes.io/kube-apiserver-client
  expirationSeconds: 31557600  # one year
  usages:
  - client auth
```

5. Create a cluster role, `jay-proxmox`
6. Bind it to