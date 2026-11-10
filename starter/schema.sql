-- Every run your product does gets one row here. Day 4 builds the moat on it.
CREATE TABLE IF NOT EXISTS runs (
  id TEXT PRIMARY KEY,
  created_at TEXT NOT NULL,
  input TEXT NOT NULL,
  output TEXT,
  status TEXT NOT NULL,
  outcome TEXT,
  feedback TEXT
);
