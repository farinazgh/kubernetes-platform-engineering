helm version
helm list -A
kubectl get nodes
kubectl describe node ip-172-31-39-134 | grep Taints
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
helm upgrade --install monitoring prometheus-community/kube-prometheus-stack --namespace monitoring --create-namespace
