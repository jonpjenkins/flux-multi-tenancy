# 04-teardown.sh will attempt to start out with a "clean" environment, which involves:
#  * running a `flux uninstall`
#  * removing components of the clusters/minikube so there are not race conditions


# Issue a flux uninstall
echo 'y' | flux uninstall || true; echo "flux uninstalled"

# Remove components that will be re-created later
rm -rf clusters/staging/flux-system clusters/staging/alerts.yaml clusters/staging/slack-url-sealed.yaml pub-sealed-secrets.pem

# Commit and push these changes
git add . && git commit -m'removing of flux components' && git push

kubectl --context=minikube delete namespace apps || true
kubectl --context=minikube delete namespace kyverno || true
