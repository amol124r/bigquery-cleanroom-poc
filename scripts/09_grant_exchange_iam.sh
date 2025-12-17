#!/usr/bin/env bash
set -euo pipefail

# Grants Analytics Hub subscription permissions on the exchange to a principal (user/service account).
# Needed because the exchange is DISCOVERY_TYPE_PRIVATE.

source "$(dirname "$0")/00_env.local.sh"

LOCATION="us"
EXCHANGE_ID="poc_dcr_exchange_251217_22d0"
PRINCIPAL="${1:-user:$(gcloud config get-value account 2>/dev/null)}"

RESOURCE="projects/${CLEANROOM_PROJECT_ID}/locations/${LOCATION}/dataExchanges/${EXCHANGE_ID}"
TOKEN="$(gcloud auth print-access-token)"

get_policy() {
  curl -sS -X POST \
    -H "Authorization: Bearer ${TOKEN}" \
    -H "x-goog-user-project: ${CLEANROOM_PROJECT_ID}" \
    -H "Content-Type: application/json" \
    "https://analyticshub.googleapis.com/v1/${RESOURCE}:getIamPolicy" \
    -d '{}' | jq .
}

echo "Reading IAM policy for: ${RESOURCE}"
POLICY="$(get_policy)"
ETAG="$(echo "$POLICY" | jq -r '.etag // empty')"

echo "Current bindings:"
echo "$POLICY" | jq '.bindings // []'

UPDATED="$(echo "$POLICY" | jq \
  --arg member "$PRINCIPAL" \
  '
  .bindings = ((.bindings // [])
    | ( . + [
        {role:"roles/analyticshub.subscriber", members:[$member]},
        {role:"roles/analyticshub.subscriptionOwner", members:[$member]}
      ])
    | group_by(.role)
    | map({role: .[0].role, members: (map(.members[]) | unique)})
  )
  ' )"

echo
echo "Setting updated IAM policy (principal: ${PRINCIPAL})..."

curl -sS -X POST \
  -H "Authorization: Bearer ${TOKEN}" \
  -H "x-goog-user-project: ${CLEANROOM_PROJECT_ID}" \
  -H "Content-Type: application/json" \
  "https://analyticshub.googleapis.com/v1/${RESOURCE}:setIamPolicy" \
  -d "$(jq -n --argjson policy "$UPDATED" '{policy:$policy}')" | jq .


