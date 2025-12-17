#!/usr/bin/env bash
set -euo pipefail

# Subscribes consumer to the authorized view listing in DCR exchange.
# Then tests if consumer can copy/export data.

source "$(dirname "$0")/00_env.local.sh"

LOCATION="us"
DCR_EXCHANGE_ID="poc_dcr_exchange_251217_22d0"
LISTING_ID="authorized_view_dcr_listing_251217_22d0"
SUBSCRIPTION_ID="poc_subscription_authorized_view_251217_22d0"

TOKEN="$(gcloud auth print-access-token)"
EXCHANGE="projects/${CLEANROOM_PROJECT_ID}/locations/${LOCATION}/dataExchanges/${DCR_EXCHANGE_ID}"
DESTINATION="projects/${CONSUMER_PROJECT_ID}/locations/${LOCATION}"
LINKED_DATASET_ID="linked_authorized_view_251217_22d0"

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
      friendlyName: "Linked dataset (authorized view from DCR)",
      description: "Linked dataset from authorized view in DCR exchange - testing copy/export"
    },
    subscriberContact: $contact
  }')"

echo "Subscribing to authorized view listing in DCR exchange: ${EXCHANGE}"

RESPONSE="$(curl -sS -X POST \
  -H "Authorization: Bearer ${TOKEN}" \
  -H "x-goog-user-project: ${CONSUMER_PROJECT_ID}" \
  -H "Content-Type: application/json" \
  "https://analyticshub.googleapis.com/v1/${EXCHANGE}:subscribe" \
  -d "${BODY}")"

echo "$RESPONSE" | jq .

OP_NAME="$(echo "$RESPONSE" | jq -r '.name // empty')"

if [ -n "$OP_NAME" ] && [ "$OP_NAME" != "null" ]; then
  echo ""
  echo "✅ Subscription operation started: ${OP_NAME}"
  echo "Waiting 30 seconds for linked dataset to be created..."
  sleep 30
  echo ""
  echo "Linked dataset should exist: ${CONSUMER_PROJECT_ID}:${LINKED_DATASET_ID}"
else
  echo ""
  echo "⚠️  No operation name returned; subscription may have failed."
fi

