set schema refactor;
-- step 06 - pull out CASE-WHEN-ELSE credit-debit-balance into function

drop function balance_from_credits_debits;

create function balance_from_credits_debits 
            (IN CREDITS DECIMAL(19,6)
           , IN DEBITS DECIMAL(19,6))
        
        returns balance DECIMAL(19,6) 
as 
begin
    balance = case 
                when :CREDITS != 0.0 
                then :CREDITS * -1.0
                else :DEBITS
              end;
end;

SELECT 
      OCRD."CardCode" AS "Customer Code"
    , OCRD."CardName" AS "Customer Name"
    , SUM( balance_from_credits_debits(JDT1."SYSCred", JDT1."SYSDeb" ) ) AS "Balance Due"
    , IFNULL(SUM(CASE 
                    WHEN DAYS_BETWEEN(JDT1."DueDate", current_timestamp) < 0 THEN 
                    balance_from_credits_debits(JDT1."BalDueCred", JDT1."BalDueDeb")
                END), 0.00) AS "Future Remit"
    , IFNULL(SUM(
                CASE 
                    WHEN (DAYS_BETWEEN(JDT1."DueDate", current_timestamp) >= 0 AND
                     DAYS_BETWEEN(JDT1."DueDate", current_timestamp) < 30) THEN 
                    balance_from_credits_debits(JDT1."BalDueCred", JDT1."BalDueDeb")
                END), 0.00) AS "0-30 days"
    , IFNULL(SUM(
                CASE 
                    WHEN (DAYS_BETWEEN(JDT1."DueDate", current_timestamp) >= 30 AND
                     DAYS_BETWEEN(JDT1."DueDate", current_timestamp) < 60) THEN 
                    balance_from_credits_debits(JDT1."BalDueCred", JDT1."BalDueDeb")
                END), 0.00) AS "31 to 60 days"
    , IFNULL(SUM(
                CASE 
                    WHEN (DAYS_BETWEEN(JDT1."DueDate", current_timestamp) >= 60 AND
                     DAYS_BETWEEN(JDT1."DueDate", current_timestamp) < 90) THEN 
                    balance_from_credits_debits(JDT1."BalDueCred", JDT1."BalDueDeb")
                END), 0.00) AS "61 to 90 days"
    , IFNULL(SUM(
                CASE 
                    WHEN (DAYS_BETWEEN(JDT1."DueDate", current_timestamp) >= 90 AND
                     DAYS_BETWEEN(JDT1."DueDate", current_timestamp) < 120) THEN 
                    balance_from_credits_debits(JDT1."BalDueCred", JDT1."BalDueDeb")
                END), 0.00) AS "91 to 120 days"
    , IFNULL(SUM(
                CASE 
                    WHEN DAYS_BETWEEN(JDT1."DueDate", current_timestamp) >= 120 THEN 
                    CASE 
                        WHEN "BalDueCred" != 0 THEN "BalDueCred" * -1 
                        ELSE "BalDueDeb" 
                    END 
                END), 0.00) AS "120+ days" 
FROM 
        JDT1 INNER JOIN  OCRD 
    ON JDT1."ShortName" = OCRD."CardCode" 
    AND OCRD."CardType" = 'c' 

GROUP BY 
    OCRD."CardCode", OCRD."CardName" 
HAVING 
    SUM( balance_from_credits_debits(JDT1."SYSCred", JDT1."SYSDeb" ) )  != 0 

ORDER BY 
    OCRD."CardCode";