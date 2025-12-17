#!/usr/bin/env bash
set -euo pipefail

# Enables required APIs on all three projects.

source "$(dirname "$0")/00_env.local.sh"

enable_on() {
  local project_id="$1"
  echo "Enabling APIs on $project_id"
  gcloud services enable \
    bigquery.googleapis.com \
    analyticshub.googleapis.com \
    --project "$project_id"
}

enable_on "$PRODUCER_PROJECT_ID"
enable_on "$CLEANROOM_PROJECT_ID"
enable_on "$CONSUMER_PROJECT_ID"


