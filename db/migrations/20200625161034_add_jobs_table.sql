-- +micrate Up
  CREATE TABLE jobs (
    id INTEGER NOT NULL PRIMARY KEY,
    url TEXT NOT NULL,
    status TEXT DEFAULT 'NEW' NOT NULL,
    http_code INTEGER DEFAULT NULL
  );

  CREATE INDEX jobs_status_IDX ON jobs (status);
-- SQL in section 'Up' is executed when this migration is applied


-- +micrate Down
  DROP TABLE jobs;
-- SQL section 'Down' is executed when this migration is rolled back
