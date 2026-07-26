-- ============================================================
-- 01. Customer Dimension
-- ============================================================

1/*
CREATED BY: ENIOLA ALABI
GOAL: [TO BE DETERMINED]
*/

SELECT
	count (*) AS total_customers,
	SUM(CASE WHEN y = 'yes' THEN 1 ELSE 0 END) AS postive_outcome,
	SUM(CASE WHEN y = 'no' THEN 1  ELSE 0 END) AS negative_outcome

FROM	
	customer_raw


-- ============================================================
-- 02. Transaction Fact
-- ============================================================

/*
CREATED BY: ENIOLA ALABI
GOAL: [TO BE DETERMINED]
*/

SELECT
	type,
	COUNT(*) AS txn_count,
	SUM(amount) AS total_amount
	
FROM	
	transaction_raw
	
GROUP BY
	type
	
ORDER BY txn_count DESC


-- ============================================================
-- 03. Economic opportunity classification (Transaction)
-- ============================================================

/*
CREATED BY: ENIOLA ALABI
GOAL: 	Classifying the transaction types baased on their economic oppurtunities 
		using a preconceived structural guaranteed assumption
*/

SELECT
	type,
	amount,


CASE 
	WHEN type IN ('DEBIT','PAYMENT') THEN 'card_spend'
	WHEN type = 'TRANSFER' THEN 'transfer'
	WHEN type IN ('CASH_IN','CASH_OUT') THEN 'cash_movement'
	ELSE 'unknown'
END AS primary_category,

CASE 
	WHEN type IN ('DEBIT','PAYMENT','TRANSFER','CASH_OUT') THEN 1
	ELSE 0
END AS is_revenue_event,

CASE 
	WHEN type IN ('TRANSFER','CASH_OUT','CASH_IN') THEN 1
	ELSE 0
END AS is_risk_event

FROM	
	transaction_raw
	
LIMIT 20


-- ============================================================
-- 04. Economic opportunity classification (Transaction) [2]
-- ============================================================

/*
CREATED BY: ENIOLA ALABI
GOAL: 	Classifying the transaction types baased on their economic oppurtunities 
		using a preconceived structural guaranteed assumption
*/
SELECT
	type, 
	primary_category,
	is_revenue_event,
	is_risk_event,
	amount,
	COUNT (*) AS n,
	SUM (amount) AS total_amount
FROM (
	SELECT
		type,
		amount,
	CASE 
		WHEN type IN ('DEBIT','PAYMENT') THEN 'card_spend'
		WHEN type = 'TRANSFER' THEN 'transfer'
		WHEN type IN ('CASH_IN','CASH_OUT') THEN 'cash_movement'
		ELSE 'unknown'
	END AS primary_category,

	CASE 
		WHEN type IN ('DEBIT','PAYMENT','TRANSFER','CASH_OUT') THEN 1
		ELSE 0
	END AS is_revenue_event,

	CASE 
		WHEN type IN ('TRANSFER','CASH_OUT','CASH_IN') THEN 1
		ELSE 0
		END AS is_risk_event

FROM	
	transaction_raw
)

GROUP BY type, primary_category, is_revenue_event, is_risk_event

ORDER BY total_amount DESC
	
LIMIT 20


-- ============================================================
-- 05. Economic opportunity classification (Transaction)_risk_event_count...
-- ============================================================

/*
CREATED BY: ENIOLA ALABI
GOAL: 	Classifying the transaction types baased on their economic oppurtunities 
		using a preconceived structural guaranteed assumption
*/
SELECT
	COUNT(*) AS txn_count, 
	SUM(CASE WHEN isFraud = 1 OR isFlaggedFraud = 1 THEN 1 ELSE 0 END) AS fraud_txn_count,
	SUM(amount) AS total_amount,
	SUM(is_revenue_event) AS revenue_event_count,
	SUM(is_risk_event) AS risk_event_count,
	MIN(step) AS first_step,	
	MAX(step) AS last_step,
	nameOrig AS account_id
FROM(
		--level 2 -- Ps you dont really need this level 2, it is redundant basically 
		SELECT 
			type,
			amount,
			nameOrig,
			step,
			isFraud,
			isFlaggedFraud,
			CASE
				WHEN type IN ('DEBIT','PAYMENT','TRANSFER','CASH_OUT') THEN 1
				
			END AS is_revenue_event,
			CASE 
				WHEN type IN ('TRANSFER','CASH_OUT','CASH_IN') THEN 1
				ELSE 0
			END AS is_risk_event
		FROM
			transaction_raw	
		)
GROUP BY nameOrig

LIMIT 10;


-- ============================================================
-- 06. Refined. Highest Fraud count
-- ============================================================

/*
CREATED BY: ENIOLA ALABI
GOAL: 	Classifying the transaction types baased on their economic oppurtunities 
		using a preconceived structural guaranteed assumption
*/

WITH account_profile AS (

SELECT -- engine
	nameOrig AS account_id,
	COUNT(*) AS txn_count, 
	SUM(CASE WHEN isFraud = 1 OR isFlaggedFraud = 1 THEN 1 ELSE 0 END) AS fraud_txn_count,
	SUM(amount) AS total_amount,
    SUM(CASE WHEN type IN ('DEBIT','PAYMENT','TRANSFER','CASH_OUT') THEN 1 ELSE 0 END) AS revenue_event_count,
    SUM(CASE WHEN type IN ('TRANSFER','CASH_OUT','CASH_IN') THEN 1 ELSE 0 END) AS risk_event_count,
	MIN(step) AS first_step,	
	MAX(step) AS last_step
	
FROM
	transaction_raw	
GROUP BY 
	nameOrig
)

SELECT 	
	account_id,
	txn_count,
	fraud_txn_count,
	risk_event_count,
	revenue_event_count,
	CAST(risk_event_count AS REAL)/txn_count AS risk_rate,
	CAST(fraud_txn_count AS REAL)/txn_count AS fraud_rate,	
	total_amount
FROM
	account_profile
	
ORDER BY fraud_txn_count DESC	
LIMIT 20


-- ============================================================
-- 07. Refined. Risk event count 
-- ============================================================

/*
CREATED BY: ENIOLA ALABI
GOAL: 	Classifying the transaction types baased on their economic oppurtunities 
		using a preconceived structural guaranteed assumption
*/

WITH account_profile AS (

SELECT -- engine
	nameOrig AS account_id,
	COUNT(*) AS txn_count, 
	SUM(CASE WHEN isFraud = 1 OR isFlaggedFraud = 1 THEN 1 ELSE 0 END) AS fraud_txn_count,
	SUM(amount) AS total_amount,
    SUM(CASE WHEN type IN ('DEBIT','PAYMENT','TRANSFER','CASH_OUT') THEN 1 ELSE 0 END) AS revenue_event_count,
    SUM(CASE WHEN type IN ('TRANSFER','CASH_OUT','CASH_IN') THEN 1 ELSE 0 END) AS risk_event_count,
	MIN(step) AS first_step,	
	MAX(step) AS last_step
	
FROM
	transaction_raw	
GROUP BY 
	nameOrig
)

SELECT 	
	account_id,
	txn_count,
	fraud_txn_count,
	risk_event_count,
	revenue_event_count,
	CAST(risk_event_count AS REAL)/txn_count AS risk_rate,
	CAST(fraud_txn_count AS REAL)/txn_count AS fraud_rate,	
	total_amount
FROM
	account_profile
	
ORDER BY txn_count DESC	
LIMIT 20


-- ============================================================
-- 08. Refined. Total amount
-- ============================================================

/*
CREATED BY: ENIOLA ALABI
GOAL: 	Classifying the transaction types baased on their economic oppurtunities 
		using a preconceived structural guaranteed assumption
*/

WITH account_profile AS (

SELECT -- engine
	nameOrig AS account_id,
	COUNT(*) AS txn_count, 
	SUM(CASE WHEN isFraud = 1 OR isFlaggedFraud = 1 THEN 1 ELSE 0 END) AS fraud_txn_count,
	SUM(amount) AS total_amount,
    SUM(CASE WHEN type IN ('DEBIT','PAYMENT','TRANSFER','CASH_OUT') THEN 1 ELSE 0 END) AS revenue_event_count,
    SUM(CASE WHEN type IN ('TRANSFER','CASH_OUT','CASH_IN') THEN 1 ELSE 0 END) AS risk_event_count,
	MIN(step) AS first_step,	
	MAX(step) AS last_step
	
FROM
	transaction_raw	
GROUP BY 
	nameOrig
)

SELECT 	
	account_id,
	txn_count,
	fraud_txn_count,
	risk_event_count,
	revenue_event_count,
	CAST(risk_event_count AS REAL)/txn_count AS risk_rate,
	CAST(fraud_txn_count AS REAL)/txn_count AS fraud_rate,	
	total_amount
FROM
	account_profile


	
ORDER BY total_amount DESC	
LIMIT 20


-- ============================================================
-- 09. Engine - Account profile revised (sender + receiver)
-- ============================================================

/*
CREATED BY: ENIOLA ALABI
GOAL: 	Classifying the transaction types baased on their economic oppurtunities 
		using a preconceived structural guaranteed assumption
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

)
SELECT	
	account_id,
	txn_count, 
	fraud_signal_count,
	risk_event_count,
	incoming_count,
	outgoing_count,
	CAST(risk_event_count AS REAL)/txn_count AS risk_rate,	
	CAST(fraud_signal_count AS REAL)/txn_count AS fraud_rate
		
FROM
	account_summary
	
WHERE	
	txn_count >= 10
ORDER BY fraud_rate DESC
LIMIT 20


-- ============================================================
-- 10. Quadrant_grain_is_account
-- ============================================================

/*
CREATED BY: ENIOLA ALABI
GOAL: 	Classifying the transaction types baased on their economic oppurtunities 
		using a preconceived structural guaranteed assumption
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

)
SELECT	
	CASE
	WHEN CAST(risk_event_count AS REAL)/txn_count >= 0.9 AND CAST(fraud_signal_count AS REAL)/txn_count> 0 THEN  'High Risk / High Fraud'
	WHEN CAST(risk_event_count AS REAL)/txn_count >= 0.9 AND CAST(fraud_signal_count AS REAL)/txn_count = 0 THEN  'High Risk / Low Fraud'	
	WHEN CAST(risk_event_count AS REAL)/txn_count < 0.9 AND CAST(fraud_signal_count AS REAL)/txn_count > 0 THEN  'Low Risk / High Fraud'
	ELSE 'Low Risk / Low Fraud'
	END AS quadrant,
	COUNT(*) AS number_of_accounts,
	SUM(total_amount) AS total_amount
		
FROM
	account_summary
	
WHERE	
	txn_count >= 10
	
GROUP BY quadrant

--INSIGHT
/*
In this modeled environment, accounts with meaningful activity are overwhelmingly risk-exposed, and fraud 
signals only appear inside already high-risk behavior bands. Changed the risk rate event threshold from 0.7 to 0.9
*/


-- ============================================================
-- 11. Table 1 Which accounts look suspicious (suspicion score)
-- ============================================================

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
	log(txn_count)/ log(max_txn_count) AS activity_score,
	txn_count,
	total_amount
FROM
	account_summary
	CROSS JOIN score_parms
)

SELECT	
	account_id, 
	fraud_rate,
	risk_rate,
	activity_score,
	txn_count,
	total_amount,
	(0.6 * fraud_rate) + (0.3 * risk_rate) + (0.1 * activity_score) AS suspicion_score
FROM
	account_metric	
	
WHERE
	txn_count > 10

ORDER BY suspicion_score DESC
LIMIT 20


-- ============================================================
-- 12. Table 3: Which transaction types drive fraud?
-- ============================================================

-- ANALYTICAL QUESTION:
-- Which transaction types account for the highest concentration of fraud
-- signals and financial exposure in the system?


SELECT
	type,
	COUNT(*) AS txn_count,
	SUM(amount) AS total_amount,
	SUM(CASE WHEN isFraud = 1 OR isFlaggedFraud = 1 THEN 1 ELSE 0 END) AS fraud_signal_count,
	CAST(SUM(CASE WHEN isFraud = 1 OR isFlaggedFraud = 1 THEN 1 ELSE 0 END) AS REAL)/(COUNT(*)) AS fraud_rate
	
FROM
	transaction_raw

GROUP BY type
ORDER BY fraud_rate DESC 

-- INSIGHT:
-- Fraud signals are concentrated entirely in TRANSFER and CASH_OUT transactions,
-- with TRANSFER showing the highest fraud rate. This suggests that fraud in the
-- system primarily occurs during fund movement and withdrawal stages rather than
-- during routine payment activity.


-- ============================================================
-- 13. Table 2 When does fraud occur over time?
-- ============================================================

-- ANALYTICAL QUESTION:
-- How does fraud activity evolve over time across transaction steps?

SELECT 
	step, 
	COUNT(*) AS txn_count, 
	SUM(amount) AS total_amount,	
	SUM(CASE WHEN isFraud = 1 OR isFlaggedFraud = 1 THEN 1 ELSE 0 END) AS fraud_signal_count,
	CAST(SUM(CASE WHEN isFraud = 1 OR isFlaggedFraud = 1 THEN 1 ELSE 0 END) AS REAL)/(COUNT(*)) AS fraud_rate
	
FROM 
	transaction_raw
	
GROUP BY step 
ORDER BY step 

--INSIGHTS
/*
--Fraud events cluster in the later stages of the transaction timeline
*/


-- ============================================================
-- 14. Table 4: Where does the money go when fraud happens?*
-- ============================================================

-- ANALYTICAL QUESTION:
-- Which destination accounts receive the largest volume of funds from fraudulent transactions?

SELECT 
	nameDest,
	COUNT(*) AS fraud_txn_count,
	SUM(amount) AS fraud_amount,
	COUNT(DISTINCT nameOrig) AS unique_senders

FROM
	transaction_raw

WHERE
	(isFraud = 1 OR isFlaggedFraud = 1)
GROUP BY nameDest
ORDER BY fraud_amount DESC

/*
-- INSIGHTS
-- most fraud events are isolated transfers, not large hub networks.
-- Account takeover followed by immediate transfer or cash-out.
-- Fraud flows in this dataset are mostly isolated sender-to-receiver transfers,
-- with most destination accounts receiving funds from only one compromised sender.
-- However, a small number of destination accounts receive funds from multiple senders,
-- which may indicate potential fraud collection or mule accounts.
*/


-- ============================================================
-- 15. Table 5: Fraud originators*
-- ============================================================

-- ANALYTICAL QUESTION:
-- Which accounts send the largest volume of fraudulent transactions?

SELECT
	nameOrig,
	COUNt(*) AS fraud_txn_count,
	SUM(amount) AS fraud_amount,
	COUNT(DISTINCT nameDest) AS unique_receivers

FROM 
	transaction_raw

WHERE
	(isFlaggedFraud = 1 or isFraud = 1)

GROUP BY nameOrig
ORDER BY fraud_amount DESC 

-- INSIGHT:
-- Fraud originators in this dataset typically execute a single large transfer
-- to a single receiving account rather than distributing funds across multiple
-- receivers. This suggests the simulated fraud scenario models account takeover
-- followed by immediate fund extraction rather than complex laundering networks.


-- ============================================================
-- 16. ENGINE (MODEL TABLE)
-- ============================================================

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
