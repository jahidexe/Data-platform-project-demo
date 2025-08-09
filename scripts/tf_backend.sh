#!/bin/bash
# create_tf_backend.sh
# Purpose: Create a GCS bucket for Terraform remote backend (state storage) in GCP

# Exit if any command fails
set -e

# ===== CONFIG =====
PROJECT_ID="esg-dev-jahid"              # Change to your project ID
BUCKET_NAME="tf-backend-${PROJECT_ID}"  # Unique bucket name
REGION="EU"                             # Match your BigQuery/Data region
STORAGE_CLASS="STANDARD"                # STANDARD, NEARLINE, etc.
TERRAFORM_STATE_FILE="terraform.tfstate"

# ===== CREATE BUCKET =====
echo "Creating GCS bucket for Terraform backend..."
gcloud storage buckets create "gs://${BUCKET_NAME}" \
  --project="${PROJECT_ID}" \
  --location="${REGION}" \
  --default-storage-class="${STORAGE_CLASS}" \
  --uniform-bucket-level-access

echo "GCS bucket '${BUCKET_NAME}' created in ${REGION}."

# ===== ENABLE VERSIONING =====
echo "Enabling object versioning for state history..."
gcloud storage buckets update "gs://${BUCKET_NAME}" \
  --versioning

echo "Versioning enabled."

# ===== PRINT BACKEND CONFIG =====
echo "Terraform backend config:"
cat <<EOF

terraform {
  backend "gcs" {
    bucket  = "${BUCKET_NAME}"
    prefix  = "state"
  }
}

EOF

echo "Paste the above block into your 'backend.tf' to use this GCS bucket for state."
