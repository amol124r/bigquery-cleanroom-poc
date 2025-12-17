#!/usr/bin/env bash
set -euo pipefail

# Runs the same consumer-side tests as script 13, but with egress controls DISABLED.
# This validates what becomes allowed when restricted export is turned off.

source "$(dirname "$0")/00_env.local.sh"

CONSUMER_LINKED_DATASET="linked_cr_poc_251217_22d0"
SHARED_TABLE="user_events_view"

OUT_DIR="$(cd "$(dirname "$0")/.." && pwd)/out"
mkdir -p "$OUT_DIR"

log() { printf "\n== %s ==\n" "$1"; }
run() { ( set +e; echo "+ $*"; "$@"; echo "exit=$?"; ) 2>&1 | tee -a "$OUT_DIR/consumer_tests_egress_disabled.log"; }

rm -f "$OUT_DIR/consumer_tests_egress_disabled.log"

log "EGRESS CONTROLS DISABLED - Re-running consumer tests"
log "1) Show dataset metadata (expect linked dataset, restrictions should be removed or reduced)"
run bq --project_id="$CONSUMER_PROJECT_ID" show --format=prettyjson "${CONSUMER_PROJECT_ID}:${CONSUMER_LINKED_DATASET}"

log "2) List tables/views in linked dataset"
run bq --project_id="$CONSUMER_PROJECT_ID" ls "${CONSUMER_PROJECT_ID}:${CONSUMER_LINKED_DATASET}"

log "3) Attempt tabledata.list-style read (bq head) - NOW SHOULD WORK"
run bq --project_id="$CONSUMER_PROJECT_ID" head -n 5 "${CONSUMER_PROJECT_ID}:${CONSUMER_LINKED_DATASET}.${SHARED_TABLE}"

log "4) Run a simple aggregate query (should still be allowed)"
run bq --location="$BQ_LOCATION" --project_id="$CONSUMER_PROJECT_ID" query --use_legacy_sql=false \
  "SELECT event_name, COUNT(*) AS c
   FROM \`${CONSUMER_PROJECT_ID}.${CONSUMER_LINKED_DATASET}.${SHARED_TABLE}\`
   GROUP BY event_name
   ORDER BY c DESC"

log "5) Join with consumer first-party table and aggregate (should still be allowed)"
run bq --location="$BQ_LOCATION" --project_id="$CONSUMER_PROJECT_ID" query --use_legacy_sql=false \
  "SELECT a.segment, e.event_name, COUNT(*) AS events
   FROM \`${CONSUMER_PROJECT_ID}.consumer_first_party.user_attributes\` a
   JOIN \`${CONSUMER_PROJECT_ID}.${CONSUMER_LINKED_DATASET}.${SHARED_TABLE}\` e
     ON e.user_id = a.user_id
   GROUP BY a.segment, e.event_name
   ORDER BY events DESC"

log "6) Attempt CTAS into consumer_derived - NOW SHOULD WORK"
run bq --location="$BQ_LOCATION" --project_id="$CONSUMER_PROJECT_ID" query --use_legacy_sql=false \
  "CREATE OR REPLACE TABLE \`${CONSUMER_PROJECT_ID}.consumer_derived.derived_events_by_segment\` AS
   SELECT a.segment, e.event_name, COUNT(*) AS events
   FROM \`${CONSUMER_PROJECT_ID}.consumer_first_party.user_attributes\` a
   JOIN \`${CONSUMER_PROJECT_ID}.${CONSUMER_LINKED_DATASET}.${SHARED_TABLE}\` e
     ON e.user_id = a.user_id
   GROUP BY a.segment, e.event_name"

log "7) Attempt CREATE VIEW AS SELECT into consumer_derived - NOW SHOULD WORK"
run bq --location="$BQ_LOCATION" --project_id="$CONSUMER_PROJECT_ID" query --use_legacy_sql=false \
  "CREATE OR REPLACE VIEW \`${CONSUMER_PROJECT_ID}.consumer_derived.v_events_by_segment\` AS
   SELECT a.segment, e.event_name, COUNT(*) AS events
   FROM \`${CONSUMER_PROJECT_ID}.consumer_first_party.user_attributes\` a
   JOIN \`${CONSUMER_PROJECT_ID}.${CONSUMER_LINKED_DATASET}.${SHARED_TABLE}\` e
     ON e.user_id = a.user_id
   GROUP BY a.segment, e.event_name"

log "8) Attempt bq cp - NOW SHOULD WORK"
run bq --project_id="$CONSUMER_PROJECT_ID" cp \
  "${CONSUMER_PROJECT_ID}:${CONSUMER_LINKED_DATASET}.${SHARED_TABLE}" \
  "${CONSUMER_PROJECT_ID}:consumer_derived.copied_user_events_view"

log "9) Attempt snapshot/clone via SQL - NOW SHOULD WORK"
run bq --location="$BQ_LOCATION" --project_id="$CONSUMER_PROJECT_ID" query --use_legacy_sql=false \
  "CREATE SNAPSHOT TABLE \`${CONSUMER_PROJECT_ID}.consumer_derived.snap_user_events\`
   CLONE \`${CONSUMER_PROJECT_ID}.${CONSUMER_LINKED_DATASET}.${SHARED_TABLE}\`"

log "10) Attempt EXPORT DATA to GCS - NOW SHOULD WORK"
BUCKET="gs://${CONSUMER_PROJECT_ID}-egress-test"
run bq --location="$BQ_LOCATION" --project_id="$CONSUMER_PROJECT_ID" query --use_legacy_sql=false \
  "EXPORT DATA OPTIONS(
    uri='${BUCKET}/export_user_events_egress_disabled_*.csv',
    format='CSV',
    overwrite=true
  ) AS
  SELECT event_name, COUNT(*) AS c
  FROM \`${CONSUMER_PROJECT_ID}.${CONSUMER_LINKED_DATASET}.${SHARED_TABLE}\`
  GROUP BY event_name"

echo
echo "✅ Tests completed. Log written to: $OUT_DIR/consumer_tests_egress_disabled.log"

