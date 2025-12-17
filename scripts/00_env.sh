#!/usr/bin/env bash
set -euo pipefail

# Copy this file to scripts/00_env.local.sh and edit values there.
# Then run: source scripts/00_env.local.sh

# ---- Region / location ----
export BQ_LOCATION="US"

# ---- Project IDs (edit these) ----
export PRODUCER_PROJECT_ID="bqcr-poc-producer-amol-001"
export CLEANROOM_PROJECT_ID="bqcr-poc-cleanroom-amol-001"
export CONSUMER_PROJECT_ID="bqcr-poc-consumer-amol-001"

# ---- Optional org/folder/billing (leave blank if not applicable) ----
# export ORG_ID="123456789012"
# export FOLDER_ID="987654321098"
# export BILLING_ACCOUNT_ID="000000-000000-000000"

# ---- BigQuery datasets ----
export PRODUCER_DATASET_RAW="producer_raw"
export PRODUCER_DATASET_SHARED="producer_shared"

export CONSUMER_DATASET_FIRST_PARTY="consumer_first_party"
export CONSUMER_DATASET_DERIVED="consumer_derived"


