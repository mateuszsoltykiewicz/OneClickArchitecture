# Middleware Terraform Stack

This repository manages the deployment of all middleware infrastructure for the platform, including logging, monitoring, security, networking, and automation components.  
It supports multi-environment (dev, prod, etc.) and multi-namespace deployments, driven by a YAML configuration file.

---

## Features

- **Multi-environment:** Deploy to any number of environments (e.g., dev, prod) using a single codebase.
- **Multi-namespace:** Deploy middleware modules per namespace, with custom configuration for each.
- **YAML-driven:** All configuration (environments, modules, namespaces) is managed in a single `environments.yaml` file.
- **Dynamic AWS/EKS/VPC Discovery:** Uses Terraform data sources to automatically discover cluster and network details.
- **Modular:** Each middleware component is a self-contained Terraform module, following best practices for reuse and encapsulation.
- **Conditional Deployment:** Modules are only deployed if enabled in the YAML config.
- **Production Ready:** Follows best practices for security, maintainability, and scalability.

---

## Directory Structure


---

## Module Overview

### acm
Manages AWS ACM certificates for secure HTTPS communication, typically for ALB or API Gateway.
- Issues and validates certificates
- Integrates with Route53 for DNS validation

### alb
Deploys and configures AWS Application Load Balancers, including target groups and optional Route53 records.
- Internal or external ALB creation
- Target group and listener management
- DNS integration via Route53

### external-services
Manages Kubernetes `ExternalService` resources, allowing you to expose external endpoints (e.g., databases, APIs) inside your cluster.
- Loops over a list of endpoints
- Enables/disables services per namespace

### fluentd
Deploys Fluentd for log aggregation, supporting output to CloudWatch or Loki (with S3 backend for Loki).
- DaemonSet deployment for node-wide log collection
- IRSA for AWS integration
- RBAC and NetworkPolicy for security
- Configurable via Helm values files

### injector
Manages Kubernetes resources for Vault Agent Injector, enabling secure injection of secrets into pods as environment variables.
- Supports Vault Agent annotations
- Integrates with Vault for dynamic secrets

### kms-key
Creates and manages AWS KMS keys for encryption and Vault auto-unseal.
- Key rotation and alias management
- Used by Vault and other modules requiring encryption

### lease-watcher
Deploys a service that monitors Vault lease events and triggers automation (e.g., pod restarts) when secrets are rotated.
- Watches Vault for credential changes
- Calls rotation webhook or triggers Kubernetes actions

### qdrant
Deploys Qdrant vector database clusters per namespace, with optional S3 snapshot integration.
- ClusterIP service (no ingress by default)
- IRSA and S3 snapshot support
- RBAC and NetworkPolicy included

### rotation-webhook
Deploys a webhook service that restarts deployments or pods when notified (e.g., by lease-watcher) that credentials have rotated.
- Secure RBAC for patching/restarting deployments
- Receives HTTP POST requests to trigger rollouts

### route53-zone
Manages AWS Route53 hosted zones and DNS records for internal and external services.
- Zone and record creation
- Used by ACM, ALB, and other modules

### vault
Deploys HashiCorp Vault with AWS KMS auto-unseal, RBAC, IRSA, and secure storage.
- Helm-based deployment
- Auto-unseal with KMS
- RBAC, IRSA, and NetworkPolicy for security

### vault-config
Configures Vault internals: enables secrets engines, creates dynamic database roles, and manages credential rotation.
- Database secret backends (RDS, MongoDB, Redis, Qdrant, etc.)
- Dynamic rotation and policy management

---

## Configuration

### environments.yaml

Define all environments, clusters, VPCs, and per-namespace middleware configuration in this file.

Example:



---

## Usage

### Prerequisites

- Terraform 1.3+
- AWS CLI
- kubectl
- yq (for YAML parsing in scripts)
- AWS credentials with sufficient permissions

### Deploy

Usage: ./run.sh <environment> <apply|plan|destroy>

./run.sh prod apply
./run.sh dev plan
./run.sh prod destroy

- The script will:
  - Parse the YAML config for the selected environment
  - Configure the S3 backend for state storage
  - Select or create a Terraform workspace per environment
  - Run the requested Terraform action

### Customizing Modules

- To enable or disable a module for a namespace, edit the corresponding section in `environments.yaml`.
- To change module parameters (e.g., log group, persistence size), edit their values in the YAML.
- For Helm-based modules, place your custom `values.yaml` in the `values/` directory and reference it in the module.

---

## Best Practices

- Use workspaces for environment isolation.
- Store state in S3 with DynamoDB locking for safety.
- Use tags for all AWS resources for cost allocation and governance.
- Keep YAML config in version control for auditability and reproducibility.
- Use data sources for all AWS/EKS/VPC lookups—never hardcode IDs.
- Review IAM roles and policies for least privilege.

---

## Troubleshooting

- **Terraform fails to find cluster/VPC:** Check that `cluster_name` and `vpc_name` in `environments.yaml` match AWS tags and resource names.
- **Module not deployed:** Ensure `enabled: true` is set for that module in the relevant namespace.
- **State errors:** Ensure the S3 bucket and DynamoDB table for state exist and are accessible.

---

## Outputs

- Namespace names, module statuses, and resource outputs are available via `terraform output`.

---

## Security & Compliance

- All sensitive values (tokens, keys, passwords) should be managed via Vault or AWS Secrets Manager, never committed to version control.
- Regularly review module IAM policies and security group rules.
- Enable audit logging for Vault and AWS resources.

---

## Maintenance & Upgrades

- Regularly update module versions and Helm charts to receive security and feature updates.
- Test changes in non-production environments before applying to production.
- Monitor for deprecations in Terraform, AWS, and Kubernetes APIs.

---

## Support

For issues, open a ticket in the repository or contact the platform team.

---

This stack is designed for secure, scalable, and maintainable middleware infrastructure across all your Kubernetes environments.

---

### References

- Terraform Modules Overview: https://developer.hashicorp.com/terraform/language/modules
- Terraform Workflow Best Practices: https://www.hashicorp.com/resources/terraform-workflow-best-practices-at-scale
- Solace: Module Separation of Concerns: https://codelabs.solace.dev/codelabs/terraform-modules/?index=..%2F..index
- Best Practices for Terraform Modules: https://techblog.flaviusdinu.com/building-reusable-terraform-modules-part-2-c7cafaeeee59
- Spacelift: Terraform Modules: https://spacelift.io/blog/what-are-terraform-modules-and-how-do-they-work

