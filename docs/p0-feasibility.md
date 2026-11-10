# P0 — Need, Audience, Dataset & Feasibility

## 1. Working title

Consumer Financial Complaint Operations & Risk Intelligence Warehouse

## 2. Audience and need

The primary audience is a compliance or customer-operations manager at a financial-services organization.

This audience needs to monitor complaint patterns, identify products or issues that may require attention, and understand whether companies are responding to complaints in a timely way.

A data product could help by organizing complaint information into consistent measures and trends that can be reviewed repeatedly instead of relying on ad hoc analysis of raw complaint records.

If the product is useful, the audience could use it to prioritize areas for investigation, monitor complaint trends over time, identify emerging issue categories, and focus operational review on products or complaint types with unusual patterns.

## 3. Proposed analytical product and questions

The likely consumption artifact is a dashboard supported by a BigQuery serving layer. The dashboard will summarize complaint trends, response timeliness, product and issue patterns, and geographic variation.

Initial analytical questions:

1. Which products and issues generate the highest complaint volumes, and how do those patterns change over time?
2. How does timely-response performance vary across companies, products, and complaint categories?
3. How many days elapse between the CFPB receiving a complaint and sending it to the company, and where do unusually long intervals occur?
4. Which states have the highest complaint volumes, and could population-adjusted rates improve geographic comparisons as a later extension?

## 4. Source identification and access

**Provider:** Consumer Financial Protection Bureau (CFPB)

**Dataset:** Consumer Complaint Database

**Official source page:**  
https://www.consumerfinance.gov/data-research/consumer-complaints/

**Direct CSV download:**  
https://files.consumerfinance.gov/ccdb/complaints.csv.zip

**Field reference:**  
https://cfpb.github.io/api/ccdb/fields.html

The project uses the official CFPB complaint CSV download because the BigQuery public version available in `bigquery-public-data.cfpb_complaints` was not current enough for the project.

The current source was downloaded from the official CFPB website, stored privately in Google Cloud Storage, and loaded into BigQuery.

**Google Cloud Storage bucket:** `seis-732-olivia-cfpb`

**BigQuery project:** `seis-732-olivia`

**Raw dataset:** `cfpb_raw`

**Raw table:** `complaints_raw`

**Processing location:** `US`

**Source format and size:** CSV distributed as a ZIP archive. The downloaded ZIP was approximately 364.6 MB, and the extracted CSV was approximately 5.8 GB.

**Ingestion process:** The official CFPB ZIP was downloaded from the CFPB website and retained in a private Google Cloud Storage bucket. The extracted `complaints.csv` file was uploaded to the same bucket and loaded into `seis-732-olivia.cfpb_raw.complaints_raw` in BigQuery using reproducible SQL.

**Refresh behavior:** CFPB states that the Consumer Complaint Database generally updates daily. The project uses a dated source extract, so the dataset represents the state of the source at the time it was downloaded.

**Instructor approval:** The use of the current CFPB external source was approved by the instructor before continuing with the project.

The source is freely available from the CFPB for analysis and reuse. The source data files themselves are not stored in the GitHub repository.

## 5. Quick source profile

The raw CFPB source currently contains 19,028,339 complaint records.

The candidate row meaning is:

**One row represents one published consumer complaint.**

This candidate grain is strongly supported by the source because:

- Total rows: 19,028,339
- Distinct complaint IDs: 19,028,339
- Null or blank complaint IDs: 0

Date coverage:

- Earliest complaint date: 2011-12-01
- Latest complaint date: 2026-11-09
- Unparseable received dates: 0

Important source-quality findings:

- 7,050 records have `date_sent_to_company` earlier than `date_received`
- 235,275 records are missing sub-product
- 948,354 records are missing sub-issue
- 63,721 records are missing state
- 3,564 records are missing ZIP code
- 21 records are missing company response to consumer
- Product is complete
- Company is complete
- Submitted-via is complete
- Timely-response is complete

Submission channels observed:

- Web
- Referral
- Phone
- Postal mail
- Fax
- Email

The source contains 179 distinct issue values and 272 distinct sub-issue values.

The product taxonomy changes over time. CFPB documentation shows that product, sub-product, issue, and sub-issue options were reorganized in 2017, 2023, and 2026. Historical complaint records preserve the original selections that were available when the complaint was submitted.

This means historical taxonomy values should not be overwritten with newer labels without an explicit mapping strategy.

## 6. Need-to-source fit

| **Proposed question** | **Needed fields or concepts** | **Candidate source object(s)** | **Why the source appears sufficient** | **Gap or assumption to test in P1** |
| --- | --- | --- | --- | --- |
| Which products and issues generate the highest complaint volumes, and how do patterns change over time? | date_received, product, sub_product, issue, sub_issue, complaint_id | `cfpb_raw.complaints_raw` | The source has long date coverage, complete product values, and detailed issue categories | Historical taxonomy changes may affect direct cross-year comparisons |
| How does timely-response performance vary across companies, products, and complaint categories? | company, product, issue, timely_response | `cfpb_raw.complaints_raw` | Timely response is complete and company/product fields are available | Company complaint volume should not be treated as a failure rate without exposure or market-size context |
| How many days elapse between the CFPB receiving a complaint and sending it to the company, and where do unusually long intervals occur? | date_received, date_sent_to_company | `cfpb_raw.complaints_raw` | Both fields are available and parse cleanly | 7,050 records have sent dates earlier than received dates and require a curation rule |
| Which states have the highest complaint volumes, and could population-adjusted rates improve comparisons? | state, complaint_id, date_received; population if later extended | `cfpb_raw.complaints_raw`; possible later Census source | State is available for most complaint records | Population normalization would require an additional source, matching-year coverage, and any required approval |

## 7. Feasibility risks and response
### Risk 1: Historical taxonomy changes

CFPB has changed product, sub-product, issue, and sub-issue options over time. Historical complaint data preserves the original values.

**Response:** Preserve the original values in Raw and Curated. If cross-period harmonization is needed later, create a separate documented reporting mapping instead of overwriting historical values.

### Risk 2: Invalid date relationships

There are 7,050 records where `date_sent_to_company` is earlier than `date_received`.

**Response:** Investigate these records in P1/P2 and define an explicit curation rule before using a derived days-to-send measure.

### Risk 3: Complaint volume can be misinterpreted

Large companies or firms that interact with more consumers may naturally have more complaints.

**Response:** Treat complaint counts as monitoring signals, not direct failure rates. Clearly document the limitation in the final product.

### Fallback

If the full project becomes too broad, the project will remain focused on the CFPB source only and prioritize product/issue trends, response timeliness, and complaint-processing analysis. Census population normalization will remain optional.

## 8. First P1 decision

The first major P1 decision will be how to represent historical product and issue taxonomy changes while preserving the source meaning of each complaint.

The likely approach is to preserve the original CFPB taxonomy values and separately evaluate whether a reporting-level harmonization is necessary for cross-period trend analysis.

## 9. AI/tool accountability

AI assistance was used to help organize project ideas, draft SQL, interpret profiling results, and structure documentation.

All major claims were checked against the actual source data loaded in BigQuery, CFPB documentation, and course requirements. Profiling queries were run directly in the project environment, and the reported counts and date ranges come from those observed results.
