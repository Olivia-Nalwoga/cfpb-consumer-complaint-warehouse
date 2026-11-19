-- P2 — Curated complaint table
-- One row = one published CFPB complaint

CREATE SCHEMA IF NOT EXISTS `seis-732-olivia.cfpb_curated`
  OPTIONS (location = 'US');

CREATE OR REPLACE TABLE `seis-732-olivia.cfpb_curated.complaints_curated`
AS
WITH cleaned AS (
  SELECT
    NULLIF(TRIM(complaint_id), '') AS complaint_id,
    NULLIF(TRIM(date_received), '') AS date_received_text,
    NULLIF(TRIM(date_sent_to_company), '') AS date_sent_to_company_text,
    NULLIF(TRIM(product), '') AS product,
    NULLIF(TRIM(sub_product), '') AS sub_product,
    NULLIF(TRIM(issue), '') AS issue,
    NULLIF(TRIM(sub_issue), '') AS sub_issue,
    NULLIF(TRIM(company_public_response), '') AS company_public_response,
    NULLIF(TRIM(company), '') AS company,
    NULLIF(TRIM(state), '') AS state,

    -- Keep ZIP as STRING because CFPB ZIP values may be partial or withheld.
    NULLIF(TRIM(zip_code), '') AS zip_code,
    NULLIF(TRIM(tags), '') AS tags,
    NULLIF(TRIM(submitted_via), '') AS submitted_via,
    NULLIF(TRIM(company_response_to_consumer), '')
      AS company_response_to_consumer,
    NULLIF(TRIM(timely_response), '') AS timely_response

  FROM `seis-732-olivia.cfpb_raw.complaints_raw`
),

parsed AS (
  SELECT
    *,
    SAFE.PARSE_DATE('%Y-%m-%d', date_received_text) AS date_received,
    SAFE.PARSE_DATE(
      '%Y-%m-%d',
      date_sent_to_company_text
    ) AS date_sent_to_company
  FROM cleaned
)

SELECT
  complaint_id,
  date_received,
  date_sent_to_company,
  product,
  sub_product,
  issue,
  sub_issue,
  company_public_response,
  company,
  state,
  zip_code,
  tags,
  submitted_via,
  company_response_to_consumer,
  timely_response,

  -- One complaint contributes one complaint to later measures.
  1 AS complaint_count,

  -- Supports the planned late-response rate.
  CASE
    WHEN timely_response = 'No' THEN 1
    ELSE 0
  END AS late_response_flag,

  CASE
    WHEN timely_response IN ('Yes', 'No') THEN 1
    ELSE 0
  END AS eligible_response_flag,

  -- Keep invalid routing pairs but do not fabricate a duration.
  CASE
    WHEN date_received IS NOT NULL
      AND date_sent_to_company IS NOT NULL
      AND date_sent_to_company >= date_received
    THEN DATE_DIFF(date_sent_to_company, date_received, DAY)
    ELSE NULL
  END AS days_to_forward,

  -- Explicit date-quality rule.
  CASE
    WHEN date_received_text IS NULL THEN 'missing_received_date'
    WHEN date_received IS NULL THEN 'malformed_received_date'
    WHEN date_sent_to_company_text IS NULL THEN 'missing_sent_date'
    WHEN date_sent_to_company IS NULL THEN 'malformed_sent_date'
    WHEN date_sent_to_company < date_received THEN 'reversed_date_pair'
    ELSE 'valid'
  END AS date_quality_status,

  -- Keep original text for traceability.
  date_received_text,
  date_sent_to_company_text

FROM parsed;


-- Curated verification

SELECT
  COUNT(*) AS curated_rows,
  COUNT(DISTINCT complaint_id) AS distinct_complaint_ids,
  COUNTIF(complaint_id IS NULL) AS missing_complaint_ids,
  COUNTIF(date_quality_status = 'reversed_date_pair') AS reversed_date_pairs
FROM `seis-732-olivia.cfpb_curated.complaints_curated`;
