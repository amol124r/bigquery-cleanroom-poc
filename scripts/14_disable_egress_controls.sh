#!/usr/bin/env bash
set -euo pipefail

# Disables egress controls on an existing Analytics Hub listing
# This allows consumers to export/copy/materialize data from the linked dataset

source "$(dirname "$0")/00_env.local.sh"

TOKEN="$(gcloud auth print-access-token)"
LISTING="projects/${CLEANROOM_PROJECT_ID}/locations/us/dataExchanges/poc_dcr_exchange_251217_22d0/listings/user_events_listing_251217_22d0"

echo "Reading current listing configuration..."
CURRENT="$(curl -sS -H "Authorization: Bearer ${TOKEN}" \
  -H "x-goog-user-project: ${CLEANROOM_PROJECT_ID}" \
  "https://analyticshub.googleapis.com/v1/${LISTING}")"

echo "Current restrictedExportConfig:"
echo "$CURRENT" | jq '.restrictedExportConfig // empty'

# Update listing to disable egress controls
echo ""
echo "Updating listing to DISABLE egress controls..."

PROD_NUM="$(gcloud projects describe ${PRODUCER_PROJECT_ID} --format='value(projectNumber)')"
DATASET_PATH="projects/${PROD_NUM}/datasets/producer_shared"
TABLE_PATH="projects/${PROD_NUM}/datasets/producer_shared/tables/user_events_view"

UPDATE_BODY="$(jq -n \
  --arg ds "${DATASET_PATH}" \
  --arg tbl "${TABLE_PATH}" \
  '{
    bigqueryDataset: {
      dataset: $ds,
      selectedResources: [{table: $tbl}],
      restrictedExportPolicy: {
        enabled: false,
        restrictDirectTableAccess: false,
        restrictQueryResult: false
      }
    },
    restrictedExportConfig: {
      enabled: false,
      restrictDirectTableAccess: false,
      restrictQueryResult: false
    }
  }')"

RESPONSE="$(curl -sS -X PATCH \
  -H "Authorization: Bearer ${TOKEN}" \
  -H "x-goog-user-project: ${CLEANROOM_PROJECT_ID}" \
  -H "Content-Type: application/json" \
  "https://analyticshub.googleapis.com/v1/${LISTING}?updateMask=bigqueryDataset.restrictedExportPolicy.enabled,bigqueryDataset.restrictedExportPolicy.restrictDirectTableAccess,bigqueryDataset.restrictedExportPolicy.restrictQueryResult,restrictedExportConfig.enabled,restrictedExportConfig.restrictDirectTableAccess,restrictedExportConfig.restrictQueryResult" \
  -d "$UPDATE_BODY")"

echo "Update response:"
echo "$RESPONSE" | jq '{
  name,
  restrictedExportConfig,
  bigqueryDataset: {
    dataset: .bigqueryDataset.dataset,
    restrictedExportPolicy: .bigqueryDataset.restrictedExportPolicy
  }
}'

echo ""
echo "✅ Egress controls DISABLED on listing: ${LISTING}"
echo ""
echo "⚠️  NOTE: Changes may take a few minutes to propagate to linked datasets."
echo "   Wait 2-3 minutes, then re-run consumer tests."

