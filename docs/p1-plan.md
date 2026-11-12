# P1 — Grain, Model, History & Pipeline Plan

## 1. Establish the question and check the source

### Audience and need

The primary audience is a compliance or customer-operations manager at a financial-services organization.

The manager needs a reliable way to monitor published consumer complaint patterns, identify product areas where complaint activity is changing, and decide where additional investigation may be needed.

### Primary analytical question

**Which comparable product groups show changes in monthly complaint volume over time, and where do those patterns suggest a need for further investigation?**

Supporting question:

**How does the late-response rate vary across those product groups over completed months?**

The same complaint-level fact table can support both questions.

### Material changes from P0

The audience, source, and proposed complaint grain remain the same as in P0.

After reviewing the P0 work, I made several improvements:

- Corrected the feasibility SQL filename and repository link.
- Expanded the date-quality profile to test both source date fields independently.
- Confirmed that both date fields are complete and parse successfully in the selected extract.
- Confirmed 7,050 reversed received/sent date pairs and defined them as exclusions from the future routing-days measure rather than exclusions from the complaint fact.
- Profiled product and sub-product combinations by month to investigate historical CFPB taxonomy changes.

The monthly profile showed an important boundary case around the April 24, 2017 CFPB form change. During April 2017, both legacy classifications such as `Consumer Loan` + `Vehicle loan` and newer classifications such as `Vehicle loan or lease` + `Loan` appear in the source.

This evidence means that a complaint should not be reclassified based only on its date. Original CFPB classifications will be preserved, and a separate reporting mapping will be used when comparable historical groups are required.

### Source object

The primary BigQuery source object is:

`seis-732-olivia.cfpb_raw.complaints_raw`

The selected extract contains 19,028,339 published complaint records with `date_received` values from 2011-12-01 through 2026-11-09.

### Source row meaning

One source row represents one published consumer complaint.

### Candidate identifier

The source field expected to uniquely identify one complaint is:

`complaint_id`

### Proposed fact grain

**One row represents one published consumer complaint in the selected CFPB extract.**

### Observed grain-check result

The grain check returned:

- Source rows: 19,028,339
- Rows with missing complaint ID: 0
- Repeated complaint ID groups: 0

### Grain conclusion

The observed results support the proposed transaction grain.

`complaint_id` is nonblank and unique across the selected extract, so each published complaint can be represented by one fact row. The identifier test establishes technical uniqueness, while the business process and analytical questions establish why one complaint is an appropriate analytical row.

The reproducible grain check is stored in:

[`sql/01_source_profile.sql`](../sql/01_source_profile.sql)

