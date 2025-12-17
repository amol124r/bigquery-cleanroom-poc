#!/usr/bin/env bash
set -euo pipefail

# Creates an Analytics Hub Data Exchange configured for Data Clean Rooms (DCR).

source "$(dirname "$0")/00_env.local.sh"

LOCATION="us" # Analytics Hub location for BigQuery US multi-region
EXCHANGE_ID="poc_dcr_exchange_251217_22d0"

TOKEN="$(gcloud auth print-access-token)"
PARENT="projects/${CLEANROOM_PROJECT_ID}/locations/${LOCATION}"

BODY="$(jq -n \
  --arg dn "POC Clean Room Exchange - user events" \
  --arg desc "POC exchange used to validate egress controls + linked dataset behavior." \
  '{
    displayName: $dn,
    description: $desc,
    discoveryType: "DISCOVERY_TYPE_PRIVATE",
    sharingEnvironmentConfig: {
      dcrExchangeConfig: {
        singleLinkedDatasetPerCleanroom: true
      }
    }
  }')"

echo "Creating DCR exchange: ${PARENT}/dataExchanges/${EXCHANGE_ID}"

curl -sS -X POST \
  -H "Authorization: Bearer ${TOKEN}" \
  -H "x-goog-user-project: ${CLEANROOM_PROJECT_ID}" \
  -H "Content-Type: application/json" \
  "https://analyticshub.googleapis.com/v1/${PARENT}/dataExchanges?dataExchangeId=${EXCHANGE_ID}" \
  -d "${BODY}" | jq .

echo
echo "EXCHANGE_RESOURCE=projects/${CLEANROOM_PROJECT_ID}/locations/${LOCATION}/dataExchanges/${EXCHANGE_ID}"


