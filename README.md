# Internal Developer Platform (IDP) on AWS + Kubernetes

## Overview

A self-service Internal Developer Platform: push code, and a pipeline
builds it, packages it, deploys it to Kubernetes with health checks and
autoscaling, and exposes metrics — all without the developer touching
AWS or `kubectl` directly.

```
Code → Build → Container → Registry → Helm Deploy → K8s (dev/stage) → Metrics
```

---

## Problem Statement

In traditional workflows:

* Developers manually build Docker images
* Deploy applications using manual Kubernetes commands
* Require direct access to infrastructure

This results in slower deployment cycles, more room for human error, and
no standardization across environments.

---

## Solution

* Developers push code to a repository
* A CI/CD pipeline automates build and deployment
* Applications are deployed to Kubernetes via Helm — no manual `kubectl`
* The same chart deploys to `dev` and `stage` with different values

---

## Architecture

```
Developer
   │
   ▼
GitHub Repository (branch: main → dev, stage → stage)
   │
   ▼
GitHub Actions (build → push → helm upgrade --install)
   │
   ▼
GHCR (image tagged :latest and :<commit-sha>)
   │
   ▼
Kubernetes (k3s on EC2, EKS-compatible manifests)
   │
   ▼
Deployment → HPA → Service → Ingress
   │
   ▼
Prometheus / Grafana (stage)
```

See [`docs/architecture.md`](docs/architecture.md) for the full design
rationale, including known limitations.

---

## Technology Stack

* **Infrastructure**: Terraform (VPC, subnets, EC2 node running k3s)
* **Containerization**: Docker
* **Packaging**: Helm
* **CI/CD**: GitHub Actions
* **Container Registry**: GitHub Container Registry (GHCR)
* **Orchestration**: Kubernetes (k3s)
* **Autoscaling**: HorizontalPodAutoscaler (CPU + memory)
* **Access Control**: Kubernetes RBAC (scoped developer + CI roles)
* **Monitoring**: Prometheus + Grafana (`kube-prometheus-stack`)
* **Web Server**: Nginx

---

## CI/CD Pipeline Flow

1. Code is pushed to `main` or `stage`
2. GitHub Actions builds the Docker image, tagged with the commit SHA
3. Image is pushed to GHCR
4. Namespaces and RBAC are applied
5. `helm upgrade --install` deploys with environment-specific values
6. `kubectl rollout status` verifies the deploy actually succeeded before
   the pipeline reports success

---

## Repository Layout

```
apps/demo-app/        # nginx app + Dockerfile + nginx.conf (stub_status enabled)
infra/terraform/       # VPC, subnet, EC2 node running k3s
infra/helm/idp-demo/    # Helm chart (values.yaml + values-dev/stage.yaml)
k8s/platform/           # namespace + RBAC (kept as a Helm-free quickstart too)
monitoring/             # kube-prometheus-stack values + install instructions
.github/workflows/      # CI/CD pipeline
docs/architecture.md    # design rationale + known limitations
```

---

## How to Run Locally

1. Start Kubernetes:

```bash
minikube start
kubectl config use-context minikube
```

2. Apply namespaces and RBAC:

```bash
kubectl apply -f k8s/platform/namespace.yaml -f k8s/platform/rbac.yaml
```

3. Deploy with Helm:

```bash
helm upgrade --install idp-demo ./infra/helm/idp-demo \
  -n dev -f infra/helm/idp-demo/values-dev.yaml
```

4. Access the application:

```bash
kubectl port-forward -n dev svc/idp-demo 8080:80
# open http://localhost:8080
```

5. (Optional) Install monitoring — see [`monitoring/README.md`](monitoring/README.md).

---

## Provisioning Real Infrastructure (AWS)

```bash
cd infra/terraform
terraform init
terraform apply
```

This provisions a VPC, subnets, and a single EC2 instance that bootstraps
`k3s` on boot. Terraform auto-generates its own SSH key pair — no manual
key file needed. Grab the node's kubeconfig over SSH
(`/etc/rancher/k3s/k3s.yaml` on the instance) to point `kubectl`/`helm` at
it, or to populate the pipeline's `KUBE_CONFIG` secret (base64-encoded).

By default, SSH is open to `0.0.0.0/0` for demo convenience — override
`allowed_ssh_cidr` with your own IP before leaving this running.

---

## Autoscaling

The `HorizontalPodAutoscaler` scales `idp-demo` between `minReplicas` and
`maxReplicas` based on CPU and memory utilization (thresholds are
per-environment in `values-dev.yaml` / `values-stage.yaml`). Requires
`metrics-server` running in the cluster (k3s ships it by default).

```bash
kubectl get hpa -n dev
```

---

## Access Control (RBAC)

* `developer-role` — read-only: pods, logs, deployments, services.
  Engineers can inspect what's running but can't change it directly.
* `ci-deployer-role` — the identity the pipeline authenticates as,
  scoped only to the resources it manages (deployments, services,
  ingresses, HPAs) — not cluster-admin.

See [`k8s/platform/rbac.yaml`](k8s/platform/rbac.yaml).

---

## Rollback

```bash
helm rollback idp-demo -n dev
# or, without Helm:
kubectl rollout undo deployment/idp-demo -n dev
```

---

## Observability

```bash
kubectl logs -n dev -l app=idp-demo
kubectl rollout status deployment/idp-demo -n dev
kubectl get hpa -n dev
```

With monitoring installed (see [`monitoring/README.md`](monitoring/README.md)):

```bash
kubectl port-forward -n monitoring svc/kube-prometheus-stack-grafana 3000:80
```

---

## Demonstration Flow

1. Modify application code in `apps/demo-app/`
2. Push to `main` (dev) or `stage`
3. Pipeline builds, pushes, and deploys via Helm
4. `kubectl rollout status` confirms the new version is live
5. Check Grafana (if installed) for updated metrics

---

## Key Outcomes

* Self-service, push-to-deploy CI/CD workflow via GitHub Actions + Helm
* Multi-environment deployment (dev/stage) from one Helm chart
* Health checks (liveness/readiness), rolling updates, and rollback
* Horizontal Pod Autoscaling on CPU + memory
* RBAC separating developer read-access from pipeline deploy-access
* Prometheus/Grafana metrics pipeline

---

## Resume Summary

Built a self-service Internal Developer Platform using Terraform,
Kubernetes, Helm, and GitHub Actions — enabling push-to-deploy workflows
across dev/stage environments with automated health checks, horizontal
autoscaling, scoped RBAC, and Prometheus/Grafana monitoring.

---

## Possible Next Steps

* GitOps (ArgoCD/Flux) instead of a push-based pipeline
* A real staging→production promotion gate (manual approval step)
* Terraform remote state backend (S3 + DynamoDB lock) for team use
* Application-level metrics, not just nginx request counts

---

## Author

Abinaya
Cloud and DevOps Enthusiast

---

## Conclusion

This platform demonstrates the path from a basic CI/CD pipeline to a
self-service developer platform: automated builds, environment-aware
deployments via Helm, autoscaling, access control, and observability —
all triggered by nothing more than a `git push`.
