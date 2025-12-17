## Naming conventions + cost notes (POC-friendly)

### Region

- **BigQuery location**: use **`US` multi-region** for simplicity.

There’s no special “cost-free region” for BigQuery, but for a small POC you can typically stay within the **BigQuery free tier** by keeping:

- tables tiny (KB/MB, not GB)
- queries minimal (only a handful)

### Recommended project naming

Pick a short, readable base name and add role suffixes:

- **Producer**: `bqcr-poc-producer`
- **Clean room**: `bqcr-poc-cleanroom`
- **Consumer**: `bqcr-poc-consumer`

If you need uniqueness, add a short suffix like your initials + 3 digits:

- `bqcr-poc-producer-amol-001`

### BigQuery naming (datasets/tables)

- **Producer datasets**
  - `producer_raw`
  - `producer_shared` (optional; for views you publish)

- **Consumer datasets**
  - `consumer_first_party`
  - `consumer_derived` (materialization target; will be used to prove CTAS blocks when egress restricted)

- **Tables**
  - `producer_raw.user_events`
  - `consumer_first_party.user_attributes`


