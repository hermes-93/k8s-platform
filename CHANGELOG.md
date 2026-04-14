# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.0.0] - 2026-04-15

### Added
- App-of-Apps ArgoCD pattern with dev / staging / prod clusters
- `charts/webapp` Helm chart: Deployment, HPA v2, PDB, ServiceMonitor, Ingress
- Kustomize overlays for all three environments
- Infrastructure applications: cert-manager, ingress-nginx, kube-prometheus-stack, Loki, Grafana
- `scripts/bootstrap.sh` for one-shot cluster provisioning
- GitHub Actions `validate.yml`: helm lint, kustomize build, kubeconform, Checkov SARIF
- Kyverno ClusterPolicies: disallow-privilege-escalation, require-resource-limits,
  disallow-latest-tag, require-run-as-non-root, require-app-labels
- Architecture documentation with Mermaid diagrams

### Security
- Pod Security Standards (Restricted profile) enforced via Kyverno
- All workloads run as non-root (UID 1000), readOnlyRootFilesystem, drop ALL capabilities
- Image digest pinning required in production namespace
- Checkov SARIF results uploaded to GitHub Security tab on every push

[Unreleased]: https://github.com/hermes-93/k8s-platform/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/hermes-93/k8s-platform/releases/tag/v1.0.0
