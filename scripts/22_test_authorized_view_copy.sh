#!/usr/bin/env bash
set -euo pipefail

# Tests if consumer can copy/export data from authorized view in DCR exchange.

source "$(dirname "$0")/00_env.local.sh"

LINKED_DATASET="linked_authorized_view_251217_22d0"
SHARED_VIEW="authorized_user_events_view"

echo "=== Testing Copy/Export from Authorized View in DCR Exchange ==="
echo ""

log() { printf "\n== %s ==\n" "$1"; }
run() { ( set +e; echo "+ $*"; "$@"; echo "exit=$?"; ) 2>&1; }

log "1) Check if CTAS works (should be blocked if restrictQueryResult=true)"
run bq --location="$BQ_LOCATION" --project_id="$CONSUMER_PROJECT_ID" query --use_legacy_sql=false \
  "CREATE OR REPLACE TABLE \`${CONSUMER_PROJECT_ID}.consumer_derived.test_authorized_view_ctas\` AS
   SELECT event_name, COUNT(*) AS c
   FROM \`${CONSUMER_PROJECT_ID}.${LINKED_DATASET}.${SHARED_VIEW}\`
   GROUP BY event_name"

log "2) Check if CREATE VIEW works (should be blocked if restrictQueryResult=true)"
run bq --location="$BQ_LOCATION" --project_id="$CONSUMER_PROJECT_ID" query --use_legacy_sql=false \
  "CREATE OR REPLACE VIEW \`${CONSUMER_PROJECT_ID}.consumer_derived.v_test_authorized_view\` AS
   SELECT event_name, COUNT(*) AS c
   FROM \`${CONSUMER_PROJECT_ID}.${LINKED_DATASET}.${SHARED_VIEW}\`
   GROUP BY event_name"

log "3) Check if bq cp works"
run bq --project_id="$CONSUMER_PROJECT_ID" cp \
  "${CONSUMER_PROJECT_ID}:${LINKED_DATASET}.${SHARED_VIEW}" \
  "${CONSUMER_PROJECT_ID}:consumer_derived.copied_authorized_view"

log "4) Check if EXPORT DATA works"
BUCKET="gs://${CONSUMER_PROJECT_ID}-egress-test"
run bq --location="$BQ_LOCATION" --project_id="$CONSUMER_PROJECT_ID" query --use_legacy_sql=false \
  "EXPORT DATA OPTIONS(
    uri='${BUCKET}/export_authorized_view_*.csv',
    format='CSV',
    overwrite=true
  ) AS
  SELECT event_name, COUNT(*) AS c
  FROM \`${CONSUMER_PROJECT_ID}.${LINKED_DATASET}.${SHARED_VIEW}\`
  GROUP BY event_name"

log "5) Check if query works (should always work)"
run bq --location="$BQ_LOCATION" --project_id="$CONSUMER_PROJECT_ID" query --use_legacy_sql=false \
  "SELECT event_name, COUNT(*) AS c
   FROM \`${CONSUMER_PROJECT_ID}.${LINKED_DATASET}.${SHARED_VIEW}\`
   GROUP BY event_name
   ORDER BY c DESC"

echo ""
echo "=== Summary ==="
echo "If restrictQueryResult=false in listing, CTAS/CREATE VIEW/EXPORT should work"
echo "If restrictQueryResult=true, all materialization should be blocked"

