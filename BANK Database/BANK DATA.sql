select * from bank_data;

use BANK_DB

SELECT DISTINCT LOAN_STATUS FROM bank_data;

-- TOTAL LOAN APPLICATIONS
SELECT COUNT(ID) AS TOTAL_LOAN_APPLICATIONS FROM bank_data;

-- TOTAL FUNDED AMOUNT
SELECT SUM(LOAN_AMOUNT)/1000000 AS 'TOTAL_FUNDED_AMOUNT IN MILLIONS' FROM bank_data;

-- TOTAL PAYMENT RECEIVED
SELECT SUM(TOTAL_PAYMENT)/1000000 AS 'TOTAL_PAYMENT_RECD IN MILLIONS' FROM bank_data;

-- AVERAGE INTEREST RATE
SELECT PURPOSE, ROUND(AVG(INT_RATE), 2)*100 AS AVG_INT_RATE FROM bank_data
GROUP BY PURPOSE;

-- AVERAGE DTI
SELECT ROUND(AVG(DTI), 2)*100 AS 'AVG_DTI' FROM bank_data;

-- AVERAGE DTI GROUP BY MONTH
SELECT YEAR(ISSUE_DATE) AS 'YEAR',
       MONTH(ISSUE_DATE) AS 'MONTH',
	   ROUND(AVG(DTI), 2)*100 AS 'MONTHLY_AVG_DTI'
FROM bank_data
WHERE 
       YEAR(ISSUE_DATE) = 2021
GROUP BY
       YEAR(ISSUE_DATE),
	   MONTH(ISSUE_DATE)
ORDER BY 
       MONTH;

SELECT DISTINCT LOAN_STATUS FROM bank_data;
-- GOOD LOAN VS BAD LOAN :

-- GOOD LOAN APPLICATION %
SELECT COUNT(CASE WHEN LOAN_STATUS = 'FULLY PAID' OR LOAN_STATUS = 'CURRENT' THEN ID END)*100 / COUNT(ID) AS GOOD_LOAN_PERCENTAGE FROM bank_data;
SELECT COUNT(CASE WHEN LOAN_STATUS IN ('FULLY PAID', 'CURRENT') THEN ID END)*100 / COUNT(ID) AS GOOD_LOAN_PERCENTAGE FROM bank_data;

-- GOOD LOAN APPLICATIONS
SELECT COUNT(CASE WHEN LOAN_STATUS IN ('FULLY PAID', 'CURRENT') THEN ID END) AS GOOD_LOAN_APPLICATIONS, COUNT(ID) AS TOTAL_APPLICATIONS FROM bank_data;

-- GOOD LOAN TOTAL AMNT RECD
SELECT CONCAT(CAST(SUM(TOTAL_PAYMENT)/1000000 AS DECIMAL(18,2)), ' ', 'millions') AS 'GOOD_LOAN_TOTAL_AMNT_RECD (in millions)'
FROM bank_data
WHERE loan_status IN ('FULLY PAID', 'CURRENT');

-- BAD LOAN APPLICATIONS %
SELECT COUNT(CASE WHEN LOAN_STATUS = 'CHARGED OFF' THEN ID END)*100 / COUNT(ID) AS BAD_LOAN_PERCENTAGE FROM bank_data;

-- BAD LOAN APPLICATIONS
SELECT COUNT(CASE WHEN LOAN_STATUS IN ('CHARGED OFF') THEN ID END) AS BAD_LOAN_APPLICATIONS, COUNT(ID) AS TOTAL_APPLICATIONS FROM bank_data;

-- BAD LOAN TOTAL AMNT RECD
SELECT CONCAT(CAST(SUM(TOTAL_PAYMENT)/1000000 AS DECIMAL(18,2)), ' ', 'millions') AS 'BAD_LOAN_TOTAL_AMNT_RECD (in millions)'
FROM bank_data
WHERE loan_status IN ('CHARGED OFF');

SELECT * FROM bank_data;


-- MONTH OVER MONTH TOTAL AMOUNT RECD

WITH MONTHLYTOTALS AS (
     SELECT 
	    YEAR(ISSUE_DATE) AS 'YEAR',
	    MONTH(ISSUE_DATE) AS 'MONTH',
	    SUM(TOTAL_PAYMENT) AS 'MONTHLY_TOTAL_PAYMENT_RECEIVED'
	 FROM 
	    bank_data
	 WHERE 
	    YEAR(ISSUE_DATE) = 2021
	 GROUP BY
	    YEAR(ISSUE_DATE),
		MONTH(ISSUE_DATE)
),
MONTHOVERMONTH AS (
     SELECT 
	       T1.YEAR,
	       T1.MONTH,
	       T1.MONTHLY_TOTAL_PAYMENT_RECEIVED AS 'CURRENT_MONTH_PAYMENT',
	       T2.MONTHLY_TOTAL_PAYMENT_RECEIVED AS 'PREVIOUS_MONTH_PAYMENT',
	       T1.MONTHLY_TOTAL_PAYMENT_RECEIVED - T2.MONTHLY_TOTAL_PAYMENT_RECEIVED AS 'MONTH_OVER_MONTH_AMOUNT'
	 FROM
	      MONTHLYTOTALS T1
	 LEFT JOIN
	      MONTHLYTOTALS T2 ON T1.YEAR = T2.YEAR AND T1.MONTH = T2.MONTH + 1
)
SELECT
     YEAR,
	 MONTH,
	 C
	 MONTH_OVER_MONTH_AMOUNT
FROM 
    MONTHOVERMONTH
ORDER BY
    YEAR, 
	MONTH;

-- MONTH TO MONTH AVERAGE INTEREST RATE AND I WANT TO BE ROUNDED OF UPTO 2 DECIMAL PLACES

WITH MonthlyInterestRate AS(
	SELECT
		YEAR(issue_date) as Year,
		MONTH(issue_date) as Month,
		ROUND(AVG(int_rate)*100,2) as monthly_average_interest_rate
	FROM
		bank_data
	WHERE
		YEAR(issue_date) = 2021
	GROUP BY
		YEAR(issue_date),
		MONTH(issue_date)
), 
MonthOverMonthInterestRate AS(
	SELECT
		MIR1.Year,
		MIR1.Month,
		MIR1.monthly_average_interest_rate as Current_Month_Interest_Rate,
		MIR2.monthly_average_interest_rate as Previous_Month_Interest_Rate,
		ROUND((MIR1.monthly_average_interest_rate - MIR2.monthly_average_interest_rate),2) as Month_Over_Month_Interest_Rate
	FROM
		MonthlyInterestRate MIR1
	LEFT JOIN
		MonthlyInterestRate MIR2
	ON
		MIR1.Year = MIR2.Year
		and MIR1.Month = MIR2.Month+1
)
SELECT
	Year, 
	Month, 
	Current_Month_Interest_Rate, 
	Previous_Month_Interest_Rate, 
	Month_Over_Month_Interest_Rate 
FROM 
	MonthOverMonthInterestRate 
ORDER BY
	Year, 
	Month;

select * from bank_data;

Current_Month_Interest_Rate
11.46
11.72
11.86
11.74
12.26
12.27
12.24
12.3
12
12.02
11.94
12.36