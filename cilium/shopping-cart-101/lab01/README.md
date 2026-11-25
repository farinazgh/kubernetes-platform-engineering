# Lab 01 — Unrestricted Network Connectivity

Establish the Shopping Cart 101 baseline on a
Cilium-managed Kubernetes cluster before introducing
network policies.

## Architecture

```mermaid
flowchart TD
    subgraph K8S["Kubernetes cluster — Cilium CNI"]
        subgraph NS["Namespace: shopping-cart"]
            SF["storefront Deployment<br/>4 pods | org=commerce"]
            AW["analytics-worker Deployment<br/>3 pods | org=analytics"]
            SVC["cart-api Service<br/>ClusterIP | TCP/80"]
            subgraph API["cart-api Deployment — org=commerce"]
                P1[cart-api pod 1]
                P2[cart-api pod 2]
                P3[cart-api pod 3]
            end
            SF -->|HTTP| SVC
            AW -->|HTTP| SVC
            SVC --> P1
            SVC --> P2
            SVC --> P3
        end
    end
    classDef default fill:#FFFFFF,stroke:#888888,color:#888888;
    style K8S fill:#FFFFFF,stroke:#888888,color:#888888
    style NS fill:#FFFFFF,stroke:#888888,color:#888888
    style API fill:#FFFFFF,stroke:#888888,color:#888888
    linkStyle default stroke:#888888,color:#888888
```

## Deploy

Run from the repository root:

```bash
kubectl apply -f lab01/01-namespace.yaml
kubectl apply -f lab01/02-cart-api.yaml
kubectl apply -f lab01/03-clients.yaml
kubectl get pods,svc -n shopping-cart
```

## Test connectivity

```bash
kubectl exec -n shopping-cart deploy/storefront -- \
  curl -i http://cart-api/v1/cart

kubectl exec -n shopping-cart deploy/analytics-worker -- \
  curl -i http://cart-api/v1/cart
```

Both clients can also invoke:

- POST /v1/cart/items
- PUT /v1/cart/discount

## Expected outcome

- Ten running pods across three Deployments.
- Both clients can reach the cart API.
- All supported HTTP operations return HTTP 200.
- East-West communication within the cluster.
- Unrestricted connectivity, assuming default Cilium
  enforcement and no other applicable policies.

The cart API is a stateless mock.

Keep all resources running for Lab 02:
L3 identity-based network policy.