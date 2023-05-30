# more info
# https://metallb.universe.tf/installation/

# 1. see what changes would be made, returns nonzero returncode if different
kubectl get configmap kube-proxy -n kube-system -o yaml | \
sed -e "s/strictARP: false/strictARP: true/" | \
kubectl diff -f - -n kube-system

# 2. actually apply the changes, returns nonzero returncode on errors only
kubectl get configmap kube-proxy -n kube-system -o yaml | \
sed -e "s/strictARP: false/strictARP: true/" | \
kubectl apply -f - -n kube-system

# 3. deploy using manifest
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.13.9/config/manifests/metallb-native.yaml

# 4. define IPs to LB service
kubectl apply -f metallb-ips.yaml

# 5. layer 2 configuraion
# more info https://metallb.universe.tf/configuration/#layer-2-configuration
kubectl apply -f metallb-layer2.yaml