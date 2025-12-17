#!/usr/bin/env bash
set -euo pipefail

# Subscribes the consumer to the DCR exchange, creating a linked dataset in the consumer project.

source "$(dirname "$0")/00_env.local.sh"

LOCATION="us"
EXCHANGE_ID="poc_dcr_exchange_251217_22d0"

# This is the dataset that will be created in the consumer project as the linked dataset.
DEST_DATASET_ID="linked_cr_poc_251217_22d0"
SUBSCRIPTION_ID="poc_subscription_251217_22d0"

TOKEN="$(gcloud auth print-access-token)"
NAME="projects/${CLEANROOM_PROJECT_ID}/locations/${LOCATION}/dataExchanges/${EXCHANGE_ID}"

BODY="$(jq -n \
  --arg proj "${CONSUMER_PROJECT_ID}" \
  --arg dsid "${DEST_DATASET_ID}" \
  --arg loc "${BQ_LOCATION}" \
  --arg parent "projects/${CONSUMER_PROJECT_ID}/locations/${LOCATION}" \
  --arg sub "${SUBSCRIPTION_ID}" \
  --arg contact "$(gcloud config get-value account 2>/dev/null)" \
  '{
    destination: $parent,
    subscription: $sub,
    destinationDataset: {
      datasetReference: {
        projectId: $proj,
        datasetId: $dsid
      },
      location: $loc,
      friendlyName: "Linked dataset (clean room POC)",
      description: "Linked dataset created by subscribing to Analytics Hub DCR exchange."
    },
    subscriberContact: $contact
  }')"

echo "Subscribing to exchange: ${NAME}"

OP="$(curl -sS -X POST \
  -H "Authorization: Bearer ${TOKEN}" \
  -H "x-goog-user-project: ${CLEANROOM_PROJECT_ID}" \
  -H "Content-Type: application/json" \
  "https://analyticshub.googleapis.com/v1/${NAME}:subscribe" \
  -d "${BODY}")"

echo "$OP" | jq .

OP_NAME="$(echo "$OP" | jq -r '.name // empty')"
if [[ -z "$OP_NAME" ]]; then
  echo "No operation name returned; subscription may have failed." >&2
  exit 1
fi

echo
echo "Polling operation: $OP_NAME"
for i in {1..60}; do
  RESP="$(curl -sS \
    -H "Authorization: Bearer ${TOKEN}" \
    -H "x-goog-user-project: ${CLEANROOM_PROJECT_ID}" \
    "https://analyticshub.googleapis.com/v1/${OP_NAME}")"
  DONE="$(echo "$RESP" | jq -r '.done')"
  if [[ "$DONE" == "true" ]]; then
    echo "$RESP" | jq .
    break
  fi
  sleep 2
done

echo
echo "If successful, linked dataset should exist: ${CONSUMER_PROJECT_ID}:${DEST_DATASET_ID}"


