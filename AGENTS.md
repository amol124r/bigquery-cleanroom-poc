# AGENTS.md

## Cursor Cloud specific instructions

This repo is a **runbook / POC scaffold** for Google Cloud **BigQuery Data Clean Rooms / Analytics Hub**, not a locally-runnable application. It is entirely `bash` scripts (`scripts/`), BigQuery SQL (`sql/`), and Markdown docs (`docs/`). There is **no build step, no package manager, no server, and no local ports** — every script calls the `gcloud`/`bq` CLIs against live Google Cloud resources. Start with `README.md` and `docs/20-poc-steps.md` for the end-to-end flow.

### Tooling (already provided by the environment)

- `gcloud` and `bq` (Google Cloud SDK) and `shellcheck` are pre-installed in the base image. No install step is needed at session start.
- There are no code dependencies to install (no `package.json`, `requirements.txt`, `Makefile`, etc.).

### Environment config (required before running any script)

- Every numbered script does `source "$(dirname "$0")/00_env.local.sh"`, so `scripts/00_env.local.sh` **must exist**. It is git-ignored (`*.local.sh`) and is auto-created from the committed template `scripts/00_env.sh` by the startup update script.
- Edit `scripts/00_env.local.sh` to set your real `PRODUCER_PROJECT_ID`, `CLEANROOM_PROJECT_ID`, `CONSUMER_PROJECT_ID`, and `BQ_LOCATION` before running the flow. The committed defaults are placeholders.

### Lint / syntax-check (fully runnable offline, no credentials needed)

- Syntax: `bash -n scripts/*.sh`
- Lint: `shellcheck scripts/*.sh`. Note: current scripts emit pre-existing informational/warning findings (e.g. `SC1091` for the sourced local env file, and some `SC2034`/`SC2086`). These are expected; treat only newly-introduced errors as actionable.

### Running the POC / "tests" (requires live GCP — blocking)

- There is **no offline test framework**. The "tests" are the numbered scripts (e.g. `scripts/03_seed_bigquery.sh`, `scripts/13_consumer_egress_tests.sh`) and `sql/validation_queries.sql`, all executed against real GCP.
- Running any script end-to-end requires: an authenticated identity (`gcloud auth login` or a service-account key via Application Default Credentials), **three GCP projects with billing** (producer / clean room / consumer), and the IAM roles listed in `docs/00-architecture.md`. Without credentials the scripts stop immediately at the GCP auth boundary (`ERROR: (bq) You do not currently have an active account selected`) — this is expected, not an environment defect.
- Some steps (clean-room creation, UI egress tests) are performed in the GCP Console per `scripts/04_console_steps_cleanroom.md` and `docs/50-browser-test-guide.md`; the scripts cover the CLI equivalents.
- Scripts write logs to `out/` (git-ignored).
