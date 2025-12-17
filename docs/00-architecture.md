## Architecture (3 projects)

### Projects

- **Producer project (`PRODUCER_PROJECT_ID`)**
  - Owns the sensitive/raw data.
  - Creates **shared resources** (table/view/routine) that will be shared into the clean room.

- **Clean room project (`CLEANROOM_PROJECT_ID`)**
  - Hosts the **Analytics Hub** data clean room.
  - Clean room owner manages subscribers and contributors.
  - Data contributors publish **listings** into the clean room.

- **Consumer project (`CONSUMER_PROJECT_ID`)**
  - Subscribes to the clean room, receives a **linked dataset** (read-only).
  - Attempts analysis, joins, derived tables, and export/copy operations (to validate controls).

### BigQuery objects you’ll create

- **Producer**:
  - Dataset: `producer_raw`
  - Table: `producer_raw.user_events` (dummy user IDs + events)
  - Optional: a **view** that projects only allowed columns

- **Consumer**:
  - Dataset: `consumer_first_party`
  - Table: `consumer_first_party.user_attributes` (dummy user IDs + segments)

- **Clean room**:
  - Data clean room (Analytics Hub)
  - Listing(s) created from producer shared resources
  - Consumer subscription -> **linked dataset** appears in consumer project

### IAM (minimum roles to make the POC work)

Exact IAM varies by org policy, but conceptually:

- **Clean room owner** (in clean room project):
  - `roles/analyticshub.admin`

- **Producer contributor user/service account**:
  - `roles/analyticshub.publisher` (to add/publish data into the clean room)
  - plus BigQuery permissions to create/read the producer dataset objects they publish

- **Consumer subscriber user/service account**:
  - `roles/analyticshub.subscriber`
  - `roles/analyticshub.subscriptionOwner`
  - plus BigQuery job execution permissions in their own project to run queries


