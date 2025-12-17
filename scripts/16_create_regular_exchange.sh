#!/usr/bin/env bash
set -euo pipefail

# Creates a REGULAR (non-DCR) Analytics Hub exchange for testing with egress controls disabled.
# This allows us to test what consumers can do when egress is completely disabled.

source "$(dirname "$0")/00_env.local.sh"

LOCATION="us"
EXCHANGE_ID="poc_regular_exchange_251217_22d0"

TOKEN="$(gcloud auth print-access-token)"
PARENT="projects/${CLEANROOM_PROJECT_ID}/locations/${LOCATION}"

BODY="$(jq -n \
  --arg dn "POC Regular Exchange - egress disabled" \
  --arg desc "Regular exchange (non-DCR) with egress controls disabled for testing consumer capabilities." \
  '{
    displayName: $dn,
    description: $desc,
    discoveryType: "DISCOVERY_TYPE_PRIVATE"
  }')"

echo "Creating regular exchange: ${PARENT}/dataExchanges/${EXCHANGE_ID}"

curl -sS -X POST \
  -H "Authorization: Bearer ${TOKEN}" \
  -H "x-goog-user-project: ${CLEANROOM_PROJECT_ID}" \
  -H "Content-Type: application/json" \
  "https://analyticshub.googleapis.com/v1/${PARENT}/dataExchanges?dataExchangeId=${EXCHANGE_ID}" \
  -d "${BODY}" | jq .

echo
echo "EXCHANGE_RESOURCE=projects/${CLEANROOM_PROJECT_ID}/locations/${LOCATION}/dataExchanges/${EXCHANGE_ID}"

