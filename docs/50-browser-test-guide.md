# Step-by-Step Browser Test: Consumer Capabilities

This guide walks you through testing **what a consumer can and cannot do** with the linked dataset in the BigQuery UI, step-by-step.

## Prerequisites

- Open BigQuery UI for **consumer project**: `https://console.cloud.google.com/bigquery?project=bqcr-poc-cons-251217-22d0`
- You should see the **Explorer** panel on the left with datasets listed

## Test 1: Can Consumer See the Linked Dataset?

**Action:**
1. In the left **Explorer** panel, expand:
   - Project: `bqcr-poc-cons-251217-22d0`
   - Dataset: `linked_cr_poc_251217_22d0` (this is the **linked dataset**)
   - View: `user_events_view`

**Expected Result:** ✅ **YES** - You can see the dataset and view listed.

**What this proves:** Consumer can **discover** what's shared via the linked dataset.

---

## Test 2: Can Consumer Run a Simple Query and See Results?

**Action:**
1. Click on `user_events_view` in the Explorer
2. In the query editor (or click "Query" button), run:
   ```sql
   SELECT * 
   FROM `bqcr-poc-cons-251217-22d0.linked_cr_poc_251217_22d0.user_events_view` 
   LIMIT 1000
   ```
3. Click **Run**

**Expected Result:** ✅ **YES** - Query completes and shows **row-level data** in the results grid (you saw 6 rows: user_id, event_ts, event_name, purchase_amount).

**What this proves:** Consumer can **query** the linked dataset and see **raw row-level results** in the query results grid. This is allowed because we shared a **plain view** (not an analysis-rule enforced resource).

---

## Test 3: Can Consumer Use the "Preview" Button?

**Action:**
1. In the right **Reference** panel (or when you click on `user_events_view`), look for a **Preview** button
2. Click **Preview**

**Expected Result:** ❌ **NO** - Should show an error like:
- `Access Denied: Table ... Data egress is restricted`
- OR the Preview button may be disabled/grayed out

**What this proves:** **Direct table read APIs** (like `tabledata.list`) are blocked by `restrictDirectTableAccess=true`. However, **SQL queries still work** (Test 2).

---

## Test 4: Can Consumer Run Aggregate Queries?

**Action:**
1. In the query editor, run:
   ```sql
   SELECT event_name, COUNT(*) AS c
   FROM `bqcr-poc-cons-251217-22d0.linked_cr_poc_251217_22d0.user_events_view`
   GROUP BY event_name
   ORDER BY c DESC
   ```
2. Click **Run**

**Expected Result:** ✅ **YES** - Query completes and shows aggregated results (page_view=3, purchase=2, add_to_cart=1).

**What this proves:** Consumer can run **aggregate queries** and see results. This is allowed.

---

## Test 5: Can Consumer Join Linked Data with Their Own Data?

**Action:**
1. In the query editor, run:
   ```sql
   SELECT a.segment, e.event_name, COUNT(*) AS events
   FROM `bqcr-poc-cons-251217-22d0.consumer_first_party.user_attributes` a
   JOIN `bqcr-poc-cons-251217-22d0.linked_cr_poc_251217_22d0.user_events_view` e
     ON e.user_id = a.user_id
   GROUP BY a.segment, e.event_name
   ORDER BY events DESC
   ```
2. Click **Run**

**Expected Result:** ✅ **YES** - Query completes and shows joined/aggregated results (e.g., high_value segment with various events).

**What this proves:** Consumer can **join** the linked dataset with their own tables and see aggregated results. This is allowed.

---

## Test 6: Can Consumer Save Query Results to a Table (CTAS)?

**Action:**
1. Run any query that references the linked dataset (e.g., Test 4 or Test 5)
2. In the query results area, look for **"Save results"** button
3. Click **Save results** → Choose **"Save as table"**
4. Try to save to: `bqcr-poc-cons-251217-22d0.consumer_derived.test_saved_results`

**Expected Result:** ❌ **NO** - Should show an error like:
- `Access Denied: Table ... Data egress is restricted`
- OR the "Save as table" option may be disabled

**What this proves:** **Materializing query results** (CTAS / destination table writes) is blocked by `restrictQueryResult=true`. Consumer cannot create derived tables from linked dataset queries.

---

## Test 7: Can Consumer Copy the Linked View?

**Action:**
1. In the Explorer, right-click (or click ⋮ menu) on `user_events_view`
2. Look for **"Copy"** or **"Duplicate"** option
3. Try to copy it

**Expected Result:** ❌ **NO** - Copy option should be:
- Disabled/grayed out
- OR show error: `Access Denied ... Data egress is restricted`

**What this proves:** **Copy/clone operations** are blocked by restricted egress.

---

## Test 8: Can Consumer Export the Linked View?

**Action:**
1. In the Explorer, right-click (or click ⋮ menu) on `user_events_view`
2. Look for **"Export"** or **"Export to GCS"** option
3. Try to export

**Expected Result:** ❌ **NO** - Export option should be:
- Disabled/grayed out
- OR show error: `Access Denied ... Data egress is restricted`

**What this proves:** **Export operations** are blocked by restricted egress.

---

## Test 9: Can Consumer Create a View That References the Linked Dataset?

**Action:**
1. In the query editor, run:
   ```sql
   CREATE OR REPLACE VIEW `bqcr-poc-cons-251217-22d0.consumer_derived.v_test_view` AS
   SELECT event_name, COUNT(*) AS c
   FROM `bqcr-poc-cons-251217-22d0.linked_cr_poc_251217_22d0.user_events_view`
   GROUP BY event_name
   ```
2. Click **Run**

**Expected Result:** ❌ **NO** - Should show an error:
- `Access Denied: Table ... Data egress is restricted`

**What this proves:** **Creating derived views** that reference the linked dataset is blocked by `restrictQueryResult=true`.

---

## Test 10: Can Consumer Use EXPORT DATA Statement?

**Action:**
1. In the query editor, run:
   ```sql
   EXPORT DATA OPTIONS(
     uri='gs://bqcr-poc-cons-251217-22d0-egress-test/export_test_*.csv',
     format='CSV',
     overwrite=true
   ) AS
   SELECT event_name, COUNT(*) AS c
   FROM `bqcr-poc-cons-251217-22d0.linked_cr_poc_251217_22d0.user_events_view`
   GROUP BY event_name
   ```
2. Click **Run**

**Expected Result:** ❌ **NO** - Should show an error:
- `Access Denied: Table ... Data egress is restricted`

**What this proves:** **EXPORT DATA** statements are blocked by `restrictQueryResult=true`.

---

## Summary Table

| Operation | Allowed? | Why |
|-----------|----------|-----|
| See linked dataset in Explorer | ✅ YES | Discovery is allowed |
| Run `SELECT *` queries | ✅ YES | SQL queries work; results visible in grid |
| Use Preview button | ❌ NO | Direct table read APIs blocked |
| Run aggregate queries | ✅ YES | SQL queries work |
| Join with own data | ✅ YES | SQL queries work |
| Save results to table (CTAS) | ❌ NO | Materialization blocked |
| Copy linked view | ❌ NO | Copy/clone blocked |
| Export linked view | ❌ NO | Export blocked |
| Create view referencing linked data | ❌ NO | Materialization blocked |
| EXPORT DATA statement | ❌ NO | Export blocked |

---

## Key Insight

**Restricted egress** blocks **exfiltration paths** (copy/export/materialize), but **does NOT prevent seeing row-level data in query results** when you share a plain view.

To prevent raw data visibility, you need **clean room analysis rules** (aggregation threshold, differential privacy, etc.) in addition to restricted egress.

---

## Related Documentation

- **[Egress Controls Comparison](./55-egress-controls-comparison.md)**: Detailed comparison of what happens when egress controls are enabled vs disabled (or partially disabled). Includes findings that DCR exchanges always enforce restrictions, even when individual flags are set to `false`.

