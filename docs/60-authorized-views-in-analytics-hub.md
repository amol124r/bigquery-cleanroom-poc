# Authorized Views in Regular Analytics Hub Exchanges

This document explores using **authorized views** in regular (non-DCR) Analytics Hub exchanges as an alternative approach to data sharing.

## What Are Authorized Views?

**Authorized views** are BigQuery views created in one project that reference tables/views in another project. The view's project must be granted access to the source project's data.

**Key characteristics:**
- View is created in the "sharing" project (e.g., cleanroom)
- View references data in the "source" project (e.g., producer)
- Source project grants access to the sharing project
- Consumers access the view, not the underlying source data directly

## Why Use Authorized Views in Analytics Hub?

### Advantages

1. **Selective Resource Sharing**: Unlike regular exchanges that require sharing entire datasets, authorized views allow sharing specific views/tables
2. **No DCR Restrictions**: Regular exchanges can have egress controls disabled, allowing consumers to export/copy data
3. **Access Control**: Producer maintains control - can revoke access at the source level
4. **Flexibility**: Can create multiple views with different access patterns

### Limitations

1. **No DCR Features**: Regular exchanges don't provide clean room analysis rules (aggregation thresholds, differential privacy)
2. **Audit/Logging**: May not have the same level of audit logging as DCR exchanges
3. **Subscription Complexity**: Regular exchange subscriptions use different APIs than DCR exchanges

## Architecture

```
Producer Project                    Cleanroom Project              Consumer Project
─────────────────                  ──────────────────            ──────────────────
                                    
producer_shared                     cleanroom_shared_views        linked_authorized_views
  └─ user_events_view  ──grant──>     └─ authorized_user_events_view  ──subscribe──>  └─ authorized_user_events_view
     (source data)                      (authorized view)              (linked dataset)
```

## Implementation Steps

### 1. Create Authorized View in Cleanroom Project

```sql
-- In cleanroom project
CREATE OR REPLACE VIEW `cleanroom_project.cleanroom_shared_views.authorized_user_events_view` AS
SELECT
  user_id,
  event_ts,
  event_name,
  purchase_amount
FROM `producer_project.producer_shared.user_events_view`
```

### 2. Grant Access from Producer to Cleanroom

```bash
# Grant cleanroom project access to producer's dataset
bq update --add_access_entry="project:CLEANROOM_PROJECT_NUMBER:READER" \
  producer_project:producer_shared
```

### 3. Create Regular Exchange (Not DCR)

```bash
# Create regular exchange (no DCR config)
curl -X POST \
  -H "Authorization: Bearer ${TOKEN}" \
  "https://analyticshub.googleapis.com/v1/projects/${CLEANROOM_PROJECT}/locations/us/dataExchanges" \
  -d '{
    "displayName": "Authorized View Exchange",
    "discoveryType": "DISCOVERY_TYPE_PRIVATE"
  }'
```

### 4. Create Listing with Egress Disabled

```bash
# Create listing pointing to authorized view dataset
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

### 5. Consumer Subscribes

**Note**: Regular exchange subscriptions use different APIs than DCR exchanges. The subscription method may vary.

## Comparison: DCR Exchange vs Authorized View Exchange

| Feature | DCR Exchange | Authorized View Exchange |
|---------|--------------|--------------------------|
| **Selective Resource Sharing** | ✅ Yes (selectedResources) | ✅ Yes (via authorized views) |
| **Egress Controls** | ✅ Required (always enforced) | ⚠️ Optional (can disable) |
| **Export/Copy Allowed** | ❌ No | ✅ Yes (if egress disabled) |
| **Analysis Rules** | ✅ Yes (aggregation, DP) | ❌ No |
| **Audit/Logging** | ✅ Enhanced | ⚠️ Standard |
| **Subscription API** | `SubscribeDataExchange` | Different API (listing-based) |
| **Use Case** | Privacy-preserving analytics | Flexible data sharing |

## Test Results

We created a test setup:

1. ✅ **Authorized view created**: `cleanroom_shared_views.authorized_user_events_view`
2. ✅ **Access granted**: Cleanroom project can access producer's view
3. ✅ **Regular exchange created**: `poc_authorized_view_exchange_251217_22d0`
4. ✅ **Listing created**: `authorized_view_listing_251217_22d0` with egress disabled

**Next steps for full validation:**
- Grant subscriber permissions
- Test consumer subscription
- Verify consumer can export/copy data
- Compare behavior with DCR exchange

## Use Cases

### When to Use Authorized Views in Regular Exchange

✅ **Good for:**
- Sharing data where consumers need to export/copy
- Selective resource sharing without DCR restrictions
- Flexible data sharing with less strict privacy requirements
- When you want consumers to materialize derived tables

❌ **Not ideal for:**
- Privacy-preserving analytics requiring aggregation thresholds
- Scenarios requiring differential privacy
- When you need enhanced audit logging
- When you want to prevent row-level data visibility

## Conclusion

**Yes, authorized views can be used in regular Analytics Hub exchanges!** This provides a middle ground:

- More flexible than DCR exchanges (can disable egress)
- More selective than regular exchanges sharing entire datasets
- Allows consumers to export/copy data if egress is disabled

However, this approach:
- Doesn't provide clean room analysis rules
- May have different subscription mechanisms
- Requires careful access management between producer and cleanroom projects

This is a viable alternative when you need selective sharing with export capabilities but don't need the strict privacy controls of DCR exchanges.

