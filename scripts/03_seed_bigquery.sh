#!/usr/bin/env bash
set -euo pipefail

# Creates datasets + seeds dummy tables in producer and consumer projects.

source "$(dirname "$0")/00_env.local.sh"

echo "Seeding producer BigQuery objects..."
bq --location="$BQ_LOCATION" --project_id="$PRODUCER_PROJECT_ID" query --use_legacy_sql=false < sql/producer_setup.sql

echo "Seeding consumer BigQuery objects..."
bq --location="$BQ_LOCATION" --project_id="$CONSUMER_PROJECT_ID" query --use_legacy_sql=false < sql/consumer_setup.sql

echo "Creating consumer derived dataset (target for CTAS tests)..."
bq --location="$BQ_LOCATION" --project_id="$CONSUMER_PROJECT_ID" mk -d --description "Derived outputs for clean room POC" "$CONSUMER_DATASET_DERIVED" || true


