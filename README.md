# Digital Banking Fraud Risk Analysis

**Project type:** Power BI + SQL portfolio case study  
**Focus:** Digital transaction monitoring, fraud signals, account risk scoring, and investigation prioritization

## Overview

This project analyzes simulated digital banking/mobile money transactions to identify fraud patterns and prioritize accounts for review.

The analysis uses SQL to transform transaction-level data into account-level monitoring outputs, then uses Power BI to present fraud patterns across transaction types, time steps, account behavior, and suspicious destination/originator activity.

## Dataset

The project uses the PaySim mobile money transaction dataset. PaySim is a synthetic financial dataset built to resemble the normal operation of mobile money transactions while injecting malicious behavior for fraud detection analysis.

> Important note: the source dataset is synthetic and intended for analysis/portfolio use. It should not be presented as confidential client data or actual bank customer data.

## Business problem

Digital payment systems produce high-volume transaction data. Fraud teams need more than raw transaction tables. They need a monitoring view that helps answer:

- Which transaction types are most associated with fraud signals?
- When do fraud events occur across the transaction timeline?
- Which accounts should be prioritized for investigation?
- Which destination accounts receive the largest fraudulent flows?
- Are suspicious accounts risky because of confirmed fraud signals, risky transaction structure, high activity, or financial exposure?

## Tools used

- **SQL / SQLite** for data preparation and account-level modelling
- **Power BI** for dashboard design and reporting
- **Power Query** for data loading and transformation
- **DAX** for report-level measures
- **GitHub** for documentation and project packaging

## Data model and analytical approach

The core modelling step treats every transaction as two account events:

1. **Outgoing event** for the sender account
2. **Incoming event** for the receiver account

This creates an account-level view of both sides of transaction behavior.

The SQL model then calculates:

- `txn_count`
- `total_amount`
- `fraud_signal_count`
- `risk_event_count`
- `incoming_count`
- `outgoing_count`
- `first_step`
- `last_step`
- `fraud_rate`
- `risk_rate`
- `activity_score`
- `activity_band`
- `suspicion_score`

## Suspicion score logic

The suspicion score is a heuristic scoring model:

```text
suspicion_score =
    (0.6 * fraud_rate) +
    (0.3 * risk_rate) +
    (0.1 * activity_score)
```

The weighting is based on business logic:

- **Fraud rate** receives the highest weight because confirmed fraud signals are the strongest evidence.
- **Risk rate** receives medium weight because some transaction types are structurally more exposed to fraud.
- **Activity score** receives a smaller weight because highly active accounts may require more monitoring, but activity alone does not prove fraud.

This is not a machine learning model. It is a transparent, explainable scoring framework designed for portfolio and dashboard analysis.

## Dashboard pages

### 1. Fraud Monitoring Overview

Purpose: provide a high-level view of transaction volume, fraud rate, risk rate, and fraud trends.

Visuals include:

- Total accounts
- Total transaction volume
- Average fraud rate
- Average risk rate
- Fraud signals by transaction type
- Fraud rate over time

### 2. Fraud Risk Analysis

Purpose: prioritize accounts for investigation.

Visuals include:

- Fraud rate vs transaction activity
- Suspicious account watchlist
- Account-level fraud and risk metrics
- Business explanation of fraud risk drivers

### 3. Account Drill Tooltip

Purpose: support deeper account-level investigation from the main analysis page.

## Key findings

1. Fraud signals are concentrated in **TRANSFER** and **CASH_OUT** transactions.
2. **TRANSFER** has the highest fraud rate among transaction types.
3. Routine transaction types such as **PAYMENT**, **DEBIT**, and **CASH_IN** show no fraud signals in the exported transaction-type summary.
4. Fraud originators generally send fraudulent funds to one receiver, suggesting account takeover and immediate extraction behavior rather than broad laundering networks.
5. A small number of destination accounts receive fraudulent funds from more than one sender, which may indicate mule-account style behavior.
6. Suspicion scoring helps rank accounts by combining confirmed fraud signals, risky transaction exposure, and activity level.

## Exported summary statistics

| Metric | Value |
|---|---:|
| Transaction rows analyzed | 6,362,620 |
| Account-monitoring rows exported | 146,679 |
| Total transaction amount | 1,144,392,944,759.77 |
| Fraud signal count | 8,213 |
| Overall fraud signal rate | 0.1291% |
| Highest fraud-rate transaction type | TRANSFER |
| Highest fraud-count transaction type | CASH_OUT |
| Top fraud destination account | C668046170 |
| Top fraud originator account | C99979309 |
| Timeline step with highest fraud signal count | 212 |

## Project files

```text
Fintech_Transaction_Fraud_Analytics/
├── README.md
├── sql/
│   ├── 00_all_saved_queries_from_sqbpro.sql
│   ├── 01_account_monitoring_model.sql
│   ├── 02_fraud_by_transaction_type.sql
│   ├── 03_fraud_timeline.sql
│   ├── 04_fraud_destinations.sql
│   └── 05_fraud_originators.sql
├── data_exports/
│   ├── account_monitoring_export.csv
│   ├── fraud_transaction_type.csv
│   ├── fraud_timeline.csv
│   ├── fraud_destinations.csv
│   └── fraud_originators.csv
├── screenshots/
│   └── add_dashboard_screenshots_here.md
├── docs/
│   ├── data_dictionary.md
│   └── deployment_checklist.md
└── linkedin/
    └── linkedin_launch_post.md
```

## Important limitation

The `.pbix` file for this project is currently larger than 100 MB, so it should not be uploaded directly to GitHub through normal GitHub storage. Use a live Power BI public link, a compressed sample version, or Git Large File Storage if you decide to store the Power BI file itself.

## How to present this project

Recommended title for LinkedIn/GitHub:

**Digital Banking Fraud Risk Analysis Dashboard**

Recommended portfolio framing:

> I built a Power BI fraud monitoring dashboard using SQL-generated account-level metrics from synthetic mobile money transaction data. The project focuses on fraud pattern detection, transaction-type risk, account-level monitoring, and an explainable suspicion scoring framework.

## Live report

Add the Power BI public report link here once published:

`[Power BI Live Report - add link here]`
