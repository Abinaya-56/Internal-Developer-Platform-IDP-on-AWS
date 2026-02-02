# Architecture — Internal Developer Platform (IDP) on AWS

## Goal
Provide a self-service deployment platform where developers deploy applications
without direct access to AWS or Kubernetes.

## High-Level Design
All infrastructure provisioning, application builds, and deployments are
executed through automated pipelines only.

## Tooling Decisions (Cost-Free Strategy)

- Terraform is used for infrastructure definition and lifecycle control.
- AWS is the target cloud environment; EKS infrastructure is defined but not continuously provisioned to avoid cost.
- Kubernetes workloads are executed on local k3s while maintaining EKS-compatible manifests.
- GitHub Actions is used as the pipeline trigger.
- Jenkins runs as a containerized, ephemeral automation engine invoked by the pipeline.
- No long-running Jenkins server or EC2 instance is used.
- Container images are stored in GitHub Container Registry (GHCR).

## Platform Flow

1. Developer pushes code to GitHub
2. Pipeline triggers automatically
3. Terraform validates infrastructure state
4. Application is built into a Docker image
5. Image is versioned and pushed to GHCR
6. Kubernetes deployment is executed via pipeline
7. Health checks validate deployment
8. Failure triggers automated rollback
9. Logs and metrics are collected

## Access Control Rules

- Developers have no direct AWS access
- Developers have no direct Kubernetes access
- All actions are pipeline-driven
