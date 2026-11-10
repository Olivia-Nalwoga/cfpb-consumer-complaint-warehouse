# P0 Feasibility Evidence

This file records summarized results from the feasibility profiling queries in `sql/00_feasibility.sql`.

The purpose is to preserve reproducible evidence for the P0 feasibility assessment without storing raw complaint records in GitHub.

## 1. Row count and complaint ID uniqueness

- Total rows: 19,028,339
- Distinct complaint IDs: 19,028,339
- Null or blank complaint IDs: 0

Interpretation:

The complaint ID is unique across the current source extract, which strongly supports the candidate grain:

**One row represents one published consumer complaint.**

## 2. Date coverage

- Earliest `date_received`: 2011-12-01
- Latest `date_received`: 2026-11-09
- Unparseable `date_received` values: 0

Interpretation:

The dataset provides long historical coverage from 2011 through 2026. The 2026 data is year-to-date and should not be treated as a complete year in later comparisons.

## 3. Missing-value profile

| Field | Missing or blank rows |
| --- | ---: |
| product | 0 |
| sub_product | 235,275 |
| issue | 6 |
| sub_issue | 948,354 |
| company | 0 |
| state | 63,721 |
| zip_code | 3,564 |
| submitted_via | 0 |
| company_response_to_consumer | 21 |
| timely_response | 0 |

Interpretation:

Missing sub-product and sub-issue values may be structurally valid and should not automatically be treated as bad records. Missing state values affect geographic analysis and will require an explicit handling rule.

## 4. Date relationship quality

- Records where `date_sent_to_company` is earlier than `date_received`: 7,050

Interpretation:

These rows should be investigated before calculating a derived days-to-send measure. They should not be silently removed without a documented Curated-layer rule.

## 5. Submission channels

| Submitted via | Complaint count |
| --- | ---: |
| Web | 18,388,005 |
| Referral | 280,765 |
| Phone | 222,307 |
| Postal mail | 111,195 |
| Fax | 25,644 |
| Email | 423 |

Interpretation:

The source contains six clear submission-channel categories, with Web representing the majority of complaints.

## 6. Issue classification breadth

- Distinct issue values: 179
- Distinct sub-issue values: 272

Interpretation:

The source provides detailed complaint classification suitable for issue-level analysis, but historical taxonomy changes must be considered.

## 7. Product values

The source contains 21 observed product labels.

The largest product categories include:

| Product | Complaint count |
| --- | ---: |
| Credit reporting or other personal consumer reports | 13,370,820 |
| Credit reporting, credit repair services, or other personal consumer reports | 2,163,769 |
| Debt collection | 1,232,896 |
| Mortgage | 466,176 |
| Checking or savings account | 410,635 |
| Credit card | 359,428 |
| Credit card or prepaid card | 206,356 |
| Money transfer, virtual currency, or money service | 197,622 |
| Credit reporting | 140,426 |
| Student loan | 136,196 |

Interpretation:

Different product labels across the historical period are consistent with documented CFPB taxonomy changes. Original source values should be preserved rather than overwritten.

## 8. Timely response

| Timely response | Complaint count |
| --- | ---: |
| Yes | 18,914,730 |
| No | 113,609 |

Interpretation:

The `timely_response` field is complete in the current extract and can support response-timeliness analysis.

## 9. Company response to consumer

| Company response | Complaint count |
| --- | ---: |
| Closed with explanation | 11,748,826 |
| Closed with non-monetary relief | 6,343,765 |
| In progress | 633,908 |
| Closed with monetary relief | 224,935 |
| Untimely response | 36,102 |
| Closed without relief | 17,867 |
| Closed | 17,611 |
| Closed with relief | 5,304 |
| Missing | 21 |

Interpretation:

`company_response_to_consumer` describes response outcome categories and is separate from the `timely_response` Yes/No field.

## 10. Complaint volume by year

| Year | Complaint count |
| --- | ---: |
| 2011 | 2,536 |
| 2012 | 72,368 |
| 2013 | 108,214 |
| 2014 | 152,908 |
| 2015 | 168,272 |
| 2016 | 191,292 |
| 2017 | 242,745 |
| 2018 | 257,130 |
| 2019 | 277,239 |
| 2020 | 444,212 |
| 2021 | 495,940 |
| 2022 | 800,245 |
| 2023 | 1,292,048 |
| 2024 | 2,734,268 |
| 2025 | 5,442,931 |
| 2026 | 6,345,991 |

Interpretation:

Complaint volume increases substantially in recent years. These counts should be treated as observed complaint volume, not automatically interpreted as increased consumer harm. The 2026 value is incomplete year-to-date.

## 11. Feasibility conclusion

The current CFPB extract is feasible for continued warehouse design because it has:

- a clear candidate transaction grain,
- a unique complaint identifier,
- long date coverage,
- useful product, issue, company, response, and channel fields,
- sufficient volume for analytical modeling,
- and identifiable data-quality and history issues that can be handled explicitly in later project phases.

The most important P1 design issue is preserving historical product and issue meaning while supporting useful trend analysis across CFPB taxonomy changes.
