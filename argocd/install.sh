kubectl taint nodes --all node-role.kubernetes.io/control-plane-

kubectl create namespace argocd
kubectl apply -n argocd --server-side --force-conflicts -f https://raw.githubusercontent.com/argoproj/argo-cd/v3.5.6/manifests/install.yaml
kubectl get pods -n argocd -o wide

kubectl get all -n argocd
  