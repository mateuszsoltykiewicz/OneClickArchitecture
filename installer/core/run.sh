#!/bin/bash
set -euo pipefail

ACTION="$1"
ENV_NAME="$2"
DR_ROLE="$3"
AWS_REGION="$4"
OWNER="$5"

if [[ -z "$ACTION" || -z "$ENV_NAME" || -z "$DR_ROLE" || -z "$AWS_REGION" || -z "$OWNER" ]] ; then
  echo "Usage: $0 {apply|destroy} <environment> <dr_role> <aws_region> <owner>"
  exit 1
fi

BACKEND_BUCKET="${DR_ROLE}-${ENV_NAME}-terraform-${AWS_REGION}-${OWNER}"
BACKEND_KEY="${DR_ROLE}-${ENV_NAME}-core-state-${AWS_REGION}-${OWNER}.tfstate"
PLAN_FILE="${DR_ROLE}-${ENV_NAME}-core-plan-${AWS_REGION}-${OWNER}.tfplan"
OUTPUT_FILE="../../configuration/core/${ENV_NAME}/configuration.json"

echo "Generating backend file for env: $ENV_NAME"
cat > backend.tf <<EOF
terraform {
  backend "s3" {
    bucket         = "${BACKEND_BUCKET}"
    key            = "core/terraform.tfstate"
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
  -var="owner=$OWNER"

echo "$ACTION Terraform-managed core applications for environment: $ENV_NAME"
terraform $ACTION \
  -auto-approve \
  -var="environment=$ENV_NAME" \
  -var="disaster_recovery_role=$DR_ROLE" \
  -var="aws_region=$AWS_REGION" \
  -var="owner=$OWNER"
