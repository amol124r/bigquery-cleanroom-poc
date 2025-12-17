-- Consumer-side setup (run in CONSUMER_PROJECT_ID)
-- Creates a first-party table the consumer will try to join with clean-room shared data.

CREATE SCHEMA IF NOT EXISTS `consumer_first_party`
OPTIONS (
  location = "US"
);

CREATE SCHEMA IF NOT EXISTS `consumer_derived`
OPTIONS (
  location = "US"
);

CREATE OR REPLACE TABLE `consumer_first_party.user_attributes` (
  user_id STRING,
  segment STRING,
  country STRING
);

INSERT INTO `consumer_first_party.user_attributes` (user_id, segment, country)
VALUES
  ("u001", "high_value", "US"),
  ("u002", "mid_value", "US"),
  ("u003", "low_value", "IN"),
  ("u999", "unknown", "US");


