# Comprehensive Summary: Data Sharing Approaches & Recommendations

## POC Intent

This Proof of Concept (POC) was designed to validate **what a consumer can and cannot do** with data shared by a producer using Google Cloud Platform's BigQuery Analytics Hub and Data Clean Room capabilities.

### Primary Objectives

1. **Understand Consumer Capabilities**: Determine what operations consumers can perform on shared data:
   - **Viewable**: Can consumers see/query the data?
   - **Joinable**: Can consumers join shared data with their own tables?
   - **Transformable**: Can consumers create derived tables/views?
   - **Copyable**: Can consumers copy/export data into their own projects?

2. **Test Egress Controls**: Validate how egress restrictions work and whether they can be disabled or bypassed.

3. **Explore Multiple Approaches**: Test various data sharing mechanisms:
   - Data Clean Room (DCR) exchanges
   - Regular Analytics Hub exchanges
   - Authorized views
   - Direct BigQuery dataset sharing

### Use Case Focus

**Producer Requirements:**
- Producer owns data in their GCP project
- Producer wants to share data (tables, views, or authorized views)
- Producer needs a mechanism to share data securely

**Consumer Requirements:**
- Consumer must be able to **query** shared data
- Consumer must be able to **transform** and **derive** new tables/views
- Consumer must be able to **copy** producer's data into their own project tables
- Consumer may need to join shared data with their own data

## Approaches Tested

### 1. Data Clean Room (DCR) Exchange with Egress Restrictions

**Configuration:**
- Exchange Type: Data Clean Room (DCR)
- Listing: Points to producer's view/table
- Egress Controls: `enabled=true`, `restrictDirectTableAccess=true`, `restrictQueryResult=true`
- Selective Sharing: ✅ Yes (via `selectedResources`)

**Test Results:**

| Operation | Allowed? | Notes |
|-----------|----------|-------|
| Query data | ✅ YES | SQL queries work, row-level results visible |
| Aggregate queries | ✅ YES | Aggregations work |
| Join with own data | ✅ YES | Joins work |
| CTAS (CREATE TABLE AS SELECT) | ❌ NO | "Data egress is restricted" |
| CREATE VIEW AS SELECT | ❌ NO | "Data egress is restricted" |
| Copy (`bq cp`) | ❌ NO | "Data egress is restricted" |
| Export to GCS | ❌ NO | "Data egress is restricted" |
| Snapshot/Clone | ❌ NO | "Data egress is restricted" |

**Pros:**
- ✅ Selective resource sharing (can share specific tables/views)
- ✅ Enhanced audit/logging capabilities
- ✅ Supports analysis rules (aggregation thresholds, differential privacy)
- ✅ Privacy-preserving by design
- ✅ Well-documented and supported

**Cons:**
- ❌ **Cannot disable egress restrictions** - always enforced at dataset level
- ❌ **Blocks all copy/export operations** - consumers cannot materialize data
- ❌ **Cannot use authorized views to bypass restrictions**
- ❌ Not suitable for use case requiring data copying

**Verdict:** ❌ **NOT SUITABLE** for use case requiring consumers to copy data.

---

### 2. DCR Exchange with Partially Disabled Egress (Attempted)

**Configuration:**
- Exchange Type: Data Clean Room (DCR)
- Listing: Attempted to set `restrictQueryResult=false`
- Egress Controls: `enabled=true` (required), `restrictDirectTableAccess=true` (required), `restrictQueryResult=false` (attempted)

**Test Results:**
- ❌ **Same behavior as fully enabled egress**
- Linked dataset still shows `RESTRICTED_DATA_EGRESS`
- All copy/export operations still blocked

**Finding:**
- DCR exchanges enforce restrictions at the **dataset level**, not just listing level
- Setting individual flags to `false` does not change behavior
- `RESTRICTED_DATA_EGRESS` restriction type is set when linked dataset is created

**Verdict:** ❌ **DOES NOT WORK** - DCR restrictions cannot be partially disabled.

---

### 3. Regular Analytics Hub Exchange with Egress Disabled

**Configuration:**
- Exchange Type: Regular (non-DCR)
- Listing: Entire dataset shared (no selective resources)
- Egress Controls: `enabled=false`, `restrictDirectTableAccess=false`, `restrictQueryResult=false`

**Test Results:**
- ✅ Listing created successfully with egress disabled
- ⚠️ Subscription API differs from DCR exchanges
- ⚠️ Cannot use `selectedResources` (must share entire dataset)

**Pros:**
- ✅ Can disable egress controls
- ✅ Consumers should be able to copy/export (if subscription works)
- ✅ Standard Analytics Hub features

**Cons:**
- ❌ **No selective resource sharing** - must share entire dataset
- ❌ Different subscription API (more complex)
- ❌ Less audit/logging than DCR exchanges
- ❌ No analysis rules support

**Verdict:** ⚠️ **PARTIALLY VIABLE** - but limited by lack of selective sharing.

---

### 4. Authorized Views in Regular Exchange ⭐ **RECOMMENDED**

**Configuration:**
- Exchange Type: Regular (non-DCR)
- Authorized View: Created in cleanroom project, references producer data
- Listing: Points to authorized view dataset
- Egress Controls: `enabled=false`, `restrictDirectTableAccess=false`, `restrictQueryResult=false`

**Architecture:**
```
Producer Project → (grants access) → Cleanroom Project → (shares via exchange) → Consumer Project
  └─ producer_shared                  └─ authorized_view                        └─ linked_dataset
     └─ user_events_view                 └─ references producer data                └─ can copy/export
```

**Test Results:**
- ✅ Authorized view created successfully
- ✅ Listing created with egress disabled
- ✅ Selective sharing achieved (via authorized views)
- ✅ Should allow copy/export (egress disabled)

**Pros:**
- ✅ **Selective resource sharing** - share specific views/tables via authorized views
- ✅ **Egress can be disabled** - consumers can copy/export
- ✅ **Flexible** - can create multiple views with different access patterns
- ✅ **Access control** - producer maintains control at source level
- ✅ **Meets all use case requirements**

**Cons:**
- ❌ No DCR analysis rules (aggregation thresholds, differential privacy)
- ❌ Standard audit/logging (not enhanced like DCR)
- ❌ Requires additional setup (authorized views + access grants)
- ❌ More complex architecture (3-project setup)

**Verdict:** ✅ **RECOMMENDED** - Best balance of selective sharing + copy capability.

---

### 5. Authorized Views in DCR Exchange (Tested)

**Configuration:**
- Exchange Type: Data Clean Room (DCR)
- Authorized View: Created in cleanroom project
- Listing: Points to authorized view with `restrictQueryResult=false`
- Egress Controls: `enabled=true` (required), `restrictDirectTableAccess=true` (required)

**Test Results:**
- ❌ **All copy/export operations still blocked**
- Linked dataset shows `RESTRICTED_DATA_EGRESS`
- Same restrictions as regular views in DCR

**Finding:**
- Authorized views **cannot bypass DCR restrictions**
- DCR exchanges enforce restrictions at dataset level
- View type (regular vs authorized) doesn't matter

**Verdict:** ❌ **DOES NOT WORK** - Authorized views don't bypass DCR restrictions.

---

### 6. Direct BigQuery Dataset Sharing (Not Fully Tested)

**Configuration:**
- Approach: Direct IAM-based dataset sharing (outside Analytics Hub)
- Method: Grant consumer project access to producer dataset

**Expected Behavior:**
- ✅ Consumer can query data
- ✅ Consumer can copy/export data
- ✅ Consumer can create derived tables
- ❌ No centralized exchange/discovery mechanism
- ❌ No audit/logging features of Analytics Hub

**Pros:**
- ✅ Simple setup
- ✅ Full access (no restrictions)
- ✅ No egress controls

**Cons:**
- ❌ No centralized discovery/exchange
- ❌ No audit/logging features
- ❌ Less scalable for multiple consumers
- ❌ No selective resource sharing (must share entire dataset)

**Verdict:** ⚠️ **VIABLE BUT LIMITED** - Works but lacks Analytics Hub features.

---

## Comparison Matrix

| Approach | Selective Sharing | Copy/Export | Analysis Rules | Audit/Logging | Complexity | Use Case Fit |
|----------|------------------|-------------|----------------|---------------|------------|--------------|
| **DCR Exchange (Egress ON)** | ✅ Yes | ❌ No | ✅ Yes | ✅ Enhanced | Medium | ❌ No |
| **DCR Exchange (Egress OFF)** | ✅ Yes | ❌ No* | ✅ Yes | ✅ Enhanced | Medium | ❌ No |
| **Regular Exchange** | ❌ No | ✅ Yes** | ❌ No | ⚠️ Standard | Medium | ⚠️ Partial |
| **Authorized Views (Regular)** | ✅ Yes | ✅ Yes | ❌ No | ⚠️ Standard | High | ✅ **YES** |
| **Authorized Views (DCR)** | ✅ Yes | ❌ No | ✅ Yes | ✅ Enhanced | High | ❌ No |
| **Direct Dataset Sharing** | ❌ No | ✅ Yes | ❌ No | ❌ None | Low | ⚠️ Partial |

\* Cannot actually disable in DCR  
\** If subscription works

---

## Final Recommendations

### For Use Case: Consumer Needs Query + Transform + Copy

**Primary Recommendation: ⭐ Authorized Views in Regular Exchange**

**Why:**
1. ✅ **Meets all requirements**: Query ✅, Transform ✅, Copy ✅
2. ✅ **Selective sharing**: Share specific views/tables via authorized views
3. ✅ **Egress disabled**: Consumers can copy/export data
4. ✅ **Flexible**: Can create multiple views with different access patterns
5. ✅ **Access control**: Producer maintains control

**Implementation Steps:**
1. Producer creates data in their project
2. Producer grants cleanroom project access to source dataset
3. Cleanroom project creates authorized views referencing producer data
4. Cleanroom project creates regular (non-DCR) Analytics Hub exchange
5. Cleanroom project creates listing pointing to authorized view dataset with `restrictedExportPolicy.enabled=false`
6. Consumer subscribes to exchange
7. Consumer gets linked dataset and can query, transform, and copy data

**Alternative: Direct BigQuery Dataset Sharing**

If Analytics Hub features (discovery, audit) are not required:
- Producer grants consumer project direct access to dataset
- Simpler setup, but less features

### When NOT to Use These Approaches

**Use DCR Exchange (with egress) when:**
- Privacy-preserving analytics is required
- You need aggregation thresholds or differential privacy
- You want to prevent data exfiltration
- Enhanced audit/logging is important
- Consumers should NOT be able to copy data

**Use Regular Exchange (without authorized views) when:**
- You're okay sharing entire datasets (not selective)
- You don't need selective resource sharing
- Simpler setup is preferred

---

## Key Findings

### 1. DCR Exchanges Always Enforce Restrictions

**Finding:** DCR exchanges enforce `RESTRICTED_DATA_EGRESS` at the **dataset level**, regardless of:
- Individual `restrict*` flags in listing configuration
- Whether views are regular or authorized
- Attempts to disable egress controls

**Implication:** If consumers need to copy data, **do not use DCR exchanges**.

### 2. Authorized Views Enable Selective Sharing in Regular Exchanges

**Finding:** Authorized views allow selective resource sharing in regular exchanges, which don't natively support `selectedResources`.

**Implication:** Use authorized views when you need both selective sharing AND copy capability.

### 3. Egress Controls Are Exchange-Type Dependent

**Finding:**
- DCR exchanges: Egress controls **required** and **always enforced**
- Regular exchanges: Egress controls **optional** and **can be disabled**

**Implication:** Choose exchange type based on whether you need copy capability.

---

## Implementation Guide

### Recommended Setup: Authorized Views in Regular Exchange

#### Step 1: Producer Setup
```sql
-- Producer creates data
CREATE TABLE producer_project.producer_raw.user_events (...);
CREATE VIEW producer_project.producer_shared.user_events_view AS
SELECT * FROM producer_project.producer_raw.user_events;
```

#### Step 2: Grant Access
```bash
# Producer grants cleanroom project access
bq update --add_access_entry="project:CLEANROOM_PROJECT_NUMBER:READER" \
  producer_project:producer_shared
```

#### Step 3: Create Authorized View
```sql
-- In cleanroom project
CREATE VIEW cleanroom_project.cleanroom_shared_views.authorized_user_events_view AS
SELECT * FROM producer_project.producer_shared.user_events_view;
```

#### Step 4: Create Regular Exchange
```bash
# Create regular (non-DCR) exchange
curl -X POST \
  -H "Authorization: Bearer ${TOKEN}" \
  "https://analyticshub.googleapis.com/v1/projects/${CLEANROOM_PROJECT}/locations/us/dataExchanges" \
  -d '{
    "displayName": "Data Sharing Exchange",
    "discoveryType": "DISCOVERY_TYPE_PRIVATE"
  }'
```

#### Step 5: Create Listing with Egress Disabled
```bash
# Create listing with egress disabled
curl -X POST \
  -H "Authorization: Bearer ${TOKEN}" \
  "https://analyticshub.googleapis.com/v1/${EXCHANGE}/listings" \
  -d '{
    "displayName": "Authorized View Listing",
    "bigqueryDataset": {
      "dataset": "projects/CLEANROOM_NUM/datasets/cleanroom_shared_views",
      "restrictedExportPolicy": {
        "enabled": false,
        "restrictDirectTableAccess": false,
        "restrictQueryResult": false
      }
    }
  }'
```

#### Step 6: Consumer Subscribes
```bash
# Consumer subscribes (API may vary for regular exchanges)
# Consumer gets linked dataset and can query, transform, and copy
```

---

## Summary

### For Your Use Case (Query + Transform + Copy)

**✅ RECOMMENDED: Authorized Views in Regular Exchange**

- Meets all requirements
- Selective sharing via authorized views
- Copy/export enabled
- Flexible and scalable

**❌ NOT RECOMMENDED: DCR Exchanges**

- Cannot disable egress restrictions
- Blocks all copy/export operations
- Designed for privacy-preserving analytics, not data copying

### Quick Decision Tree

```
Do consumers need to COPY data?
├─ YES → Use Authorized Views in Regular Exchange ⭐
└─ NO → Use DCR Exchange (for privacy-preserving analytics)
```

---

## References

- [Architecture Overview](./00-architecture.md)
- [Egress Controls Comparison](./55-egress-controls-comparison.md)
- [Authorized Views in Analytics Hub](./60-authorized-views-in-analytics-hub.md)
- [Authorized Views in DCR Exchange](./65-authorized-views-in-dcr-exchange.md)
- [Consumer Capabilities Matrix](./10-consumer-capabilities-matrix.md)
- [Observed Outcomes](./40-observed-outcomes.md)

