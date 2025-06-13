#!/bin/bash

set -euo pipefail

ACTION="$1"
ENV_NAME="$2"
DR_ROLE="$3"
AWS_REGION="$4"
OWNER="$5"

if [[ -z "$ACTION" || -z "$ENV_NAME" || -z "$DR_ROLE" || -z "$AWS_REGION" || -z "$OWNER" ]]; then
  echo "Usage: $0 {deploy|destroy} <environment> <dr_role> <aws_region> <owner>"
  exit 1
fi

BACKEND_BUCKET="${DR_ROLE}-${ENV_NAME}-terraform-${AWS_REGION}-${OWNER}"
BACKEND_KEY="${DR_ROLE}-${ENV_NAME}-backend-state-${AWS_REGION}-${OWNER}.tfstate"
PLAN_FILE="${DR_ROLE}-${ENV_NAME}-backend-plan-${AWS_REGION}-${OWNER}.tfplan"
OUTPUT_FILE="../../configuration/backend/${ENV_NAME}/configuration.json"

case "$ACTION" in
  deploy)
    echo "Running Terraform init for environment: $ENV_NAME"
    terraform init \
      -backend-config="bucket=$BACKEND_BUCKET" \
      -backend-config="region=$AWS_REGION" \
      -backend-config="key=$BACKEND_KEY"

    echo "Running Terraform plan for environment: $ENV_NAME"
    terraform plan \
      -out="$PLAN_FILE" \
      -var="environment=$ENV_NAME" \
      -var="disaster_recovery_role=$DR_ROLE" \
      -var="aws_region=$AWS_REGION" \
      -var="owner=$OWNER"

    echo "Applying Terraform changes for environment: $ENV_NAME"
    terraform apply \
      -auto-approve "$PLAN_FILE"

    echo "Fetching Terraform outputs in JSON for environment: $ENV_NAME"
    terraform output -json > "$OUTPUT_FILE"
    ;;
  destroy)
    echo "Running Terraform init for environment: $ENV_NAME"
    terraform init \
      -backend-config="bucket=$BACKEND_BUCKET" \
      -backend-config="region=$AWS_REGION" \
      -backend-config="key=$BACKEND_KEY"

    echo "Destroying Terraform-managed infrastructure for environment: $ENV_NAME"
    terraform destroy \
      -auto-approve \
      -var="environment=$ENV_NAME" \
      -var="disaster_recovery_role=$DR_ROLE" \
      -var="aws_region=$AWS_REGION" \
      -var="owner=$OWNER"
    ;;
  *)
    echo "Usage: $0 {deploy|destroy} <environment> <dr_role> <aws_region> <owner>"
    exit 1
    ;;
esac
