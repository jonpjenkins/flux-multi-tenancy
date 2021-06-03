# 05-curl-test.sh opens a port-forward tunnel to the webserver svc and issues a curl

# background port forward
kubectl port-forward --context=minikube -n apps svc/gowebserver-helm-chart-demo 8080:8080 &> /dev/null &

# Allow the port forward to come up
sleep 2

# Issue curl
curl localhost:8080

# kill backgrounded port forward
killall kubectl port-forward &> /dev/null || true