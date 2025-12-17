#!/usr/bin/env bash
set -euo pipefail

# Tests using authorized views WITHIN a DCR exchange.
# Question: Can authorized views bypass DCR restrictions and allow copying?

source "$(dirname "$0")/00_env.local.sh"

echo "=== Testing Authorized Views in DCR Exchange ==="
echo ""

# Step 1: Ensure authorized view exists in cleanroom
CLEANROOM_DATASET="cleanroom_shared_views"
CLEANROOM_VIEW="authorized_user_events_view"

echo "Step 1: Ensuring authorized view exists..."
bq --project_id="$CLEANROOM_PROJECT_ID" mk --dataset \
  --location="$BQ_LOCATION" \
  --description="Dataset for authorized views" \
  "${CLEANROOM_PROJECT_ID}:${CLEANROOM_DATASET}" 2>/dev/null || true

# Create/replace the authorized view
bq --project_id="$CLEANROOM_PROJECT_ID" query --use_legacy_sql=false <<EOF
CREATE OR REPLACE VIEW \`${CLEANROOM_PROJECT_ID}.${CLEANROOM_DATASET}.${CLEANROOM_VIEW}\` AS
SELECT
  user_id,
  event_ts,
  event_name,
  purchase_amount
FROM \`${PRODUCER_PROJECT_ID}.producer_shared.user_events_view\`
EOF

# Step 2: Create a NEW listing in the EXISTING DCR exchange using authorized view
echo ""
echo "Step 2: Creating listing in DCR exchange with authorized view..."

DCR_EXCHANGE_ID="poc_dcr_exchange_251217_22d0"
LISTING_ID="authorized_view_dcr_listing_251217_22d0"

TOKEN="$(gcloud auth print-access-token)"
PARENT="projects/${CLEANROOM_PROJECT_ID}/locations/us/dataExchanges/${DCR_EXCHANGE_ID}"

CLEANROOM_NUM="$(gcloud projects describe ${CLEANROOM_PROJECT_ID} --format='value(projectNumber)')"
AUTHORIZED_VIEW_TABLE="projects/${CLEANROOM_NUM}/datasets/${CLEANROOM_DATASET}/tables/${CLEANROOM_VIEW}"

# Try creating listing with authorized view as selectedResource
BODY="$(jq -n \
  --arg dn "Authorized View in DCR - Test Copy" \
  --arg desc "Authorized view shared via DCR exchange - testing if copy/export works" \
  --arg ds "projects/${CLEANROOM_NUM}/datasets/${CLEANROOM_DATASET}" \
  --arg tbl "${AUTHORIZED_VIEW_TABLE}" \
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
        restrictQueryResult: false
      }
    }
  }')"

echo "Creating listing in DCR exchange with authorized view..."
RESPONSE="$(curl -sS -X POST \
  -H "Authorization: Bearer ${TOKEN}" \
  -H "x-goog-user-project: ${CLEANROOM_PROJECT_ID}" \
  -H "Content-Type: application/json" \
  "https://analyticshub.googleapis.com/v1/${PARENT}/listings?listingId=${LISTING_ID}" \
  -d "${BODY}")"

echo "$RESPONSE" | jq '{name, displayName, bigqueryDataset: {dataset, selectedResources, restrictedExportPolicy}}'

# Check if it worked
if echo "$RESPONSE" | jq -e '.name' > /dev/null 2>&1; then
  echo ""
  echo "✅ Listing created successfully!"
  echo ""
  echo "Next steps:"
  echo "1. Consumer needs to subscribe to this new listing"
  echo "2. Test if consumer can copy/export the authorized view"
  echo "3. Compare behavior with regular view in DCR"
else
  echo ""
  echo "❌ Listing creation may have failed. Response:"
  echo "$RESPONSE" | jq .
fi

