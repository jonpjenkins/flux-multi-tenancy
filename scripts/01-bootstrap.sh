# 01-bootstrap.sh issues a flux bootstrap, then will pull any changes by by the flux system

# Bootstrap
flux bootstrap github \
  --context=minikube \
  --components-extra=image-reflector-controller,image-automation-controller \
  --owner=$GITHUB_USER \
  --interval=10s \
  --repository=flux-multi-tenancy \
  --branch=main \
  --path=./clusters/staging \
  --personal

# After things come up, then pull in the changes made by the flux system
git pull