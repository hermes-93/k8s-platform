#!/usr/bin/env bash
# Bootstrap ArgoCD and apply the root app-of-apps for a given environment.
# Usage: ./scripts/bootstrap.sh <env>   (env = dev | staging | prod)

set -euo pipefail

ENV="${1:-dev}"
ARGOCD_NS="argocd"
ARGOCD_VERSION="v2.10.5"

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; NC='\033[0m'
info()  { echo -e "${GREEN}[INFO]${NC}  $*"; }
warn()  { echo -e "${YELLOW}[WARN]${NC}  $*"; }
error() { echo -e "${RED}[ERROR]${NC} $*" >&2; exit 1; }

# Validate environment
case "$ENV" in
  dev|staging|prod) ;;
  *) error "Unknown environment '$ENV'. Use: dev | staging | prod" ;;
esac

info "Bootstrapping k8s-platform in environment: $ENV"

# --- Prerequisites check ---
for cmd in kubectl helm kustomize argocd; do
  command -v "$cmd" &>/dev/null || error "Required tool not found: $cmd"
done

CLUSTER=$(kubectl config current-context)
warn "Target cluster: $CLUSTER"
read -r -p "Continue? [y/N] " confirm
[[ "$confirm" =~ ^[Yy]$ ]] || { info "Aborted."; exit 0; }

# --- Install ArgoCD ---
if kubectl get namespace "$ARGOCD_NS" &>/dev/null; then
  info "Namespace $ARGOCD_NS already exists, skipping install"
else
  info "Installing ArgoCD $ARGOCD_VERSION..."
  kubectl create namespace "$ARGOCD_NS"
  kubectl apply -n "$ARGOCD_NS" \
    -f "https://raw.githubusercontent.com/argoproj/argo-cd/${ARGOCD_VERSION}/manifests/install.yaml"

  info "Waiting for ArgoCD to be ready..."
  kubectl rollout status deployment/argocd-server -n "$ARGOCD_NS" --timeout=120s
fi

# --- Apply root app ---
info "Applying root app-of-apps for $ENV..."
kubectl apply -f "clusters/${ENV}/root-app.yaml"

# --- Print access info ---
info "Done! Get the initial admin password with:"
echo "  kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d"
echo ""
info "Port-forward ArgoCD UI:"
echo "  kubectl port-forward svc/argocd-server -n argocd 8080:443"
echo "  https://localhost:8080  (admin / <password above>)"
