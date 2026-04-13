# k8s-platform

Production-grade Kubernetes Internal Developer Platform built with GitOps principles.

## Stack

| Layer | Tool |
|-------|------|
| GitOps engine | ArgoCD (app-of-apps pattern) |
| Packaging | Helm 3 + Kustomize overlays |
| Environments | dev / staging / prod |
| Ingress | ingress-nginx + cert-manager (Let's Encrypt) |
| Secrets | External Secrets Operator + HashiCorp Vault |
| Observability | Prometheus + Grafana + Loki + OpenTelemetry |
| Autoscaling | HPA + KEDA |
| Policy | OPA Gatekeeper |

## Repository structure

```
k8s-platform/
├── apps/                    # ArgoCD Application manifests
│   ├── base/                # Base Kustomize configs
│   └── overlays/            # Per-environment patches
│       ├── dev/
│       ├── staging/
│       └── prod/
├── clusters/                # Bootstrap entry point (app-of-apps)
│   ├── dev/
│   ├── staging/
│   └── prod/
├── charts/                  # Custom Helm charts
│   └── webapp/              # Generic web application chart
├── infrastructure/          # Platform-level services
│   ├── cert-manager/
│   ├── ingress-nginx/
│   └── monitoring/          # Prometheus stack, Loki, Grafana
├── scripts/                 # Cluster bootstrap & maintenance scripts
└── docs/                    # Architecture decisions, runbooks
```

## Environments

```
dev      → fast feedback, relaxed limits, auto-sync
staging  → production-mirror, manual sync gate
prod     → blue-green deployments, PDB enforced, alerts active
```

## Quick start

### Prerequisites

```bash
# Tools required
kubectl >= 1.28
helm >= 3.14
argocd CLI >= 2.10
kustomize >= 5.3
```

### Bootstrap a cluster

```bash
# 1. Install ArgoCD
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# 2. Apply the root app-of-apps
kubectl apply -f clusters/dev/root-app.yaml

# 3. ArgoCD will reconcile the rest automatically
argocd app list
```

### Deploy an application

```bash
# Add your app manifest under apps/base/
# Create an overlay under apps/overlays/<env>/
# Commit and push — ArgoCD syncs automatically (dev) or on approval (prod)
```

## Helm chart: webapp

A generic Helm chart for stateless web workloads. Supports:

- Deployment with configurable replicas / resource limits
- HorizontalPodAutoscaler
- Ingress with TLS via cert-manager annotation
- PodDisruptionBudget
- ConfigMap + Secret refs
- ServiceMonitor for Prometheus scraping

```bash
helm install my-app charts/webapp \
  --namespace my-namespace \
  -f charts/webapp/values.yaml \
  -f apps/overlays/prod/my-app-values.yaml
```

## Observability

Grafana dashboards are stored as JSON in `infrastructure/monitoring/grafana/dashboards/`.  
All dashboards are provisioned automatically via ConfigMap on deploy.

| Dashboard | What it shows |
|-----------|--------------|
| cluster-overview | Node CPU/mem, pod counts, restarts |
| webapp-service | RPS, latency p50/p95/p99, error rate |
| argocd | Sync status, health, deploy frequency |

## Security

- All workloads run as non-root (`runAsNonRoot: true`)
- Read-only root filesystem where possible
- Network policies: default-deny + explicit allow rules
- Image scanning in CI via Trivy (blocks on CRITICAL)
- Secrets never stored in git — managed via External Secrets Operator

## License

MIT
