-- step 4
-- change name of the function to "dataInEditPeriod" as this is what the function determines
-- remove the TTODAY parameter and use the CURRENT_DATE function instead
-- change the return value data type to INTEGER to enable using the function result in SQL calculations
-- changed name of the return value to RESULT 
CREATE FUNCTION "dataInEditPeriod"(checked_day DATE) 
RETURNS result INTEGER
LANGUAGE SQLSCRIPT   
SQL SECURITY INVOKER 
AS
BEGIN
    result := 0;
    
    IF :checked_day BETWEEN ADD_DAYS( current_date, -30) 
                        AND :current_date 
        OR :checked_day = LAST_DAY( :checked_day)
    THEN 
        result := 1;
    END IF;
END ;