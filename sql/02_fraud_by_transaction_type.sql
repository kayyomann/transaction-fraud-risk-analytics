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
