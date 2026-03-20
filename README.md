# Internal Developer Platform (IDP) on Kubernetes

## Overview

This project demonstrates a self-service Internal Developer Platform (IDP) that enables developers to deploy applications through a simple code push.

The platform automates the complete workflow:
Code → Build → Container → Registry → Kubernetes Deployment

It eliminates manual infrastructure handling and direct interaction with Kubernetes.

---

## Problem Statement

In traditional workflows:

* Developers manually build Docker images
* Deploy applications using manual Kubernetes commands
* Require direct access to infrastructure

This results in:

* Slower deployment cycles
* Increased risk of human error
* Lack of standardization

---

## Solution

This project implements a pipeline-driven platform where:

* Developers push code to a repository
* A CI/CD pipeline automates build and deployment
* Applications are deployed to Kubernetes without manual steps

---

## Architecture

```
Developer
   │
   ▼
GitHub Repository
   │
   ▼
GitHub Actions (CI/CD Pipeline)
   │
   ▼
Docker Image Build
   │
   ▼
GitHub Container Registry (GHCR)
   │
   ▼
Kubernetes Cluster (Minikube)
   │
   ▼
Deployment → Pods → Service → Ingress
```

---

## Technology Stack

* Infrastructure: Terraform (design-level implementation on AWS)
* Containerization: Docker
* CI/CD: GitHub Actions
* Container Registry: GitHub Container Registry (GHCR)
* Orchestration: Kubernetes (Minikube)
* Web Server: Nginx

---

## CI/CD Pipeline Flow

1. Code is pushed to GitHub
2. GitHub Actions pipeline is triggered
3. Docker image is built
4. Image is pushed to GHCR
5. Kubernetes deployment is updated
6. Application is deployed automatically

---

## Kubernetes Components

* Namespaces for environment isolation (dev, stage)
* Deployment for managing application pods
* Service for internal networking
* Ingress for external access
* Resource limits for CPU and memory management

---

## Production-Oriented Features

* Rolling update deployment strategy
* Liveness and readiness probes
* Automatic restart of failed containers
* Rollback capability
* Basic log monitoring

---

## Deployment Strategy

Rolling updates ensure:

* Zero downtime deployments
* Controlled replacement of application instances
* Stable release transitions

---

## Rollback Capability

```
kubectl rollout undo deployment/demo-app -n dev
```

---

## Observability

Application logs:

```
kubectl logs -n dev -l app=demo-app
```

Deployment status:

```
kubectl rollout status deployment/demo-app -n dev
```

---

## How to Run Locally

1. Start Kubernetes:

```
minikube start
kubectl config use-context minikube
```

2. Deploy platform components:

```
kubectl apply -f k8s/platform/
```

3. Access the application:

```
minikube service demo-service -n dev
```

---

## Demonstration Flow

1. Modify application code
2. Push changes to GitHub
3. Pipeline builds and pushes Docker image
4. Kubernetes deploys the updated version
5. Application reflects changes automatically

---

## Key Outcomes

* Built a self-service deployment platform
* Implemented push-to-deploy CI/CD workflow
* Eliminated manual deployment steps
* Designed a production-like Kubernetes environment
* Integrated health checks and rollback mechanisms

---

## Resume Summary

Built an Internal Developer Platform (IDP) enabling push-to-deploy workflows using GitHub Actions, Docker, and Kubernetes with automated deployments, health checks, and rollback capabilities.

---

## Future Enhancements

* Multi-environment deployment (dev, stage, production)
* Helm-based packaging and deployment
* Monitoring integration using Prometheus and Grafana
* Role-based access control (RBAC)
* Horizontal Pod Autoscaling (HPA)

---

## Author

Abinaya
Cloud and DevOps Enthusiast

---

## Conclusion

This project demonstrates how modern DevOps practices evolve from simple pipelines to full-fledged platforms, enabling reliable, automated, and scalable application deployments.
