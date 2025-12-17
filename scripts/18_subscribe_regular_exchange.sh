#!/usr/bin/env bash
set -euo pipefail

# Subscribes consumer to the regular exchange (no egress controls) to create a linked dataset.

source "$(dirname "$0")/00_env.local.sh"

LOCATION="us"
EXCHANGE_ID="poc_regular_exchange_251217_22d0"
LISTING_ID="user_events_listing_no_egress_251217_22d0"
SUBSCRIPTION_ID="poc_subscription_no_egress_251217_22d0"

TOKEN="$(gcloud auth print-access-token)"
LISTING="projects/${CLEANROOM_PROJECT_ID}/locations/${LOCATION}/dataExchanges/${EXCHANGE_ID}/listings/${LISTING_ID}"
DESTINATION="projects/${CONSUMER_PROJECT_ID}/locations/${LOCATION}"
LINKED_DATASET_ID="linked_no_egress_251217_22d0"

BODY="$(jq -n \
  --arg dest "${DESTINATION}" \
  --arg sub "${SUBSCRIPTION_ID}" \
  --arg proj "${CONSUMER_PROJECT_ID}" \
  --arg dsid "${LINKED_DATASET_ID}" \
  --arg loc "${BQ_LOCATION}" \
  --arg contact "$(gcloud config get-value account 2>/dev/null)" \
  '{
    destination: $dest,
    subscription: $sub,
    destinationDataset: {
      datasetReference: {
        projectId: $proj,
        datasetId: $dsid
      },
      location: $loc,
      friendlyName: "Linked dataset (no egress restrictions)",
      description: "Linked dataset from regular exchange with egress controls disabled."
    },
    subscriberContact: $contact
  }')"

echo "Subscribing to listing: ${LISTING}"

RESPONSE="$(curl -sS -X POST \
  -H "Authorization: Bearer ${TOKEN}" \
  -H "x-goog-user-project: ${CONSUMER_PROJECT_ID}" \
  -H "Content-Type: application/json" \
  "https://analyticshub.googleapis.com/v1/${LISTING}:subscribe" \
  -d "${BODY}")"

echo "$RESPONSE" | jq .

OP_NAME="$(echo "$RESPONSE" | jq -r '.name // empty')"

if [ -n "$OP_NAME" ]; then
  echo ""
  echo "Polling operation: ${OP_NAME}"
  # Wait for operation to complete
  sleep 5
  echo ""
  echo "If successful, linked dataset should exist: ${CONSUMER_PROJECT_ID}:${LINKED_DATASET_ID}"
else
  echo "No operation name returned; subscription may have failed."
fi

