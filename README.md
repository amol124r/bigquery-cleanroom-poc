## GCP BigQuery Clean Room / Analytics Hub POC (Producer → Clean Room → Consumer)

This repo is a **runbook + reproducible POC scaffold** for validating **what a consumer can and cannot do** with data shared by a producer using:

- **BigQuery Sharing / Analytics Hub**
- **BigQuery Data Clean Rooms** (built on Analytics Hub)
- **Linked datasets**
- **Analysis rules** (clean room privacy/query restrictions)
- **Data egress controls** (copy/export/materialization restrictions)

### What this POC proves

You will stand up:

- **Producer project**: owns raw data tables.
- **Clean room project**: owns the clean room and publishes listings.
- **Consumer project**: subscribes, gets a **linked dataset**, and attempts various operations.

The end state is a documented matrix of:

- **Viewable** (what consumer can see/query)
- **Joinable** (can they join with their own tables?)
- **Materializable** (can they create derived tables / CTAS?)
- **Exportable / Copyable** (can they download/export/copy/snapshot/clone?)

### Setup Requirements

This POC requires you to have access to GCP projects and the necessary permissions. The repo provides:

- **Console click-paths**
- **`gcloud`/`bq` commands**
- **SQL scripts**

### Start here

- **📋 [Comprehensive Summary & Recommendations](./docs/70-comprehensive-summary-and-recommendations.md)** ⭐ **START HERE**
- `docs/00-architecture.md`
- `docs/05-naming-and-cost.md`
- `docs/10-consumer-capabilities-matrix.md`
- `docs/20-poc-steps.md`
- `docs/40-observed-outcomes.md`
- `docs/45-current-setup-consumer-perspective.md`

### Quick links (official docs referenced in this POC)

- BigQuery data clean rooms: `https://cloud.google.com/bigquery/docs/data-clean-rooms`
- BigQuery sharing / Analytics Hub intro: `https://cloud.google.com/bigquery/docs/analytics-hub-introduction`


