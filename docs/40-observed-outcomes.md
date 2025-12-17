## Observed outcomes (actual POC run)

This section captures what we **actually observed** running the POC against real GCP projects using **restricted egress**.

### Environment

- **Producer project**: `bqcr-poc-prod-251217-22d0`
  - Shared view: `producer_shared.user_events_view`
- **Clean room project**: `bqcr-poc-cr-251217-22d0`
  - Exchange: `poc_dcr_exchange_251217_22d0` (location `us`)
  - Listing: `user_events_listing_251217_22d0`
  - Listing restricted export policy:
    - `enabled=true`
    - `restrictDirectTableAccess=true`
    - `restrictQueryResult=true`
- **Consumer project**: `bqcr-poc-cons-251217-22d0`
  - Linked dataset created: `linked_cr_poc_251217_22d0`

### Important API nuance (subscription)

For `SubscribeDataExchangeRequest`, the API **requires** these fields (per discovery doc descriptions):

- `destination`: `projects/{consumerProjectId}/locations/us`
- `subscription`: a name like `poc_subscription_...`

Once those were included, subscription succeeded and created a linked dataset.

### Linked dataset state (consumer)

We confirmed the dataset is:

- `type = LINKED`
- `restrictions.type = RESTRICTED_DATA_EGRESS`
- `linkedDatasetMetadata.linkState = LINKED`

### What the consumer could do

- **List tables/views** in the linked dataset: **allowed**
- **Run SQL queries** against the linked dataset view: **allowed**
  - We confirmed both **aggregate** queries and **joins** run successfully.
  - Importantly: **row-level results can still be viewed in the query results grid** if the shared object itself exposes row-level data. Restricted egress does **not** equal “no raw visibility.”

### What the consumer could *not* do (egress blocks)

All of the following failed with **Access Denied ... Data egress is restricted**:

- **Direct read / preview** (`bq head`, i.e., direct row reads)
- **CTAS / materialize results** into consumer tables
- **CREATE VIEW AS SELECT** into consumer datasets
- **Copy (`bq cp`)**
- **Snapshot/clone**
- **Export query results to GCS via `EXPORT DATA`**

### Key takeaway

This automated run primarily validated **Analytics Hub restricted egress controls**.

To prevent consumers from seeing raw rows at all, you must also use **clean room analysis rules** (for example, aggregation threshold enforced views / query templates) rather than publishing a plain view that returns row-level data.

### Evidence / logs

- Full run log: `out/consumer_tests.log`

Key excerpts (exact messages observed):

- `bq head`:
  - `Access Denied: Table ... Data egress is restricted`
- `CREATE TABLE AS SELECT`:
  - `Access Denied: Table ... Data egress is restricted`
- `bq cp`:
  - `Access Denied: Table ... Data egress is restricted`
- `EXPORT DATA`:
  - `Access Denied: Table ... Data egress is restricted`


