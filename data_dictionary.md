# Data Dictionary

## account_monitoring_export.csv

| Column | Meaning |
|---|---|
| account_id | Account identifier generated from sender and receiver account IDs |
| txn_count | Number of account-level events after combining incoming and outgoing activity |
| total_amount | Total transaction amount associated with the account |
| fraud_signal_count | Number of transactions where `isFraud = 1` or `isFlaggedFraud = 1` |
| risk_event_count | Count of structurally risky transaction types: TRANSFER, CASH_OUT, CASH_IN |
| incoming_count | Count of incoming transaction events |
| outgoing_count | Count of outgoing transaction events |
| first_step | First observed transaction step for the account |
| last_step | Last observed transaction step for the account |
| fraud_rate | fraud_signal_count / txn_count |
| risk_rate | risk_event_count / txn_count |
| activity_score | Log-normalized activity score based on transaction count |
| activity_band | Activity classification: Low, Medium, or High Activity |
| suspicion_score | Weighted score combining fraud_rate, risk_rate, and activity_score |

## fraud_transaction_type.csv

| Column | Meaning |
|---|---|
| type | Transaction type |
| txn_count | Number of transactions for the type |
| total_amount | Total transaction value for the type |
| fraud_signal_count | Number of fraud or flagged-fraud transactions |
| fraud_rate | fraud_signal_count / txn_count |

## fraud_timeline.csv

| Column | Meaning |
|---|---|
| step | Time step in the PaySim dataset |
| txn_count | Number of transactions in that step |
| total_amount | Total transaction value in that step |
| fraud_signal_count | Number of fraud or flagged-fraud transactions in that step |
| fraud_rate | fraud_signal_count / txn_count |

## fraud_destinations.csv

| Column | Meaning |
|---|---|
| nameDest | Destination account receiving fraudulent funds |
| fraud_txn_count | Number of fraudulent transactions received |
| fraud_amount | Total fraudulent amount received |
| unique_senders | Number of distinct fraud-originating senders |

## fraud_originators.csv

| Column | Meaning |
|---|---|
| nameOrig | Account originating fraudulent transactions |
| fraud_txn_count | Number of fraudulent transactions sent |
| fraud_amount | Total fraudulent amount sent |
| unique_receivers | Number of distinct receiving accounts |
