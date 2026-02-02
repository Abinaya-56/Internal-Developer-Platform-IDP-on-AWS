# Internal Developer Platform (IDP) on AWS

## Problem Statement
Developers should deploy applications without accessing AWS, Kubernetes, or servers.

## Solution Overview
A pipeline-driven internal platform that provisions infrastructure, builds applications,
deploys to Kubernetes, and manages rollbacks automatically.

## Core Capabilities
- Pipeline-only infrastructure changes
- Automated Docker image build & versioning
- Kubernetes-based deployments
- Health checks and automated rollback
- No manual kubectl or EC2 access

## Tech Stack (Cost-Free Focus)
- Infrastructure: Terraform
- CI/CD: GitHub Actions
- Kubernetes: k3s (local) → EKS (design-level)
- Container Registry: GitHub Container Registry
- Cloud Provider: AWS (Free Tier / simulated)

## Project Status
Phase 1 – Architecture & Planning
