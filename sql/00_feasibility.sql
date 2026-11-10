-- ============================================================
-- P0 FEASIBILITY PROFILING
-- Project: Consumer Financial Complaint Operations & Risk
--          Intelligence Warehouse
-- Source:  seis-732-olivia.cfpb_raw.complaints_raw
-- Purpose:
--   Profile the CFPB source to evaluate grain, date coverage,
--   completeness, categories, and key feasibility risks.
-- ============================================================


-- ============================================================
-- STEP 1: Confirm total row count and complaint ID uniqueness
-- Purpose:
--   Evaluate whether one row can represent one published
--   consumer complaint.
-- ============================================================

SELECT
  COUNT(*) AS total_rows,
  COUNT(DISTINCT complaint_id) AS distinct_complaint_ids,
  COUNTIF(complaint_id IS NULL OR TRIM(complaint_id) = '') AS missing_complaint_ids
FROM `seis-732-olivia.cfpb_raw.complaints_raw`;


-- ============================================================
-- STEP 2: Check complaint date coverage and parse quality
-- Purpose:
--   Identify the historical coverage of the source and confirm
--   whether date_received can be parsed as YYYY-MM-DD.
-- ============================================================

SELECT
  MIN(SAFE.PARSE_DATE('%Y-%m-%d', date_received)) AS earliest_date_received,
  MAX(SAFE.PARSE_DATE('%Y-%m-%d', date_received)) AS latest_date_received,
  COUNTIF(
    SAFE.PARSE_DATE('%Y-%m-%d', date_received) IS NULL
    AND date_received IS NOT NULL
    AND TRIM(date_received) != ''
  ) AS unparseable_date_received
FROM `seis-732-olivia.cfpb_raw.complaints_raw`;


-- ============================================================
-- STEP 3: Check missing values in important analytical fields
-- Purpose:
--   Identify fields that may require explicit Curated-layer
--   handling.
-- ============================================================

SELECT
  COUNT(*) AS total_rows,
  COUNTIF(product IS NULL OR TRIM(product) = '') AS missing_product,
  COUNTIF(sub_product IS NULL OR TRIM(sub_product) = '') AS missing_sub_product,
  COUNTIF(issue IS NULL OR TRIM(issue) = '') AS missing_issue,
  COUNTIF(sub_issue IS NULL OR TRIM(sub_issue) = '') AS missing_sub_issue,
  COUNTIF(company IS NULL OR TRIM(company) = '') AS missing_company,
  COUNTIF(state IS NULL OR TRIM(state) = '') AS missing_state,
  COUNTIF(zip_code IS NULL OR TRIM(zip_code) = '') AS missing_zip_code,
  COUNTIF(submitted_via IS NULL OR TRIM(submitted_via) = '') AS missing_submitted_via,
  COUNTIF(
    company_response_to_consumer IS NULL
    OR TRIM(company_response_to_consumer) = ''
  ) AS missing_company_response_to_consumer,
  COUNTIF(
    timely_response IS NULL
    OR TRIM(timely_response) = ''
  ) AS missing_timely_response
FROM `seis-732-olivia.cfpb_raw.complaints_raw`;


-- ============================================================
-- STEP 4: Check date relationship quality
-- Purpose:
--   Identify records where date_sent_to_company occurs before
--   date_received. These records may need to be flagged or
--   excluded from a future days-to-send metric.
-- ============================================================

SELECT
  COUNT(*) AS sent_before_received_count
FROM `seis-732-olivia.cfpb_raw.complaints_raw`
WHERE SAFE.PARSE_DATE('%Y-%m-%d', date_sent_to_company)
      < SAFE.PARSE_DATE('%Y-%m-%d', date_received);


-- ============================================================
-- STEP 5: Profile submission channels
-- Purpose:
--   Confirm the distinct values available for submission-channel
--   analysis.
-- ============================================================

SELECT
  submitted_via,
  COUNT(*) AS complaint_count
FROM `seis-732-olivia.cfpb_raw.complaints_raw`
GROUP BY submitted_via
ORDER BY complaint_count DESC;


-- ============================================================
-- STEP 6: Count distinct issue and sub-issue values
-- Purpose:
--   Evaluate the breadth of complaint classifications.
-- ============================================================

SELECT
  COUNT(DISTINCT issue) AS distinct_issue_count,
  COUNT(DISTINCT sub_issue) AS distinct_sub_issue_count
FROM `seis-732-olivia.cfpb_raw.complaints_raw`;


-- ============================================================
-- STEP 7: Profile product values
-- Purpose:
--   Inspect historical product labels and identify evidence of
--   taxonomy changes over time.
-- ============================================================

SELECT
  product,
  COUNT(*) AS complaint_count
FROM `seis-732-olivia.cfpb_raw.complaints_raw`
GROUP BY product
ORDER BY complaint_count DESC;


-- ============================================================
-- STEP 8: Profile timely-response values
-- Purpose:
--   Confirm the categories and completeness of the
--   timely_response field.
-- ============================================================

SELECT
  timely_response,
  COUNT(*) AS complaint_count
FROM `seis-732-olivia.cfpb_raw.complaints_raw`
GROUP BY timely_response
ORDER BY complaint_count DESC;


-- ============================================================
-- STEP 9: Profile company-response categories
-- Purpose:
--   Understand how company response outcomes are represented.
--   Note that this field is different from timely_response.
-- ============================================================

SELECT
  company_response_to_consumer,
  COUNT(*) AS complaint_count
FROM `seis-732-olivia.cfpb_raw.complaints_raw`
GROUP BY company_response_to_consumer
ORDER BY complaint_count DESC;


-- ============================================================
-- STEP 10: Profile complaint volume by year
-- Purpose:
--   Evaluate historical coverage and complaint-volume patterns.
--   The latest year may be incomplete and should be labeled YTD
--   in later analysis.
-- ============================================================

SELECT
  EXTRACT(
    YEAR FROM SAFE.PARSE_DATE('%Y-%m-%d', date_received)
  ) AS complaint_year,
  COUNT(*) AS complaint_count
FROM `seis-732-olivia.cfpb_raw.complaints_raw`
WHERE SAFE.PARSE_DATE('%Y-%m-%d', date_received) IS NOT NULL
GROUP BY complaint_year
ORDER BY complaint_year;
