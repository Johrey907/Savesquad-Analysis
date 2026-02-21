
--Determine the interest per person over time
SELECT
    Name,
    SUM(Saving) AS Total_savings,
    SUM(Loan) AS Total_loans,
    SUM(Loanpay) AS Total_loanpay,
	SUM(Loanout) AS Total_loanout,
	SUM(Loanpayout) AS Total_loanpayout
    CAST(
        SUM(
            CASE 
                WHEN MONTH([Date]) = 5 THEN (1.05 * Loan) - Loan
                ELSE (1.10 * Loan) - Loan                        
            END
        ) AS INT
    ) AS Total_Interest 
FROM 
    savesquad2
GROUP BY  Name;


WITH MemberTotals AS (
    -- 1. Calculate Total Loans, Total Loan Repayments, and Total Interest per member
    SELECT
        Name,
        SUM(Loan) AS Total_Loan,
        SUM(Loanpay) AS Total_loanpay,
        SUM(
            CASE 
                WHEN MONTH([Date]) = 5 
                    THEN (0.05 * Loan) -- 5% interest
                ELSE 
                    (0.10 * Loan)  -- 10% interest
            END
      ) AS Total_Interest
    FROM 
        savesquad
    GROUP BY 
        Name
)
-- 2. Calculate the Outstanding Loan (Total Loans + Total Interest - Total Repayments)
SELECT
    Name,
    Total_Loan,
    Total_loanpay,
    Total_Interest,
    -- Calculate the outstanding amount. Use CAST to ensure the final result is an integer.
    CAST(
        (Total_Loan + Total_Interest - Total_loanpay)
    AS INT) AS Outstanding_Loan
FROM 
    MemberTotals
ORDER BY 
    Outstanding_Loan DESC;


select * from SaveSquad;

SET IDENTITY_INSERT SaveSquad OFF;

INSERT INTO SaveSquad
    (Name, Date, Saving, Loan, Loanpay, ID)
VALUES
    ('Bariki',   '2025-11-25', 100000, '',       '',      64),
    ('Emmanuel', '2025-11-25', 100000, '',   200000,      65),
    ('Hamisi',   '2025-11-25', 100000, '',       '',      66),
    ('Martha',   '2025-11-25', 100000, '',   220000,      67),
    ('Mowen',    '2025-11-25', 100000, '',       '',      68),
    ('Raymond',  '2025-11-25', 100000, '',   275000,      69),
    ('Shamimu',  '2025-11-25', 100000, '',       '',      70);


SELECT * 
FROM SaveSquad2;


ALTER TABLE savesquad2
ADD 
    Loanout DECIMAL(18,2),
    Loanpayout DECIMAL(18,2);

UPDATE savesquad2
SET Loan = NULL,
    Loanout = 200000
WHERE Name = 'Raymond'
  AND Date = '2025-12-31';



  WITH MemberTotals AS (
    -- 1. Calculate totals per member
    SELECT
        Name,
        SUM(COALESCE(Loan, 0)) AS Total_Loan,
        SUM(COALESCE(Loanpay, 0)) AS Total_loanpay,
        -- Calculate interest based on the sum of loans for specific periods
        SUM(
            CASE 
                WHEN MONTH([Date]) = 5 
                    THEN (0.05 * COALESCE(Loan, 0)) 
                ELSE 
                    (0.10 * COALESCE(Loan, 0)) 
            END
      ) AS Total_Interest
    FROM 
        savesquad
    GROUP BY 
        Name
)
-- 2. Final Calculation
SELECT
    Name,
    Total_Loan,
    Total_loanpay,
    Total_Interest,
    -- Rounding or Casting to INT as per your requirement
    CAST(
        (Total_Loan + Total_Interest - Total_loanpay) 
    AS INT) AS Outstanding_Loan
FROM 
    MemberTotals
ORDER BY 
    Outstanding_Loan DESC;