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

In Curated, it is standardized and used to create:

- `late_response_flag = 1` when `timely_response = 'No'`
- `eligible_response_flag = 1` when `timely_response` is either `Yes` or `No`

The acceptance check observed 113,609 late-response records and
19,028,339 eligible-response records, and both counts reconciled exactly
between Raw and Curated.

In P3, these fields are planned to support:

`late-response rate = SUM(late_response_flag) / SUM(eligible_response_flag)`

grouped by completed received month and comparable reporting product group.
