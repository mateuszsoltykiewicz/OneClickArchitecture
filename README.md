# DigitalFirstAi DevOps Solution – CI/CD & AWS Deployment

This repository contains a comprehensive, modular DevOps solution for deploying and managing DigitalFirstAi applications on AWS using modern infrastructure-as-code, containerization, and Kubernetes orchestration.

---

## Table of Contents

- [Architecture Overview](#architecture-overview)
- [Core Technologies](#core-technologies)
- [AWS Components](#aws-components)
- [Applications & Middleware](#applications--middleware)
- [CI/CD Pipeline Stages](#cicd-pipeline-stages)
- [Configuration Management](#configuration-management)
- [Environment Separation](#environment-separation)
- [Directory Structure](#directory-structure)
- [Security & Networking](#security--networking)
- [Automation & Modularity](#automation--modularity)

---

## Architecture Overview

- **Infrastructure as Code (IaC):** Terraform is used to provision and manage all AWS resources and infrastructure state.
- **Containerization:** All applications are containerized with Docker, and images are stored in AWS ECR.
- **Kubernetes Orchestration:** Applications are deployed on AWS EKS clusters, with Helm charts templating deployments.
- **Environment-driven:** Configurations are environment-specific and centrally managed.

---

## Core Technologies

- **Terraform:** Infrastructure provisioning and management.
- **Docker:** Application containerization.
- **AWS ECR:** Container image registry.
- **EKS (Kubernetes):** Container orchestration.
- **Helm:** Application deployment templating.
- **Python Scripts:** Automation for image building, ECR management, and rollouts.

---

## AWS Components

- **Databases:** RDS Aurora PostgreSQL, DocumentDB (MongoDB), Elasticache Redis.
- **Compute:** EKS clusters for orchestrating containers.
- **Networking:** VPCs with public/private subnets, security groups per service, Internet Gateway (IGW), and NAT.
- **Load Balancing:** AWS ALB (Application Load Balancer) with ingress controllers.

---

## Applications & Middleware

## Apps

### Middleware

- `alb-ingress-controller`
- `external-services` (for secure DB connectivity)
- `NGINX controller`
- `QDrant database`
- `Qdrant operator`

---

## CI/CD Pipeline Stages

### 1. Preparation

- Build Docker images for each application using source code from `../df-repositories/{APPLICATION_NAME}`.
- Push images to ECR.
- Use a configurator to propagate environment-specific configurations.
- Frontend requires custom `.env` and NGINX configuration.
- Python `images-controller` automates repository cloning and Dockerfile management.

### 2. Installer

- **Infrastructure:** Deploys AWS resources via Terraform.
- **Middleware:** Installs supporting services using Helm and Terraform.
- **DigitalFirstAi Apps:** Deploys applications using Helm charts with configuration values.
- Each step maintains a separate Terraform state.
- Dependencies (DB endpoints, certificate ARNs, cluster credentials) are dynamically injected.

### 3. Migration Assistant

- Migrates MongoDB, Redis, Qdrant, and PostgreSQL RDS to the new environment.
- Configurable for databases and destinations.
- Qdrant migrates from EC2 to Kubernetes Pod.
- Supports migration for each environment.

### 4. Updater

- Automates Docker image builds and pushes when versions change.
- Manages Helm upgrades and rollbacks.
- Python scripts handle ECR management and image versioning.

---

## Configuration Management

- **Centralized Directory:** All configuration is stored centrally and propagated by the configurator.
- **Examples:** 
  - `terraform_default_configuration.yaml` for infrastructure
  - `values.yaml` for Helm chart deployments

---

## Environment Separation

- **Production:** Dedicated VPC, EKS cluster, and databases.
- **Test/Staging:** Shared VPC and EKS cluster, separated by Kubernetes namespaces (e.g., `test-qdrant`, `staging-middleware`).

---

## Directory Structure



---

## Security & Networking

- **Security Groups:** Chained per service for controlled inter-service communication (e.g., RDS <-> EKS).
- **Sensitive Data:** Managed via Kubernetes ConfigMaps and environment variables (consider using Secrets for production).
- **Networking:** VPCs, subnets, IGW, NAT, and ALB for secure and scalable connectivity.

---

## Automation & Modularity

- **Modular Stages:** Each deployment stage is independently modular (separate state files, scripts, and configurations).
- **Automation Scripts:** Python scripts for efficient, repeatable builds and deployments.
- **Migration & Updates:** Automated, configurable, and environment-aware.

---

## Example Configurations

### Infrastructure (YAML)

### Helm values.yaml (Excerpt)

---

## Best Practices

- Modular, environment-driven deployments
- Automated, scriptable image and infrastructure management
- Clear separation of test, staging, and production environments
- Use of Helm and Terraform for scalable, repeatable deployments

---

> **Note:**  
> This README is a high-level summary. For detailed documentation, configuration examples, and deployment instructions, refer to the respective subdirectories and configuration files.


