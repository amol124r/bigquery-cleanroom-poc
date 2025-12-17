-- Producer-side setup (run in PRODUCER_PROJECT_ID)
-- Creates a dummy user event table that simulates sensitive identifiers.

CREATE SCHEMA IF NOT EXISTS `producer_raw`
OPTIONS (
  location = "US"
);

CREATE SCHEMA IF NOT EXISTS `producer_shared`
OPTIONS (
  location = "US"
);

CREATE OR REPLACE TABLE `producer_raw.user_events` (
  user_id STRING,
  event_ts TIMESTAMP,
  event_name STRING,
  purchase_amount NUMERIC
);

INSERT INTO `producer_raw.user_events` (user_id, event_ts, event_name, purchase_amount)
VALUES
  ("u001", TIMESTAMP("2025-01-01T10:00:00Z"), "page_view", NULL),
  ("u001", TIMESTAMP("2025-01-01T10:05:00Z"), "add_to_cart", NULL),
  ("u001", TIMESTAMP("2025-01-01T10:10:00Z"), "purchase", 120.50),
  ("u002", TIMESTAMP("2025-01-02T11:00:00Z"), "page_view", NULL),
  ("u002", TIMESTAMP("2025-01-02T11:15:00Z"), "purchase", 42.00),
  ("u003", TIMESTAMP("2025-01-03T09:00:00Z"), "page_view", NULL);

-- Optional: a projection view that removes obviously sensitive fields (if desired).
-- Note: Clean-room analysis rules are the primary mechanism to prevent raw access.
CREATE OR REPLACE VIEW `producer_shared.user_events_view` AS
SELECT
  user_id,
  event_ts,
  event_name,
  purchase_amount
FROM `producer_raw.user_events`;


