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
