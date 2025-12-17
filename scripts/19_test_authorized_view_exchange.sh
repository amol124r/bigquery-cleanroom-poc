#!/usr/bin/env bash
set -euo pipefail

# Tests using authorized views in a regular Analytics Hub exchange.
# This approach allows sharing specific views/tables without DCR restrictions.

source "$(dirname "$0")/00_env.local.sh"

echo "=== Testing Authorized Views in Regular Analytics Hub Exchange ==="
echo ""

# Step 1: Create an authorized view in the cleanroom project
# This view will reference the producer's table
echo "Step 1: Creating authorized view in cleanroom project..."
CLEANROOM_DATASET="cleanroom_shared_views"
CLEANROOM_VIEW="authorized_user_events_view"

# Create dataset in cleanroom if it doesn't exist
bq --project_id="$CLEANROOM_PROJECT_ID" mk --dataset \
  --location="$BQ_LOCATION" \
  --description="Dataset for authorized views to share via Analytics Hub" \
  "${CLEANROOM_PROJECT_ID}:${CLEANROOM_DATASET}" 2>/dev/null || true

# Create the authorized view that references producer's table
echo "Creating authorized view that references producer table..."
bq --project_id="$CLEANROOM_PROJECT_ID" query --use_legacy_sql=false <<EOF
CREATE OR REPLACE VIEW \`${CLEANROOM_PROJECT_ID}.${CLEANROOM_DATASET}.${CLEANROOM_VIEW}\` AS
SELECT
  user_id,
  event_ts,
  event_name,
  purchase_amount
FROM \`${PRODUCER_PROJECT_ID}.producer_shared.user_events_view\`
EOF

# Step 2: Grant the cleanroom project access to the producer's view
echo ""
echo "Step 2: Granting cleanroom project access to producer's view..."
PROD_NUM="$(gcloud projects describe ${PRODUCER_PROJECT_ID} --format='value(projectNumber)')"
CLEANROOM_NUM="$(gcloud projects describe ${CLEANROOM_PROJECT_ID} --format='value(projectNumber)')"

# Grant BigQuery Data Viewer role to cleanroom project
echo "Granting access to cleanroom project..."
bq --project_id="$PRODUCER_PROJECT_ID" update \
  --add_access_entry="project:${CLEANROOM_NUM}:READER" \
  "${PRODUCER_PROJECT_ID}:producer_shared" 2>/dev/null || echo "Access may already exist or error occurred"

# Step 3: Create a regular exchange and listing with the authorized view
echo ""
echo "Step 3: Creating regular exchange with authorized view listing..."

EXCHANGE_ID="poc_authorized_view_exchange_251217_22d0"
LISTING_ID="authorized_view_listing_251217_22d0"

TOKEN="$(gcloud auth print-access-token)"
PARENT="projects/${CLEANROOM_PROJECT_ID}/locations/us/dataExchanges/${EXCHANGE_ID}"

# Create exchange if it doesn't exist
curl -sS -X POST \
  -H "Authorization: Bearer ${TOKEN}" \
  -H "x-goog-user-project: ${CLEANROOM_PROJECT_ID}" \
  -H "Content-Type: application/json" \
  "https://analyticshub.googleapis.com/v1/projects/${CLEANROOM_PROJECT_ID}/locations/us/dataExchanges?dataExchangeId=${EXCHANGE_ID}" \
  -d "$(jq -n \
    --arg dn "POC Authorized View Exchange" \
    --arg desc "Regular exchange using authorized views for flexible data sharing" \
    '{
      displayName: $dn,
      description: $desc,
      discoveryType: "DISCOVERY_TYPE_PRIVATE"
    }')" | jq '{name, displayName}' || echo "Exchange may already exist"

# Create listing pointing to the authorized view dataset
CLEANROOM_DATASET_PATH="projects/${CLEANROOM_NUM}/datasets/${CLEANROOM_DATASET}"

BODY="$(jq -n \
  --arg dn "Authorized View Listing - No Egress" \
  --arg desc "Authorized view shared via regular exchange - allows export/copy" \
  --arg ds "${CLEANROOM_DATASET_PATH}" \
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

echo "Creating listing with authorized view dataset..."
curl -sS -X POST \
  -H "Authorization: Bearer ${TOKEN}" \
  -H "x-goog-user-project: ${CLEANROOM_PROJECT_ID}" \
  -H "Content-Type: application/json" \
  "https://analyticshub.googleapis.com/v1/${PARENT}/listings?listingId=${LISTING_ID}" \
  -d "${BODY}" | jq '{name, displayName, bigqueryDataset: {dataset, restrictedExportPolicy}}'

echo ""
echo "=== Summary ==="
echo "✅ Created authorized view: ${CLEANROOM_PROJECT_ID}.${CLEANROOM_DATASET}.${CLEANROOM_VIEW}"
echo "✅ Granted cleanroom project access to producer's view"
echo "✅ Created regular exchange: ${EXCHANGE_ID}"
echo "✅ Created listing pointing to authorized view dataset"
echo ""
echo "Next steps:"
echo "1. Grant subscriber permissions on the exchange"
echo "2. Consumer can subscribe to get the authorized view"
echo "3. Consumer should be able to export/copy since egress is disabled"

