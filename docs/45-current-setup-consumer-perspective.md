## Current setup: what the consumer can see vs can’t (as-built POC)

This document describes the **current** POC configuration we built and ran, and what it enables from the **consumer perspective**.

### Current configuration (important)

This POC uses **Analytics Hub + linked dataset + restricted egress**.

- The producer published a **plain BigQuery view** with row-level columns:
  - `producer_shared.user_events_view` (contains `user_id`, timestamps, etc.)
- The listing enabled **restricted export**:
  - `enabled=true`
  - `restrictDirectTableAccess=true`
  - `restrictQueryResult=true`
- The consumer subscribed and got a **linked dataset** in the consumer project:
  - `linked_cr_poc_251217_22d0`
  - BigQuery dataset metadata shows: `restrictions.type = RESTRICTED_DATA_EGRESS`

This setup **does not** add clean-room **analysis rules** (aggregation threshold / query templates) on top of the shared resource.

### What the consumer can do (VISIBLE / ALLOWED)

#### A) See schema + object metadata

In BigQuery UI, the consumer can:

- Expand the linked dataset
- Open the view details (schema fields)

#### B) Run SQL and see query results (including row-level results)

Because the shared object is a normal view, the consumer can:

- Run `SELECT * ... LIMIT ...`
- See the returned rows in the **query results grid** in the BigQuery UI

This is expected: **restricted egress controls do not prevent query results from being displayed**.

### What the consumer can’t do (EGRESS / EXFIL BLOCKS)

Restricted egress blocks the common “copy data out” and “materialize into my project” paths. In our run, these operations failed with **Access Denied … Data egress is restricted**:

#### A) Direct row reads / preview via certain APIs

- Example: `bq head` (tabledata.list-like access) failed.
- In UI, the “Preview” button may fail depending on how it is implemented for the object.

#### B) Copy / snapshot / clone

- `bq cp` failed
- snapshot/clone DDL failed

#### C) Export

- `EXPORT DATA ... AS SELECT ... FROM linked_dataset...` failed

#### D) Materialize results (destination writes)

- `CREATE TABLE AS SELECT` failed (CTAS)
- `CREATE VIEW AS SELECT` failed

### Key takeaway

- **Restricted egress** is primarily about preventing **copy/export/materialization** of linked data.
- If you also need to prevent consumers from seeing **row-level** results, you must use **clean-room analysis rules** (for example, aggregation threshold enforced views / query templates) and/or share only aggregated outputs.


