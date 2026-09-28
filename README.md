# Transaction Fraud Risk Analysis (Mobile Money)

**SQL + Power BI analysis of 6.36M synthetic mobile-money transactions to find where fraud concentrates and build a review-prioritization view for fraud teams.**

[View the interactive Power BI dashboard](https://app.powerbi.com/view?r=eyJrIjoiNWY3M2Q0YzItMjFiZC00MTFhLTg3ZmItNTdjMDI4YjkwYmRjIiwidCI6IjA3ZjFiOTE0LTE1YjMtNDUzOC1hMmNjLWM5ODcyY2U4Y2YxMCJ9&pageName=a991c259c9200626fd4e)

---

## Summary

**Problem.** Fraud teams need to know where fraud is concentrated and which accounts deserve investigation first, without reviewing the entire transaction population.

**What I did.** Analyzed 6.36M synthetic mobile-money transactions (PaySim) in SQL, built account-level risk metrics, and created a Power BI dashboard that ranks accounts using known fraud patterns.

**What I found.** All 8,213 fraudulent transactions occurred in two transaction types, TRANSFER and CASH_OUT, which together make up about 43.5% of transactions. Fraud was 0.13% of transactions but roughly 1% of transaction value (about 12.1B simulated units), meaning the average fraudulent transaction was roughly 8x larger than the average transaction.

**So what.** In this dataset, limiting first-line review to TRANSFER and CASH_OUT would have covered 100% of fraud while removing about 56.5% of transactions from the review queue. Because PaySim only simulates fraud through these two types, this is a rule to test on real data, not a proven result. The next step is a score built only on signals available before fraud is confirmed, so it can support live triage.

---

## Dataset

This project uses the **PaySim** mobile-money dataset, a synthetic dataset built to resemble normal mobile-money activity with injected fraudulent behavior. Each `step` represents one hour of simulated time.

The data is synthetic. It is not client data or real bank customer data, and amounts are simulated units rather than a real currency.

## Business questions

- Which transaction types are most associated with fraud?
- When do fraud events occur across the transaction timeline?
- Which accounts should be prioritized for investigation?
- Which destination accounts receive the largest fraudulent flows?
- Is an account risky because of confirmed fraud, risky transaction structure, high activity, or financial exposure?

## Approach

**Tools:** SQL (SQLite) for data preparation and account-level modelling · Power Query for loading · DAX for report measures · Power BI for the dashboard.

**Account-level model.** Every transaction is treated as two account events: an outgoing event for the sender and an incoming event for the receiver. This gives a view of both sides of each account's behavior.

Events are grouped by account, and the monitoring output keeps only accounts with **10 or more transaction events** (146,679 accounts). The threshold removes accounts with too little activity to rank meaningfully.

For each account, the SQL model calculates: `txn_count`, `total_amount`, `fraud_signal_count`, `risk_event_count`, `incoming_count`, `outgoing_count`, `first_step`, `last_step`, `fraud_rate`, `risk_rate`, `activity_score`, `activity_band`, and `suspicion_score`.

**Suspicion score.** A transparent, heuristic ranking, not a machine learning model:

```
suspicion_score = (0.6 * fraud_rate) + (0.3 * risk_rate) + (0.1 * activity_score)
```
> Because `fraud_rate` uses confirmed fraud labels, this score ranks accounts by known fraud exposure. It is a review and pattern-analysis tool, not a detector of undiscovered fraud.
>
- **Fraud rate (60%)**: confirmed fraud signals are the strongest evidence.
- **Risk rate (30%)**: some transaction types are structurally more exposed to fraud.
- **Activity score (10%)**: highly active accounts may warrant more monitoring, but activity alone does not indicate fraud.

## Dashboard

1. **Fraud Monitoring Overview**: total accounts, transaction volume, average fraud and risk rates, fraud by transaction type, fraud over time.
2. **Fraud Risk Analysis**: fraud rate vs. activity, suspicious account watchlist, account-level metrics, explanation of risk drivers.
3. **Account Drill Tooltip**: account-level detail from the analysis page.

## Key findings

- **Fraud is concentrated in two transaction types.** All fraud occurred in TRANSFER and CASH_OUT (~43.5% of transactions). TRANSFER has the highest fraud rate; CASH_OUT has the highest fraud count. PAYMENT, DEBIT, and CASH_IN show no fraud. *Note: PaySim simulates fraud as a transfer-then-cash-out pattern, so this concentration partly reflects how the data was generated.*
- **Fraud skews toward high-value transactions.** Fraud is ~0.13% of transactions but ~1% of value; the average fraudulent transaction is ~8x the overall average.
- **Fraud looks like takeover-and-extract, not broad laundering.** Fraudulent senders generally send to a single receiver, consistent with account takeover followed by immediate extraction.
- **A few receivers look like mule accounts.** A small number of destination accounts receive fraudulent funds from more than one sender.
- **Fraud peaks at a specific point in time.** The highest fraud count occurred at step 212 (hour 212 of the simulation).

## Summary statistics

| Metric | Value |
|---|---|
| Transactions analyzed | 6,362,620 |
| Account-monitoring rows exported | 146,679 |
| Total transaction value | ~1.14T simulated units |
| Fraudulent transactions | 8,213 |
| Fraud rate (by count) | 0.13% |
| Fraudulent transaction value | ~12.1B simulated units (~1% of total) |
| Share of transactions in TRANSFER + CASH_OUT | ~43.5% |
| Highest fraud-rate type | TRANSFER |
| Highest fraud-count type | CASH_OUT |

## Recommendations

These are hypotheses to test on real data, not production rules.

1. **Test type-based review queues.** Check whether concentrating first-line review on higher-risk transaction types captures most fraud without leaving blind spots in the others.
2. **Test amount thresholds within high-risk types.** Because fraud skews toward high values, evaluate amount-based triggers for TRANSFER and CASH_OUT.
3. **Monitor receiving accounts.** Flag destination accounts that receive funds from multiple flagged senders as potential mule accounts.
4. **Rank on pre-confirmation signals.** Rebuild the score using only signals available before fraud is confirmed, so it can support live triage.

## Limitations

- **Synthetic data.** Patterns in PaySim may not reflect any real institution's fraud mix.
- **The suspicion score uses confirmed fraud labels.** It is a prioritization and review view of known outcomes, not a predictive model.
- **The 10-event threshold shapes the watchlist.** In PaySim most sending accounts appear only once, so the ranked accounts are mostly receiving accounts. Low-activity accounts, including many fraudulent senders, are outside the score.
- **No cost or false-positive analysis.** The project does not estimate investigation cost, review capacity, or false-positive rates.
- **Rounded figures.** The fraudulent value and ~8x ratio are derived from exported summary totals rather than recomputed from the raw data.
