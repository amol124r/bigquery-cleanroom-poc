-- Validation queries to run from the CONSUMER_PROJECT_ID after subscription
-- Replace `LINKED_DATASET` and `SHARED_RESOURCE` with your actual linked dataset + view/table names.
--
-- Examples:
--   `LINKED_DATASET` = `cleanroom_linked`
--   `SHARED_RESOURCE` = `user_events_view` (often an analysis-rule enforced view created via clean room listing)

-- 1) Basic select (expected to be blocked or constrained depending on analysis rules)
-- SELECT * FROM `LINKED_DATASET.SHARED_RESOURCE` LIMIT 10;

-- 2) Example aggregation query (expected to be allowed in clean rooms if it satisfies rules)
-- SELECT
--   event_name,
--   COUNT(*) AS event_count
-- FROM `LINKED_DATASET.SHARED_RESOURCE`
-- GROUP BY event_name
-- ORDER BY event_count DESC;

-- 3) Join with consumer first-party data (expected to be allowed only via safe/aggregated results)
-- SELECT
--   a.segment,
--   e.event_name,
--   COUNT(*) AS events
-- FROM `consumer_first_party.user_attributes` a
-- JOIN `LINKED_DATASET.SHARED_RESOURCE` e
--   ON e.user_id = a.user_id
-- GROUP BY a.segment, e.event_name
-- ORDER BY events DESC;

-- 4) Attempt to materialize results (expected to FAIL when egress is restricted)
-- CREATE TABLE `consumer_first_party.derived_events_by_segment` AS
-- SELECT
--   a.segment,
--   e.event_name,
--   COUNT(*) AS events
-- FROM `consumer_first_party.user_attributes` a
-- JOIN `LINKED_DATASET.SHARED_RESOURCE` e
--   ON e.user_id = a.user_id
-- GROUP BY a.segment, e.event_name;

-- 5) Attempt to create a view in consumer project (expected to FAIL when egress is restricted)
-- CREATE VIEW `consumer_first_party.v_events_by_segment` AS
-- SELECT
--   a.segment,
--   e.event_name,
--   COUNT(*) AS events
-- FROM `consumer_first_party.user_attributes` a
-- JOIN `LINKED_DATASET.SHARED_RESOURCE` e
--   ON e.user_id = a.user_id
-- GROUP BY a.segment, e.event_name;


