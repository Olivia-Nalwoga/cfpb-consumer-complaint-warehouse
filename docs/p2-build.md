## 3. Run and interpret two acceptance checks

The executable acceptance checks are stored in
[`sql/04_acceptance.sql`](../sql/04_acceptance.sql).

| Risk and affected result | Check code | Expected result and why | Observed result | Interpretation or action |
|---|---|---|---|---|
| Curation could duplicate complaints, remove records, or break the one-row-per-complaint grain. This would inflate or reduce complaint counts in later reporting. | `sql/04_acceptance.sql` — Check 1 | Raw and Curated row counts should match, missing complaint IDs should equal 0, and repeated complaint-ID groups should equal 0. | Raw rows = 19,028,339; Curated rows = 19,028,339; missing complaint IDs = 0; repeated complaint-ID groups = 0. | The Curated build preserved all complaint rows and maintained the intended one-row-per-`complaint_id` grain. No corrective action was required. |
| Incorrect response-flag logic could misstate the planned late-response rate. | `sql/04_acceptance.sql` — Check 2 | The number of Raw records with `timely_response = 'No'` should equal the sum of `late_response_flag`. The Raw count of `Yes` or `No` responses should equal the sum of `eligible_response_flag`. | Raw late count = 113,609; Curated late count = 113,609; Raw eligible count = 19,028,339; Curated eligible count = 19,028,339. Both reconciliation checks returned TRUE. | The Curated response flags exactly reconcile to the Raw source values, so the transformation preserves the meaning needed for the planned late-response-rate measure. |

### Field / measure trace

The source field `timely_response` is preserved from the CFPB extract in
`cfpb_raw.complaints_raw`.

In Curated, it is trimmed and used to create:

- `late_response_flag = 1` when `timely_response = 'No'`
- `eligible_response_flag = 1` when `timely_response` is either `Yes` or `No`

The acceptance check observed 113,609 late-response records and
19,028,339 eligible-response records, and both counts reconciled exactly
between Raw and Curated.

In P3, these fields are planned to support:

`late-response rate = SUM(late_response_flag) / SUM(eligible_response_flag)`

grouped by completed received month and comparable reporting product group.

## 4. Make the run reproducible and record the next step

The P2 build uses the following execution order:

1. Verify the existing CFPB Raw input using [`sql/02_ingest.sql`](../sql/02_ingest.sql).
   The Raw input is stored in `seis-732-olivia.cfpb_raw.complaints_raw`.

2. Run [`sql/03_curate.sql`](../sql/03_curate.sql).
   This recreates `seis-732-olivia.cfpb_curated.complaints_curated`
   from the current Raw input.

3. Review the Curated verification results:
   - Curated rows = 19,028,339
   - Distinct complaint IDs = 19,028,339
   - Missing complaint IDs = 0
   - Reversed date pairs = 7,050

4. Run [`sql/04_acceptance.sql`](../sql/04_acceptance.sql).

5. Compare the observed acceptance-check results with the expected results
   documented in this build note.

The Raw table must already exist before the Curated build runs. The Curated script
uses `CREATE OR REPLACE TABLE`, so rerunning it replaces the Curated table using the
current Raw input. The acceptance checks do not modify data; they only inspect and
reconcile Raw and Curated results.

### Main limitation

This P2 build validates the complaint-level Raw-to-Curated path, but it does not yet
create the dimensional model, the comparable reporting product-group mapping, or the
final Serving output.

The original CFPB product and sub-product values are preserved in Curated because the
source classification structure changes over time. Cross-period reporting harmonization
will be implemented later rather than overwriting the original classifications.

### Next P3 step

The next P3 step is to build the warehouse dimensions and `fact_complaint`, implement
the reporting product-group mapping, and create the Serving output for monthly complaint
volume and late-response rate. P3 will also test same-input reruns, changed input, and
the reporting effect of historical classification changes.

### AI/tool assistance

AI assistance was used to help organize the SQL and documentation. All SQL was run in
BigQuery, and the row counts and reconciliation results reported here were checked
against the actual project tables.
