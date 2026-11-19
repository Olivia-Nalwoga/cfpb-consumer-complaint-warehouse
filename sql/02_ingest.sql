-- P2 — Source-to-Raw ingestion / verification
-- Project: seis-732-olivia
-- Raw table: seis-732-olivia.cfpb_raw.complaints_raw
-- Processing location: US

-- The CFPB source extract was downloaded from the official
-- Consumer Complaint Database, stored in Google Cloud Storage,
-- and loaded into this Raw table before P2.
--
-- P2 reuses the existing Raw input rather than reloading the
-- multi-GB source solely to produce new evidence.

-- Verify Raw row count and complaint grain.

SELECT
  COUNT(*) AS raw_rows,
  COUNT(DISTINCT complaint_id) AS distinct_complaint_ids,
  COUNTIF(complaint_id IS NULL OR TRIM(complaint_id) = '')
    AS missing_complaint_ids
FROM `seis-732-olivia.cfpb_raw.complaints_raw`;


-- Verify Raw date coverage.

SELECT
  MIN(SAFE.PARSE_DATE('%Y-%m-%d', NULLIF(TRIM(date_received), '')))
    AS earliest_received_date,
  MAX(SAFE.PARSE_DATE('%Y-%m-%d', NULLIF(TRIM(date_received), '')))
    AS latest_received_date
FROM `seis-732-olivia.cfpb_raw.complaints_raw`;


-- Verify the Raw schema used by the P2 Curated build.

SELECT
  column_name,
  data_type,
  is_nullable
FROM `seis-732-olivia.cfpb_raw.INFORMATION_SCHEMA.COLUMNS`
WHERE table_name = 'complaints_raw'
ORDER BY ordinal_position;
