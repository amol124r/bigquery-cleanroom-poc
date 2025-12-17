## Consumer capabilities matrix (what to validate)

This matrix is framed as **“What can the consumer do after the producer publishes data into a clean room, and the consumer receives a linked dataset?”**

### Terms (from official docs)

The BigQuery data clean rooms docs define core objects and constraints:

- **Data clean room**: an environment to share sensitive data where **raw access is prevented** and **query restrictions are enforced**.
- **Shared resource**: a shared unit in a clean room and **must be a BigQuery table, view, or routine (TVF)**.
- **Linked dataset**: a **read-only** BigQuery dataset (symbolic link) created for subscribers.
- **Analysis rule**: configured by data contributors; **prevents raw access** and enforces query restrictions.
- **Data egress controls**: **automatically enabled** to prevent subscribers from copying/exporting raw data; can be further configured.

Source: `https://cloud.google.com/bigquery/docs/data-clean-rooms`

Separately, the BigQuery sharing / Analytics Hub docs define **data egress options** for linked datasets:

- Data egress options let publishers restrict subscriber export “out of BigQuery linked datasets.”
- When restricted, the docs explicitly state the following are disabled:
  - **Copy/clone/export/snapshot APIs**
  - **Copy/clone/export/snapshot UI options in console**
  - **Connecting restricted dataset to Table Explorer**
  - **BigQuery Data Transfer Service on the restricted dataset**
  - **`CREATE TABLE AS SELECT` and writing to a destination table**
  - **`CREATE VIEW AS SELECT` and writing to a destination view**

Source: `https://cloud.google.com/bigquery/docs/analytics-hub-introduction` (section “Data egress options (BigQuery shared datasets only)”)

### Capability matrix (expected outcomes)

#### 1) Can the consumer see raw table data?

- **Expected**:
  - **If you only use restricted egress** (Analytics Hub egress controls) but share a normal view/table, the consumer can still **run SQL and view row-level results** in the query results grid.
  - **If you use clean room analysis rule–enforced resources**, raw row-level visibility should be prevented and only allowed outputs (often aggregated) should be returned.
- **Validate**:
  - Attempt `SELECT * FROM linked_dataset.some_resource LIMIT 10;`
  - Attempt “preview” in UI (Table Explorer)

#### 2) Can the consumer run queries?

- **Expected**: **Yes, but constrained** by analysis rules.
- **Validate**:
  - For aggregation-threshold enforced resources, docs indicate querying uses `SELECT WITH AGGREGATION_THRESHOLD` syntax.

#### 3) Can the consumer join clean-room data with consumer’s own tables?

- **Expected**: **Yes, in the way permitted by the analysis rule**.
- **Validate**:
  - Join shared data to `consumer_first_party.user_attributes` and only return aggregated outputs.

#### 4) Can the consumer create derived tables (CTAS / destination table writes)?

- **Expected**:
  - If **data egress restrictions are enabled** on the listing or query results, **CTAS and writing to destination tables are disabled** (per Analytics Hub docs).
  - If **not restricted**, consumer can usually materialize query results into tables in their own project (this is the “exfil via derived table” risk).
- **Validate**:
  - Attempt `CREATE TABLE consumer_ds.derived AS SELECT ... FROM linked_dataset...;`
  - Attempt query with a destination table set in UI

#### 5) Can the consumer export/copy/snapshot/clone?

- **Expected**: If restricted egress is enabled, **copy/clone/export/snapshot** are disabled (API + UI).
- **Validate**:
  - UI attempts (Copy / Snapshot)
  - `bq extract`, `bq cp`, table snapshot/clone operations

#### 6) Can the consumer download query results to local machine?

- **Expected**:
  - If restricted egress blocks “export/copy”, it still leaves a question: “can a user see result rows and manually download?”
  - In practice, BigQuery UI typically allows downloading **query results**, but clean room analysis rules are designed to ensure **only safe (typically aggregated) results** are produced.
- **Validate**:
  - Run allowed aggregate query and attempt “Download results” (CSV/JSON) in UI.
  - Record whether it’s permitted and whether result granularity is safe.

### What the POC should document (success criteria)

- **Exactly which operations fail** for the consumer (with the exact error text / UI screenshots).
- **Exactly which operations still succeed** (especially: “download query results”).
- **How join + aggregation is enforced** (example queries).
- **Whether any materialization path remains** (CTAS, destination tables, exports).


