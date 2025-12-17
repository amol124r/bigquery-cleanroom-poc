# Authorized Views in DCR Exchange: Can They Bypass Restrictions?

This document tests whether using **authorized views** within a **Data Clean Room (DCR) exchange** can allow consumers to copy/export data, bypassing DCR restrictions.

## Test Setup

### Configuration
- **Exchange Type**: Data Clean Room (DCR)
- **Authorized View**: Created in cleanroom project, references producer's data
- **Listing Configuration**:
  - `restrictedExportPolicy.enabled: true` (required for DCR)
  - `restrictDirectTableAccess: true` (required for DCR)
  - `restrictQueryResult: false` (attempted to allow copying)

### Test Results

| Operation | Result | Error Message |
|-----------|--------|---------------|
| **Query data** | ✅ **ALLOWED** | Query works, results visible |
| **CTAS (CREATE TABLE AS SELECT)** | ❌ **BLOCKED** | "Data egress is restricted" |
| **CREATE VIEW AS SELECT** | ❌ **BLOCKED** | "Data egress is restricted" |
| **bq cp (copy)** | ❌ **BLOCKED** | "Data egress is restricted" |
| **EXPORT DATA** | ❌ **BLOCKED** | "Data egress is restricted" |

## Key Finding

**Even with `restrictQueryResult: false` in the listing configuration, the linked dataset still shows `RESTRICTED_DATA_EGRESS` and all copy/export operations are blocked.**

### Linked Dataset Metadata

```json
{
  "type": "LINKED",
  "restrictions": {
    "type": "RESTRICTED_DATA_EGRESS"
  }
}
```

## Why This Happens

### DCR Exchanges Enforce Restrictions at Dataset Level

1. **DCR Requirement**: DCR exchanges **require** `restrictDirectTableAccess: true` - you cannot set it to `false`
2. **Dataset-Level Enforcement**: When a linked dataset is created from a DCR exchange, it automatically gets the `RESTRICTED_DATA_EGRESS` restriction type
3. **Restriction Persistence**: This restriction is set at the **dataset level**, not just the listing level, so it applies regardless of individual `restrict*` flags

### Authorized Views Don't Bypass DCR Restrictions

**Answer: NO** - Authorized views in DCR exchanges **cannot bypass DCR restrictions**.

Even though:
- The authorized view is created in the cleanroom project
- The listing has `restrictQueryResult: false`
- The view references producer data through authorized access

The linked dataset still enforces `RESTRICTED_DATA_EGRESS` because:
- It's created from a **DCR exchange**
- DCR exchanges always enforce restrictions at the dataset level
- The restriction type is set when the linked dataset is created, not based on the view type

## Comparison: Authorized Views in Different Exchange Types

| Exchange Type | Authorized View | Egress Controls | Copy/Export Allowed? |
|---------------|----------------|-----------------|----------------------|
| **DCR Exchange** | ✅ Can use | Required (always enforced) | ❌ **NO** - Restrictions enforced |
| **Regular Exchange** | ✅ Can use | Optional (can disable) | ✅ **YES** - If egress disabled |

## Conclusion

**Using authorized views within a DCR exchange does NOT enable copying data to consumer project's tables.**

### Why?
- DCR exchanges enforce `RESTRICTED_DATA_EGRESS` at the **dataset level**
- This restriction applies to **all** resources in the linked dataset, regardless of:
  - Whether they're regular views or authorized views
  - The individual `restrict*` flags in the listing
  - The view's access pattern

### Solution: Use Regular Exchange with Authorized Views

If you need to allow copying/exporting while using authorized views:

1. ✅ **Use a regular (non-DCR) exchange**
2. ✅ **Create authorized views in the cleanroom project**
3. ✅ **Set `restrictedExportPolicy.enabled: false` in the listing**
4. ✅ **Consumer can then copy/export data**

See [Authorized Views in Analytics Hub](./60-authorized-views-in-analytics-hub.md) for details on the regular exchange approach.

## Summary

| Approach | Exchange Type | Copy/Export | Use Case |
|----------|---------------|-------------|----------|
| **Authorized View in DCR** | DCR | ❌ Blocked | Privacy-preserving analytics (no export) |
| **Authorized View in Regular** | Regular | ✅ Allowed | Flexible sharing with export capability |
| **Regular View in DCR** | DCR | ❌ Blocked | Privacy-preserving analytics (no export) |

**Bottom line**: DCR exchanges are designed to enforce privacy controls, and this enforcement happens at the dataset level, not the view level. Authorized views don't provide a workaround for DCR restrictions.

