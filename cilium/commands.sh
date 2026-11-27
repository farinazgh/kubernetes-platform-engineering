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

 # after applying the Cilium NetworkPolicy, the following command failed with a 403 Forbidden error
kubectl exec -n shopping-cart deploy/analytics-worker -- curl --max-time 5 -i http://cart-api/v1/cart
CART_IP=$(kubectl get pod -n shopping-cart cart-api-f9775db54-b4d22 -o jsonpath='{.status.podIP}')
kubectl exec -n shopping-cart deploy/storefront -- curl --max-time 5 -i http://$CART_IP:8080
kubectl exec -n shopping-cart cart-api-f9775db54-b4d22 -- python -m http.server 8080 --bind 0.0.0.0
kubectl exec -n shopping-cart deploy/analytics-worker -- curl --max-time 5 -i http://cart-api/v1/cart