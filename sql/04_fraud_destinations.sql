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
