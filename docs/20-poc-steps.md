## POC runbook (console + scripts)

### Prereqs

- You can create projects in your org/folder and attach billing.
- You have `gcloud` installed locally and authenticated (`gcloud auth login`).
- You can enable APIs.

### 0) Choose IDs/locations

Set these (examples):

- `PRODUCER_PROJECT_ID=cr-producer-123`
- `CLEANROOM_PROJECT_ID=cr-cleanroom-123`
- `CONSUMER_PROJECT_ID=cr-consumer-123`
- `BQ_LOCATION=US` (use US multi-region for this POC)

Recommended naming + cost notes:

- `docs/05-naming-and-cost.md`

### 1) Create 3 projects + enable APIs

Create projects in your org/folder (org-specific), then enable:

- BigQuery API
- Analytics Hub API

### 2) Producer: create dataset + dummy table

Run the SQL in:

- `sql/producer_setup.sql`

### 3) Consumer: create first-party dataset + table

Run the SQL in:

- `sql/consumer_setup.sql`

### 4) Clean room: create the data clean room (Console)

In **clean room project**:

- Go to BigQuery → **Sharing (Analytics Hub)**
- Create a **Data clean room**
- Add:
  - **Data contributor(s)**: producer identities
  - **Subscriber(s)**: consumer identities

### 5) Publish data into the clean room (Console)

As a **data contributor** (producer side):

- Add data (create listing) in the clean room using the producer’s **shared resource** (table/view/routine).
- Configure **analysis rule(s)** (at least aggregation threshold) so raw access is prevented.
- Ensure **data egress controls** are enabled (default), and optionally set the listing to restricted egress as part of the POC.

### 6) Consumer subscribes (Console)

In **consumer project**:

- Subscribe to the clean room
- Confirm a **linked dataset** appears in BigQuery under the consumer project.

### 7) Validate consumer operations (this is the POC)

Run the validation checks in:

- `sql/validation_queries.sql`

Use the explicit checklist for evidence capture:

- `docs/30-validation-checklist.md`

Also attempt these UI actions and record outcomes:

- Table Explorer “Preview” on linked dataset resources
- “Copy table”
- “Snapshot”
- “Export”
- Query → “Save results” to a destination table
- Download query results

### 8) Produce final deliverable

Fill out (copy and edit) the matrix in:

- `docs/10-consumer-capabilities-matrix.md`

Include:

- which operations are blocked (and exact error messages)
- which operations succeed
- any join/materialization workarounds you find (if any)


