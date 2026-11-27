kubectl get endpointslices -n shopping-cart

kubectl exec -n shopping-cart deploy/storefront -- curl -i http://cart-api/v1/cart

kubectl exec -n shopping-cart deploy/storefront -- curl -i -X POST http://cart-api/v1/cart/items


kubectl exec -n shopping-cart deploy/storefront -- curl -i -X PUT http://cart-api/v1/cart/discount

kubectl exec -n shopping-cart deploy/analytics-worker -- curl -i http://cart-api/v1/cart

kubectl exec -n shopping-cart deploy/analytics-worker -- curl -i http://cart-api/v1/cart


kubectl exec -n shopping-cart deploy/analytics-worker -- curl -i -X POST http://cart-api/v1/cart/items

kubectl exec -n shopping-cart deploy/analytics-worker -- curl -i -X PUT http://cart-api/v1/cart/discount


kubectl exec -n shopping-cart deploy/storefront -- \
 sh -c 'for i in $(seq 1 10); do
 curl -s http://cart-api/v1/cart
 echo
 done'

 # after applying the Cilium NetworkPolicy, the following command  failed with a 403 Forbidden error
kubectl exec -n shopping-cart deploy/analytics-worker -- curl --max-time 5 -i http://cart-api/v1/cart
