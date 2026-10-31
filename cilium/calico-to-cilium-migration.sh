# Check the cluster context and inspect the existing Calico networking setup.
kubectl config current-context
kubectl get nodes -o wide
kubectl get pods -A
kubectl config current-context
clear
sudo ls -la /etc/cni/net.d/
sudo cat /etc/cni/net.d/10-calico.conflist
kubectl get ippools.crd.projectcalico.org -o wide
kubectl get ippool default-ipv4-ippool -o jsonpath='{.spec.cidr}{"\n"}'
kubectl get nodes -o custom-columns=NAME:.metadata.name,POD_CIDR:.spec.podCIDR
kubectl get node ip-172-31-39-134   -o jsonpath='{.spec.podCIDR}{"\n"}{.spec.podCIDRs}{"\n"}'

# Download and verify the Cilium CLI before making any cluster changes.
CILIUM_CLI_VERSION=$(curl -fsSL https://raw.githubusercontent.com/cilium/cilium-cli/main/stable.txt)
curl -L --fail -O   "https://github.com/cilium/cilium-cli/releases/download/${CILIUM_CLI_VERSION}/cilium-linux-amd64.tar.gz"
curl -L --fail -O   "https://github.com/cilium/cilium-cli/releases/download/${CILIUM_CLI_VERSION}/cilium-linux-amd64.tar.gz.sha256sum"
sha256sum --check cilium-linux-amd64.tar.gz.sha256sum
sudo tar xzvfC cilium-linux-amd64.tar.gz /usr/local/bin
cilium version

# Back up the current CNI configuration and save cluster state for migration.
sudo tar -czf /home/ubuntu/cni-backup.tar.gz   -C /etc/cni net.d
clear
mkdir -p /root/cilium-migration
cd /root/cilium-migration
kubectl get all -A -o yaml > workloads.yaml
kubectl get networkpolicy -A -o yaml > networkpolicies.yaml
kubectl get ippool default-ipv4-ippool -o yaml > calico-ippool.yaml
kubectl get nodes -o yaml > nodes.yaml
helm list -A
kubectl get ippool default-ipv4-ippool   -o jsonpath='IPIP={.spec.ipipMode} VXLAN={.spec.vxlanMode}{"\n"}'
kubectl get networkpolicy -A
kubectl get bgppeers.crd.projectcalico.org -A
kubectl get svc -A -o wide
ip route
free -h
test -f /home/ubuntu/calico.yaml && echo "Calico manifest found"
cd /root/cilium-migration

# Stage Cilium with custom CNI configuration so Calico remains active initially.
cat > values-migration.yaml <<'EOF'
operator:
  replicas: 1
  unmanagedPodWatcher:
    restart: false
routingMode: tunnel
tunnelProtocol: vxlan
tunnelPort: 8473
cni:
  customConf: true
  uninstall: false
ipam:
  mode: cluster-pool
  operator:
    clusterPoolIPv4PodCIDRList:
      - "10.245.0.0/16"
policyEnforcementMode: "never"
bpf:
  hostLegacyRouting: true
kubeProxyReplacement: false
EOF
ls
ls -lrt
cilium install 1.20.4   --values values-migration.yaml   --dry-run-helm-values > values-initial.yaml
helm repo add cilium https://helm.cilium.io/
helm repo update
helm install cilium cilium/cilium   --version 1.20.4   --namespace kube-system   --values values-initial.yaml
cilium status --wait
kubectl -n kube-system get daemonsets,deployments,pods

# Configure Cilium to write its CNI config, then opt the selected node into Cilium.
cat <<'EOF' | kubectl apply --server-side -f -
apiVersion: cilium.io/v2
kind: CiliumNodeConfig
metadata:
  namespace: kube-system
  name: cilium-default
spec:
  nodeSelector:
    matchLabels:
      io.cilium.migration/cilium-default: "true"
  defaults:
    write-cni-conf-when-ready: /host/etc/cni/net.d/05-cilium.conflist
    custom-cni-conf: "false"
    cni-chaining-mode: "none"
    cni-exclusive: "true"
EOF
NODE=ip-172-31-39-134
kubectl label node "$NODE"   --overwrite   io.cilium.migration/cilium-default=true
kubectl -n kube-system delete pod   --field-selector spec.nodeName="$NODE"   -l k8s-app=cilium
kubectl -n kube-system rollout status ds/cilium   --timeout=180s
sudo ls -la /etc/cni/net.d/
cd /root/cilium-migration

# Switch Cilium to its final CNI and policy settings across the cluster.
cilium install 1.20.4   --values values-initial.yaml   --dry-run-helm-values   --set operator.unmanagedPodWatcher.restart=true   --set cni.customConf=false   --set policyEnforcementMode=default   > values-final.yaml
helm upgrade cilium cilium/cilium   --namespace kube-system   --version 1.20.4   --values values-final.yaml
kubectl -n kube-system rollout restart daemonset/cilium
cilium status --wait
kubectl delete -n kube-system   ciliumnodeconfig cilium-default
cilium status
kubectl get pods -A -o wide
kubectl get ciliumendpoints -A

# Remove Calico after checking Cilium, then verify the resulting cluster state.
kubectl delete -f /home/ubuntu/calico.yaml
clear
kubectl -n kube-system get daemonsets,deployments
sudo ls -la /etc/cni/net.d/
clear
kubectl get all --all-namespaces
clear

# Enable Hubble and run connectivity checks after the CNI migration.
cilium hubble enable --ui
cilium status --wait
kubectl -n kube-system get pods,deploy,ds,svc
cilium hubble ui
cilium connectivity test --single-node
clear
kubectl get ciliumnodes
kubectl get ciliumendpoints -A
kubectl get ciliumidentities
kubectl get ciliumclusterwidenetworkpolicies
kubectl -n kube-system get daemonsets,deployments
