# Consumer Financial Complaint Operations & Risk Intelligence Warehouse

## Project Overview

This repository contains my individual SEIS 732 Data Warehousing project at the University of St. Thomas.

The project uses the Consumer Financial Protection Bureau (CFPB) Consumer Complaint Database to design and build an analytical data warehouse for complaint monitoring, compliance, and customer-operations decision support.

The project focuses on building a reproducible analytical pipeline in Google BigQuery, including source ingestion, raw and curated data, dimensional modeling, data-quality checks, historical meaning, serving outputs, and a final analytical product.

## Current Project Stage

P0 — Need, Audience, Dataset & Feasibility

The current work evaluates whether the CFPB complaint data can support the proposed audience and analytical questions.

## Source

**Provider:** Consumer Financial Protection Bureau (CFPB)

**Dataset:** Consumer Complaint Database

**Official source page:**  
[CFPB Consumer Complaint Database](https://www.consumerfinance.gov/data-research/consumer-complaints/)

**Direct CSV download:**  
[Download all complaint data (CSV ZIP)](https://files.consumerfinance.gov/ccdb/complaints.csv.zip)

**Field reference:**  
[CFPB Consumer Complaint Database field reference](https://cfpb.github.io/api/ccdb/fields.html)

The current source is the official CFPB complaint CSV download. The source file is stored privately in Google Cloud Storage and loaded into BigQuery for analysis.

Source data files are not stored in this GitHub repository.

## BigQuery Environment

- Google Cloud project: `seis-732-olivia`
- Raw dataset: `cfpb_raw`
- Raw table: `complaints_raw`
- Processing location: `US`

## P0 Files

- [P0 Feasibility Report](docs/p0-feasibility.md)
- [Feasibility SQL](sql/00_feasibility.sql)
- [P0 Evidence Summary](evidence/p0-feasibility-results.md)

## Important Note

This repository contains code, documentation, models, and summarized analytical evidence only. Raw CFPB source data and downloaded data extracts are intentionally excluded.
