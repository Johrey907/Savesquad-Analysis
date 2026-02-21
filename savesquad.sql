-- Inserting data into the database
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

-- Adding columns in a database as the group has introduced loan to the outsiders with a group mamber as a guarantor
ALTER TABLE savesquad2
ADD 
    Loanout DECIMAL(18,2),
    Loanpayout DECIMAL(18,2);
-- Updating the database
UPDATE savesquad2
SET Loan = NULL,
    Loanout = 200000
WHERE Name = 'Raymond'
  AND Date = '2025-12-31';


-- Group loan report over the year
  WITH MemberTotals AS (
    -- 1. Calculate totals per member using coalesce to make sure null values does not affect the balances wrongly
    SELECT
        Name,
        SUM(COALESCE(Loan, 0)) AS Total_Loan,
        SUM(COALESCE(Loanpay, 0)) AS Total_loanpay,
        -- Calculate interest based on the sum of loans for may and the rest of the month
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
    -- Rounding or Casting to INT 
    CAST(
        (Total_Loan + Total_Interest - Total_loanpay) 
    AS INT) AS Outstanding_Loan
FROM 
    MemberTotals
ORDER BY 
    Outstanding_Loan DESC;