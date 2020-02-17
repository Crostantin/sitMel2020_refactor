-- step 2
-- replace superfluous type cast TO_DATE
-- as the input paramters are already DATE data types
CREATE FUNCTION "F_KEEP_DATE"
                (TDATE DATE, TTODAY DATE) 
RETURNS RETVALUE CHAR
LANGUAGE SQLSCRIPT   
SQL SECURITY INVOKER AS
BEGIN
    RETVALUE := 'F';
    
    IF :TDATE BETWEEN ADD_DAYS( :TTODAY, -30) 
                  AND :TTODAY 
        OR EXTRACT( MONTH FROM ADD_DAYS( :TDATE, 1)) )
            <> EXTRACT( MONTH FROM :TDATE) )
    THEN 
        RETVALUE := 'T';
    END IF;
END ;