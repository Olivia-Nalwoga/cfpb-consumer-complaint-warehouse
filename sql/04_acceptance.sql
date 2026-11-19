-- This SQL file contains acceptance checks for the
-- seis-732-olivia project, including checks for
-- Curated grain preservation and late-response flag reconciliation.

-- ============================================================
-- CHECK 1: Curated grain preservation
-- Risk:
-- Curation could accidentally duplicate complaints, remove rows,
-- or produce blank complaint identifiers.
--
-- Expected:
-- Raw rows = Curated rows
-- Missing complaint IDs = 0
-- Repeated complaint ID groups = 0
-- ============================================================

WITH repeated_ids AS (
  SELECT
    complaint_id,
    COUNT(*) AS rows_per_id
  FROM `seis-732-olivia.cfpb_curated.complaints_curated`
  GROUP BY complaint_id
  HAVING complaint_id IS NOT NULL
     AND COUNT(*) > 1
)

SELECT
  (
    SELECT COUNT(*)
    FROM `seis-732-olivia.cfpb_raw.complaints_raw`
  ) AS raw_rows,

  (
    SELECT COUNT(*)
    FROM `seis-732-olivia.cfpb_curated.complaints_curated`
  ) AS curated_rows,

  (
    SELECT COUNTIF(
      complaint_id IS NULL
      OR TRIM(complaint_id) = ''
    )
    FROM `seis-732-olivia.cfpb_curated.complaints_curated`
  ) AS missing_complaint_ids,

  (
    SELECT COUNT(*)
    FROM repeated_ids
  ) AS repeated_complaint_id_groups;


-- ============================================================
-- CHECK 2: Late-response flag reconciliation
-- Risk:
-- The Curated flags could misstate which complaints were late
-- or eligible for the planned late-response rate.
--
-- Expected:
-- Raw 'No' count = Curated late_response_flag sum
-- Raw Yes + No count = Curated eligible_response_flag sum
-- ============================================================

WITH raw_counts AS (
  SELECT
    COUNTIF(TRIM(timely_response) = 'No') AS raw_late_count,
    COUNTIF(TRIM(timely_response) IN ('Yes', 'No'))
      AS raw_eligible_count
  FROM `seis-732-olivia.cfpb_raw.complaints_raw`
),

curated_counts AS (
  SELECT
    SUM(late_response_flag) AS curated_late_count,
    SUM(eligible_response_flag) AS curated_eligible_count
  FROM `seis-732-olivia.cfpb_curated.complaints_curated`
)

SELECT
  raw_late_count,
  curated_late_count,
  raw_eligible_count,
  curated_eligible_count,

  raw_late_count = curated_late_count
    AS late_count_matches,

  raw_eligible_count = curated_eligible_count
    AS eligible_count_matches

FROM raw_counts
CROSS JOIN curated_counts;
