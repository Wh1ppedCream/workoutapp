CREATE TABLE IF NOT EXISTS diagnostic_events (
  receipt_id TEXT PRIMARY KEY NOT NULL,
  deletion_token_hash TEXT NOT NULL,
  schema_version INTEGER NOT NULL,
  kind TEXT NOT NULL,
  app_version TEXT NOT NULL,
  build_number INTEGER NOT NULL,
  platform TEXT NOT NULL,
  code TEXT NOT NULL,
  source TEXT NOT NULL,
  outcome TEXT NOT NULL,
  duration_bucket TEXT NOT NULL,
  item_count_bucket TEXT NOT NULL,
  manifest_version INTEGER,
  received_at INTEGER NOT NULL
);

CREATE INDEX IF NOT EXISTS diagnostic_events_received_at
  ON diagnostic_events (received_at);
