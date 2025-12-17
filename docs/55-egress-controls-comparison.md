# Egress Controls Comparison: ON vs OFF

This document compares consumer capabilities with **egress controls enabled** vs **disabled** (or partially disabled) in Analytics Hub.

## Test Configuration

### Configuration 1: Egress Controls FULLY ENABLED (Original Setup)
- **Exchange Type**: Data Clean Room (DCR)
- **Listing Configuration**:
  - `restrictedExportPolicy.enabled: true`
  - `restrictDirectTableAccess: true`
  - `restrictQueryResult: true`
- **Dataset Restriction**: `RESTRICTED_DATA_EGRESS`

### Configuration 2: Egress Controls PARTIALLY DISABLED (Attempted)
- **Exchange Type**: Data Clean Room (DCR)
- **Listing Configuration**:
  - `restrictedExportPolicy.enabled: true` (required for DCR)
  - `restrictDirectTableAccess: false`
  - `restrictQueryResult: false`
- **Dataset Restriction**: Still shows `RESTRICTED_DATA_EGRESS`

**Note**: We attempted to fully disable egress controls (`enabled: false`), but DCR exchanges require `enabled: true`. We also attempted to create a regular (non-DCR) exchange, but encountered API limitations for subscription.

## Test Results Comparison

| Test # | Operation | Egress ON<br/>(Config 1) | Egress Partially OFF<br/>(Config 2) | Notes |
|--------|-----------|--------------------------|-------------------------------------|-------|
| 1 | See linked dataset in Explorer | ✅ YES | ✅ YES | Discovery works in both cases |
| 2 | Run `SELECT *` queries | ✅ YES | ✅ YES | SQL queries work; row-level data visible |
| 3 | Use Preview button / `bq head` | ❌ NO<br/>Error: "Data egress is restricted" | ❌ NO<br/>Error: "Cannot list a table of type VIEW" | Different error, but still blocked. Views can't be listed with `bq head` anyway. |
| 4 | Run aggregate queries | ✅ YES | ✅ YES | Aggregate queries work in both cases |
| 5 | Join with own data | ✅ YES | ✅ YES | Joins work in both cases |
| 6 | Save results to table (CTAS) | ❌ NO<br/>Error: "Data egress is restricted" | ❌ NO<br/>Error: "Data egress is restricted" | Still blocked despite `restrictQueryResult: false` |
| 7 | Copy linked view (`bq cp`) | ❌ NO<br/>Error: "Data egress is restricted" | ❌ NO<br/>Error: "Data egress is restricted" | Still blocked |
| 8 | Export linked view | ❌ NO<br/>Error: "Data egress is restricted" | ❌ NO<br/>Error: "Data egress is restricted" | Still blocked |
| 9 | Create view referencing linked data | ❌ NO<br/>Error: "Data egress is restricted" | ❌ NO<br/>Error: "Data egress is restricted" | Still blocked despite `restrictQueryResult: false` |
| 10 | EXPORT DATA statement | ❌ NO<br/>Error: "Data egress is restricted" | ❌ NO<br/>Error: "Data egress is restricted" | Still blocked |

## Key Findings

### 1. DCR Exchanges Always Enforce Restrictions

**Finding**: Even when we set `restrictDirectTableAccess: false` and `restrictQueryResult: false` in the listing configuration, the linked dataset still shows:
```json
"restrictions": {
  "type": "RESTRICTED_DATA_EGRESS"
}
```

And all materialization/export operations remain blocked.

**Implication**: Data Clean Room exchanges appear to enforce restrictions at the dataset level, regardless of the individual `restrict*` flags in the listing configuration. The `RESTRICTED_DATA_EGRESS` restriction type is set when the linked dataset is created and persists.

### 2. Cannot Fully Disable Egress in DCR Exchanges

**Finding**: Attempting to set `restrictedExportPolicy.enabled: false` in a DCR exchange listing results in:
- Error when subscribing: `"restricted_export_config must be enabled in linked_dataset_creation_options.selected_resources"`

**Implication**: DCR exchanges **require** egress controls to be enabled. This is by design - clean rooms are meant to enforce privacy controls.

### 3. Regular Exchanges Have Different Limitations

**Finding**: We attempted to create a regular (non-DCR) exchange with egress disabled, but encountered:
- Regular exchanges don't support `selectedResources` (must share entire dataset)
- Regular exchanges use different subscription APIs
- Subscription to regular exchange listings failed with API structure errors

**Implication**: Regular exchanges may allow disabling egress, but they have different capabilities (no selective resource sharing) and different subscription mechanisms.

### 4. What Actually Works

**With Egress ON (Current Setup)**:
- ✅ Discovery and exploration
- ✅ SQL queries (including `SELECT *` with row-level results)
- ✅ Aggregate queries
- ✅ Joins with consumer's own data
- ❌ Materialization (CTAS, CREATE VIEW)
- ❌ Copy/clone operations
- ❌ Export operations
- ❌ Direct table read APIs (Preview, `bq head`)

**With Egress Partially OFF (Attempted)**:
- Same as above - no change in behavior despite setting flags to `false`

## Recommendations

### For Maximum Privacy (Current Setup)
- Use DCR exchange with egress controls fully enabled
- Add **analysis rules** (aggregation thresholds, differential privacy) if you need to prevent row-level data visibility in query results
- Current setup blocks all exfiltration paths while allowing analytical queries

### For Data Sharing Without Restrictions
- Use **regular BigQuery dataset sharing** (not Analytics Hub) if you want consumers to freely export/copy data
- OR use a **regular Analytics Hub exchange** (non-DCR) - but this requires sharing entire datasets, not selective resources
- Note: Regular exchanges may not provide the same level of audit/logging as DCR exchanges

### For Selective Resource Sharing Without Egress
- **Not currently supported** in Analytics Hub
- DCR exchanges require egress controls
- Regular exchanges don't support selective resource sharing

## Conclusion

**Data Clean Room exchanges are designed to enforce privacy controls**, and egress restrictions cannot be fully disabled. Even when individual restriction flags are set to `false`, the linked dataset maintains the `RESTRICTED_DATA_EGRESS` restriction type, and materialization/export operations remain blocked.

This is **by design** - clean rooms are meant to provide secure, privacy-preserving data sharing where consumers can analyze data but cannot exfiltrate it.

If you need to allow consumers to export/copy data, consider:
1. Using regular BigQuery dataset sharing (outside Analytics Hub)
2. Using a regular Analytics Hub exchange (but with entire dataset sharing, not selective)
3. Accepting that DCR exchanges enforce restrictions as a core feature

