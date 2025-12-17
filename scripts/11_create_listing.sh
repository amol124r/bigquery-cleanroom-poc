#!/usr/bin/env bash
set -euo pipefail

# Creates a listing inside the DCR exchange that points at the producer's shared view.
# Also enables restricted export policy to validate egress controls.

source "$(dirname "$0")/00_env.local.sh"

LOCATION="us"
EXCHANGE_ID="poc_dcr_exchange_251217_22d0"
LISTING_ID="user_events_listing_251217_22d0"

TOKEN="$(gcloud auth print-access-token)"
PARENT="projects/${CLEANROOM_PROJECT_ID}/locations/${LOCATION}/dataExchanges/${EXCHANGE_ID}"

# Dataset that contains the shared resource (view) in the producer project.
SOURCE_DATASET="projects/${PRODUCER_PROJECT_ID}/datasets/${PRODUCER_DATASET_SHARED}"
SOURCE_TABLE="projects/${PRODUCER_PROJECT_ID}/datasets/${PRODUCER_DATASET_SHARED}/tables/user_events_view"

BODY="$(jq -n \
  --arg dn "POC User Events - restricted egress" \
  --arg desc "Producer shared view with restricted export enabled to test subscriber egress controls." \
  --arg ds "${SOURCE_DATASET}" \
  --arg tbl "${SOURCE_TABLE}" \
  '{
    displayName: $dn,
    description: $desc,
    discoveryType: "DISCOVERY_TYPE_PRIVATE",
    bigqueryDataset: {
      dataset: $ds,
      selectedResources: [
        { table: $tbl }
      ],
      restrictedExportPolicy: {
        enabled: true,
        restrictDirectTableAccess: true,
        restrictQueryResult: true
      }
    }
  }')"

echo "Creating listing: ${PARENT}/listings/${LISTING_ID}"

curl -sS -X POST \
  -H "Authorization: Bearer ${TOKEN}" \
  -H "x-goog-user-project: ${CLEANROOM_PROJECT_ID}" \
  -H "Content-Type: application/json" \
  "https://analyticshub.googleapis.com/v1/${PARENT}/listings?listingId=${LISTING_ID}" \
  -d "${BODY}" | jq .

echo
echo "LISTING_RESOURCE=projects/${CLEANROOM_PROJECT_ID}/locations/${LOCATION}/dataExchanges/${EXCHANGE_ID}/listings/${LISTING_ID}"


