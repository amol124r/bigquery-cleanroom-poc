## Validation checklist (capture evidence)

Run these steps as the **consumer** after you have a **linked dataset**.

For each item, capture:

- Console screenshots (or at least the exact error message text)
- The SQL you ran
- Timestamp + project ID

### A) Confirm linked dataset properties

- Verify the dataset is **read-only**.
- Verify you can edit only **some metadata** (description/labels) but not underlying resources.
- **Identity contamination check (recommended)**:
  - As the consumer principal, try to query the producer raw table directly:
    - `SELECT * FROM \`bqcr-poc-prod-251217-22d0.producer_raw.user_events\` LIMIT 1;`
  - Expected: **Access Denied**. If it succeeds, your “consumer” identity has producer access and the POC is not trustworthy.

### B) Query behavior

- Attempt raw select:
  - `SELECT * FROM linked_dataset.shared_resource LIMIT 10;`
  - Record whether it fails, and why.

- Attempt allowed aggregate query:
  - `SELECT event_name, COUNT(*) FROM ... GROUP BY event_name;`
  - If using aggregation-threshold enforced view, validate you must use the documented syntax (where applicable).

### C) Join behavior (consumer first-party + linked dataset)

- Run a join query with **aggregated output** (see `sql/validation_queries.sql`).
- Record whether joining is allowed and what restrictions apply.

### D) Materialization attempts (the “copy to my project” risk)

Attempt these and record the outcome:

- **CTAS into consumer dataset**:
  - `CREATE TABLE consumer_derived.t AS SELECT ... FROM linked_dataset...;`
- **Destination table from query UI** (set “Destination”)
- **Create view in consumer**:
  - `CREATE VIEW consumer_derived.v AS SELECT ...;`

Per Analytics Hub docs for restricted egress, these are expected to be **disabled**.

### E) Export/copy/snapshot/clone attempts

Try both UI and CLI:

- UI: Copy / Snapshot / Export actions on the linked dataset tables/views
- CLI (examples):
  - `bq cp`
  - `bq extract`

Per Analytics Hub docs for restricted egress, these are expected to be **disabled**.

### F) “Download query results” (the tricky one)

Run an allowed query and attempt:

- Download results from BigQuery UI (CSV/JSON)

Document:

- whether download is allowed
- what granularity is exposed (aggregated-only vs row-level)
- whether the observed visibility is due to sharing a row-level view vs an analysis-rule enforced clean room resource


