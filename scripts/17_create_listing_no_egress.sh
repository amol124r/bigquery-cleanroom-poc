#!/usr/bin/env bash
set -euo pipefail

# Creates a listing in the regular exchange with NO egress controls enabled.

source "$(dirname "$0")/00_env.local.sh"

LOCATION="us"
EXCHANGE_ID="poc_regular_exchange_251217_22d0"
LISTING_ID="user_events_listing_no_egress_251217_22d0"

TOKEN="$(gcloud auth print-access-token)"
PARENT="projects/${CLEANROOM_PROJECT_ID}/locations/${LOCATION}/dataExchanges/${EXCHANGE_ID}"

PROD_NUM="$(gcloud projects describe ${PRODUCER_PROJECT_ID} --format='value(projectNumber)')"
SOURCE_DATASET="projects/${PROD_NUM}/datasets/producer_shared"
SOURCE_TABLE="projects/${PROD_NUM}/datasets/producer_shared/tables/user_events_view"

BODY="$(jq -n \
  --arg dn "POC User Events - NO egress restrictions" \
  --arg desc "Producer shared dataset with NO restricted export - consumers can export/copy/materialize." \
  --arg ds "${SOURCE_DATASET}" \
  '{
    displayName: $dn,
    description: $desc,
    discoveryType: "DISCOVERY_TYPE_PRIVATE",
    bigqueryDataset: {
      dataset: $ds,
      restrictedExportPolicy: {
        enabled: false,
        restrictDirectTableAccess: false,
        restrictQueryResult: false
      }
    }
  }')"

echo "Creating listing with NO egress controls: ${PARENT}/listings/${LISTING_ID}"

curl -sS -X POST \
  -H "Authorization: Bearer ${TOKEN}" \
  -H "x-goog-user-project: ${CLEANROOM_PROJECT_ID}" \
  -H "Content-Type: application/json" \
  "https://analyticshub.googleapis.com/v1/${PARENT}/listings?listingId=${LISTING_ID}" \
  -d "${BODY}" | jq .

echo
echo "LISTING_RESOURCE=projects/${CLEANROOM_PROJECT_ID}/locations/${LOCATION}/dataExchanges/${EXCHANGE_ID}/listings/${LISTING_ID}"

