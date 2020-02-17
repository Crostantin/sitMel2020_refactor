-- step 6
-- change to single assigment and CASE expression
CREATE FUNCTION "dataInEditPeriod"(checked_day DATE) 
RETURNS result INTEGER
LANGUAGE SQLSCRIPT   
SQL SECURITY INVOKER 
AS
BEGIN
    -- editing is allowed when checked_day is within the past 30 days
    -- or if checked_day is the last day of it's month (?)  
    result := CASE 
                WHEN ( (:checked_day BETWEEN ADD_DAYS (current_date, -30) 
                                        AND current_date) 
                      OR  (:checked_day = LAST_DAY(:checked_day)) ) 
                THEN 1
                ELSE 0
             END;
END ;

-- the function could be used in a statement like the following:
WITH testdata 
("FeeAmount", "FeeIssueDate")
AS (SELECT 
        12.3 AS "FeeAmount"
        , date'20.01.2020' AS "FeeIssueDate" 
    FROM dummy
    UNION ALL
    SELECT 
        8.2 AS "FeeAmount"
        , date'20.12.2019' AS "FeeIssueDate" 
    FROM dummy)
SELECT 
    "FeeAmount"
    , SUM ("FeeAmount" * "dataInEditPeriod"("FeeIssueDate") )  AS "FeesOpenToChange" 
FROM 
    testdata
GROUP BY 
    "FeeAmount"