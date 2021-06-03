# 04-slack-integration.sh sets up github auth for the flux-system
# based on a user's GITHUB_TOKEN env var. This process creates a file
# that is safe to store in git
# via https://fluxcd.io/docs/guides/sealed-secrets/

# Install kubeseal
flux create source helm sealed-secrets \
--interval=1h \
--url=https://bitnami-labs.github.io/sealed-secrets

flux create helmrelease sealed-secrets \
--interval=1h \
--release-name=sealed-secrets \
--target-namespace=flux-system \
--source=HelmRepository/sealed-secrets \
--chart=sealed-secrets \
--chart-version=">=1.15.0-0" \
--crds=CreateReplace

kubeseal --fetch-cert \
--controller-name=sealed-secrets \
--controller-namespace=flux-system \
> pub-sealed-secrets.pem

kubectl -n flux-system create secret generic slack-url \
--from-literal=address=$FLUX_SYSTEM_WEBHOOK \
--dry-run=client \
-o yaml > slack-url.yaml

kubeseal --format=yaml --cert=./pub-sealed-secrets.pem \
< slack-url.yaml > clusters/staging/slack-url-sealed.yaml

rm slack-url.yaml

cat <<EOF > clusters/staging/alerts.yaml
apiVersion: notification.toolkit.fluxcd.io/v1beta1
kind: Provider
metadata:
  name: slack
  namespace: flux-system
spec:
  type: slack
  channel: general
  secretRef:
    name: slack-url
---
apiVersion: notification.toolkit.fluxcd.io/v1beta1
kind: Alert
metadata:
  name: on-call-webapp
  namespace: flux-system
spec:
  providerRef:
    name: slack
  eventSeverity: info
  eventSources:
    - kind: GitRepository
      name: '*'
    - kind: Kustomization
      name: '*'
EOF

git add pub-sealed-secrets.pem clusters; git commit -m'sealed secretfor github'; git push