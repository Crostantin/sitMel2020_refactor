-- step 3
-- change second part of the OR expression to 
-- use the LAST_DAY() function since this is what is computed here
CREATE FUNCTION "F_KEEP_DATE"
                (TDATE DATE, TTODAY DATE) 
RETURNS RETVALUE CHAR
LANGUAGE SQLSCRIPT   
SQL SECURITY INVOKER AS
BEGIN
    RETVALUE := 'F';
    
    IF :TDATE BETWEEN ADD_DAYS( :TTODAY, -30) 
                  AND :TTODAY 
        OR :TDATE = LAST_DAY( :TDATE)
    THEN 
        RETVALUE := 'T';
    END IF;
END ;