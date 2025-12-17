#!/usr/bin/env bash
set -euo pipefail

# Creates the 3 projects (producer, cleanroom, consumer).
#
# Notes:
# - Project creation requires org/folder permissions + billing linking permissions.
# - If your org forbids project creation from CLI, create them in Console and skip this step.

source "$(dirname "$0")/00_env.local.sh"

create_project() {
  local project_id="$1"
  local name="$2"

  if gcloud projects describe "$project_id" >/dev/null 2>&1; then
    echo "Project exists: $project_id"
    return 0
  fi

  echo "Creating project: $project_id ($name)"

  if [[ -n "${FOLDER_ID:-}" ]]; then
    gcloud projects create "$project_id" --name="$name" --folder="$FOLDER_ID"
  elif [[ -n "${ORG_ID:-}" ]]; then
    gcloud projects create "$project_id" --name="$name" --organization="$ORG_ID"
  else
    gcloud projects create "$project_id" --name="$name"
  fi

  if [[ -n "${BILLING_ACCOUNT_ID:-}" ]]; then
    echo "Linking billing account to $project_id"
    gcloud billing projects link "$project_id" --billing-account="$BILLING_ACCOUNT_ID"
  else
    echo "Billing not linked (BILLING_ACCOUNT_ID not set). Link billing in Console if needed."
  fi
}

create_project "$PRODUCER_PROJECT_ID" "BQ Clean Room POC - Producer"
create_project "$CLEANROOM_PROJECT_ID" "BQ Clean Room POC - Cleanroom"
create_project "$CONSUMER_PROJECT_ID" "BQ Clean Room POC - Consumer"


