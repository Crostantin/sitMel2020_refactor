-- step 5
-- move the result assignment into the IF clause
CREATE FUNCTION "dataInEditPeriod"(checked_day DATE) 
RETURNS result INTEGER
LANGUAGE SQLSCRIPT   
SQL SECURITY INVOKER 
AS
BEGIN
    
    IF :checked_day BETWEEN ADD_DAYS( current_date, -30) 
                        AND :current_date 
        OR :checked_day = LAST_DAY( :checked_day)
    THEN 
        result := 1;
    ELSE 
        result := 0;
    END IF;
END ;