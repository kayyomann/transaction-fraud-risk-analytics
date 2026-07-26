/*
PROJECT: Digital Banking Fraud Risk Analysis

CREATED BY: Eniola Alabi

OBJECTIVE:
Identify and prioritize potentially fraudulent accounts by analyzing behavioral
patterns in digital banking transactions.

APPROACH:
1. Transform raw transactions into account-level events by treating each transaction
   as both an outgoing event (sender) and incoming event (receiver).

2. Aggregate account activity to create behavioral metrics including:
   - transaction count
   - total transaction volume
   - fraud signal count
   - risk exposure based on transaction type

3. Engineer behavioral indicators:
   - fraud_rate = fraud_signal_count / txn_count
   - risk_rate = risk_event_count / txn_count
   - activity_score = normalized transaction activity

4. Combine behavioral signals into a composite suspicion score using a weighted model:
   suspicion_score =
       (0.6 * fraud_rate) +
       (0.3 * risk_rate) +
       (0.1 * activity_score)

5. Rank accounts by suspicion score to generate a prioritized watchlist for
   potential fraud investigation.

ANALYTICAL QUESTION:
Which accounts demonstrate the most suspicious behavior when considering fraud
signals, risky transaction patterns, and transaction activity levels?

DATASET:
Simulated digital banking transaction dataset containing transfer, payment,
cash-in, and cash-out events.

OUTPUT:
A ranked list of accounts with the highest suspicion scores, highlighting
accounts that may warrant further fraud investigation.
*/

WITH account_profile AS (
SELECT -- SENDERS
	nameOrig AS account_id,
	'outgoing' AS direction,
	amount,
	type,
	step,
	isFraud,
	isFlaggedFraud,
	(CASE WHEN isFraud = 1 OR isFlaggedFraud = 1 THEN 1 ELSE 0 END) AS fraud_signal,
	(CASE WHEN type IN ('DEBIT','PAYMENT','TRANSFER','CASH_OUT') THEN 1 ELSE 0 END) AS is_revenue_event,
	(CASE WHEN type IN ('TRANSFER','CASH_OUT','CASH_IN') THEN 1 ELSE 0 END) AS is_risk_event
	
FROM
	transaction_raw

UNION ALL

SELECT -- receiver
	nameDest AS account_id,
	'incoming' AS direction,
	amount,
	type,
	step,
	isFraud,
	isFlaggedFraud,
	(CASE WHEN isFraud = 1 OR isFlaggedFraud = 1 THEN 1 ELSE 0 END) AS fraud_signal,
	0 AS is_revenue_event,
	(CASE WHEN type IN ('TRANSFER','CASH_OUT','CASH_IN') THEN 1 ELSE 0 END) AS is_risk_event	
FROM
	transaction_raw

),

account_summary AS(
SELECT 	
	account_id,
	COUNT(*)AS txn_count, 
	SUM(amount) AS total_amount,
	SUM(fraud_signal) AS fraud_signal_count,
	SUM(is_risk_event) AS risk_event_count,
	SUM(CASE WHEN direction = 'incoming' THEN 1 ELSE 0 END) AS incoming_count,
	SUM(CASE WHEN direction = 'outgoing' THEN 1 ELSE 0 END) AS outgoing_count,
	MIN(step) AS first_step,
	MAX(step) AS last_step
FROM
	account_profile

GROUP BY account_id

),
score_parms AS (
SELECT
	max(txn_count) AS max_txn_count
FROM
	account_summary 
),

account_metric AS (
SELECT
	account_id,
	CAST(fraud_signal_count AS REAL)/txn_count AS fraud_rate,
	CAST(risk_event_count AS REAL)/txn_count AS risk_rate,	
	fraud_signal_count,
	risk_event_count,
	incoming_count,
	outgoing_count,
	first_step,
	last_step,
	log(txn_count)/ log(max_txn_count) AS activity_score,
	txn_count,
	total_amount
FROM
	account_summary
	CROSS JOIN score_parms
)

SELECT	
	account_id, 
	txn_count,
	total_amount,
	fraud_signal_count,
	risk_event_count,
	incoming_count,
	outgoing_count,
	first_step,
	last_step,
	fraud_rate,
	risk_rate,
	activity_score,
	CASE
	WHEN txn_count BETWEEN 10 AND 25 THEN 'Low Activity'
	WHEN txn_count BETWEEN 26 AND 60 THEN 'Medium Activity'
	ELSE 'High Activity'
	END AS activity_band,
	(0.6 * fraud_rate) + (0.3 * risk_rate) + (0.1 * activity_score) AS suspicion_score
FROM
	account_metric	
	
WHERE
	txn_count >= 10

ORDER BY suspicion_score DESC
