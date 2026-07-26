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
