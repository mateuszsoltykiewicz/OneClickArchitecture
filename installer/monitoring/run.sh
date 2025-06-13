#!/bin/bash
set -euo pipefail

ACTION="$1"
ENV_NAME="$2"
DR_ROLE="$3"
AWS_REGION="$4"
CLUSTER_NAME="$5"
OWNER="$6"

if [[ -z "$ACTION" || -z "$ENV_NAME" || -z "$DR_ROLE" || -z "$AWS_REGION" || -z "$CLUSTER_NAME" || -z "$OWNER" ]] ; then
  echo "Usage: $0 {apply|destroy} <environment> <dr_role> <aws_region> <cluster_name> <owner>"
  exit 1
fi

BACKEND_BUCKET="${DR_ROLE}-${ENV_NAME}-terraform-${AWS_REGION}-${OWNER}"
BACKEND_KEY="${DR_ROLE}-${ENV_NAME}-monitoring-state-${AWS_REGION}-${OWNER}.tfstate"
PLAN_FILE="${DR_ROLE}-${ENV_NAME}-monitoring-plan-${AWS_REGION}-${OWNER}.tfplan"
OUTPUT_FILE="../../configuration/monitoring/${ENV_NAME}/configuration.json"

echo "Generating backend file for env: $ENV_NAME"
cat > backend.tf <<EOF
terraform {
  backend "s3" {
    bucket         = "${BACKEND_BUCKET}"
    key            = "${BACKEND_KEY}"
    region         = "${AWS_REGION}"
  }
}
EOF

echo "Initializing terraform"
terraform init -reconfigure

echo "Selecting terraform workspace for env: $ENV_NAME"
terraform workspace select "$ENV_NAME" || terraform workspace new "$ENV_NAME"

echo "Running Terraform plan for environment: $ENV_NAME"
terraform plan \
  -out="$PLAN_FILE" \
  -var="environment=$ENV_NAME" \
  -var="disaster_recovery_role=$DR_ROLE" \
  -var="aws_region=$AWS_REGION" \
  -var="cluster_name=$CLUSTER_NAME" \
  -var="owner=$OWNER"

echo "$ACTION Terraform-managed core applications for environment: $ENV_NAME"
terraform $ACTION \
  -auto-approve \
  -var="environment=$ENV_NAME" \
  -var="disaster_recovery_role=$DR_ROLE" \
  -var="aws_region=$AWS_REGION" \
  -var="cluster_name=$CLUSTER_NAME" \
  -var="owner=$OWNER"
