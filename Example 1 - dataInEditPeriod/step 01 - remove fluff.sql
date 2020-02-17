-- step 1
-- remove "fluff" (versioning comments should go into the VCS as commit comments)
-- re-format to make control-flow visible
CREATE FUNCTION "F_KEEP_DATE"
                (TDATE DATE, TTODAY DATE) 
RETURNS RETVALUE CHAR
LANGUAGE SQLSCRIPT   
SQL SECURITY INVOKER AS
BEGIN
    RETVALUE := 'F';
    
    IF :TDATE BETWEEN ADD_DAYS( TO_DATE(:TTODAY, 'YYYY-MM-DD')
                               , -30) 
                  AND :TTODAY 
        OR TO_CHAR( EXTRACT( MONTH FROM ADD_DAYS( TO_DATE(:TDATE, 'YYYY-MM-DD'), 1)))
            <>  TO_CHAR( EXTRACT( MONTH FROM TO_DATE( :TDATE, 'YYYY-MM-DD')))
    THEN 
        RETVALUE := 'T';
    END IF;
END ;