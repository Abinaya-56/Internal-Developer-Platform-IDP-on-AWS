# Architecture — Internal Developer Platform (IDP)

## Goal
Provide a self-service deployment platform where developers push code and
get a running, monitored, auto-scaled application — without touching AWS
or Kubernetes directly.

## High-Level Design
All infrastructure provisioning, application builds, and deployments are
executed through automated pipelines only.

## Tooling Decisions (Cost-Free Strategy)

- **Terraform** provisions the underlying compute (VPC, subnets, a single
  EC2 node) and is the source of truth for infrastructure state. It targets
  a cost-free footprint: one `t2.micro` instance rather than a managed EKS
  control plane, since EKS bills per-cluster-hour regardless of workload.
- **k3s** (a lightweight, certified Kubernetes distribution) runs on that
  EC2 node. Because it speaks the standard Kubernetes API, the manifests
  and Helm chart in this repo are portable to EKS or any other conformant
  cluster with no changes — swapping the Terraform target is the only
  work required to move from this cost-free setup to a managed cluster.
- **GitHub Actions** is both the pipeline trigger and the execution engine
  — it builds the image, pushes it, and deploys it. There's no separate
  Jenkins or other CI server; GitHub Actions' hosted runners are the only
  compute the pipeline itself uses.
- **Helm** packages the application so the same chart deploys to `dev` and
  `stage` with different `values-*.yaml` overrides (replica count,
  resource limits, autoscaling thresholds, metrics).
- **GitHub Container Registry (GHCR)** stores container images, tagged
  both `latest` and by short commit SHA for traceability and rollback.

## Platform Flow

1. Developer pushes code to `main` (→ `dev`) or `stage` (→ `stage`)
2. GitHub Actions triggers automatically
3. Docker image is built and tagged with the commit SHA
4. Image is pushed to GHCR
5. Namespaces and RBAC are applied
6. `helm upgrade --install` deploys the app with environment-specific values
7. Liveness/readiness probes gate traffic; `kubectl rollout status` confirms
   the deployment succeeded before the pipeline reports success
8. A failed or unhealthy rollout can be reverted with `helm rollback` or
   `kubectl rollout undo`
9. Prometheus scrapes app metrics (enabled in `stage`); Grafana visualizes them

## Kubernetes Components

- Namespaces: `dev`, `stage`
- Deployment with rolling updates (`maxUnavailable: 0`) and health probes
- HorizontalPodAutoscaler scaling on CPU + memory utilization
- Service (ClusterIP) and Ingress per environment
- RBAC: a read-only `developer-role` for engineers to inspect workloads,
  and a narrowly-scoped `ci-deployer-role` the pipeline authenticates as
  instead of a cluster-admin kubeconfig

## Access Control Rules

- Developers have no direct AWS access
- Developers have no `kubectl apply`/`create`/`delete` access — only
  read access to pods, logs, deployments, and services for debugging
- All changes to running workloads happen through the CI/CD pipeline,
  which itself is scoped to the specific resources it needs to manage
  (deployments, services, ingresses, HPAs) rather than full cluster admin

## Known Limitations (worth knowing before you demo this)

- Single EC2 node — no high availability at the infrastructure layer.
  This is a deliberate cost/scope tradeoff for a portfolio project, not
  a production posture.
- No automated Terraform state backend configured (state is local by
  default) — fine for a solo demo, not for team use.
- The metrics pipeline reports nginx-level request stats via
  `nginx-prometheus-exporter`, not application-level business metrics.
