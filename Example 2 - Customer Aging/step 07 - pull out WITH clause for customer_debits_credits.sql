set schema refactor;
-- step 07 - pull out WITH clause for customer_debits_credits, DUE DAYS calculation

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

WITH _customer_debits_credits
("Customer Code", "Customer Name", "SYSCred", "SYSDeb", "BalDueCred", "BalDueDeb", "Due Days") AS 
    (SELECT 
          OCRD."CardCode" AS "Customer Code"
        , OCRD."CardName" AS "Customer Name"
        , JDT1."SYSCred"
        , JDT1."SYSDeb"
        , JDT1."BalDueCred"
        , JDT1."BalDueDeb"
        , DAYS_BETWEEN(JDT1."DueDate", current_timestamp) AS "Due Days"
     FROM 
            JDT1 INNER JOIN  OCRD 
        ON  JDT1."ShortName" = OCRD."CardCode" 
        AND OCRD."CardType" = 'c'    
    )

SELECT 
      "Customer Code"
    , "Customer Name"
    , SUM( balance_from_credits_debits("SYSCred", "SYSDeb" ) ) AS "Balance Due"
    , IFNULL(SUM(CASE 
                    WHEN "Due Days" < 0 
                    THEN  balance_from_credits_debits("BalDueCred", "BalDueDeb")
                 END), 0.00) AS "Future Remit"
    , IFNULL(SUM(
                CASE 
                    WHEN ("Due Days" >= 0 AND "Due Days" < 30) 
                    THEN balance_from_credits_debits("BalDueCred", "BalDueDeb")
                END), 0.00) AS "0-30 days"
    , IFNULL(SUM(
                CASE 
                    WHEN ("Due Days" >= 30 AND "Due Days" < 60) 
                    THEN balance_from_credits_debits("BalDueCred", "BalDueDeb")
                END), 0.00) AS "31 to 60 days"
    , IFNULL(SUM(
                CASE 
                    WHEN ("Due Days" >= 60 AND "Due Days" < 90) 
                    THEN balance_from_credits_debits("BalDueCred", "BalDueDeb")
                END), 0.00) AS "61 to 90 days"
    , IFNULL(SUM(
                CASE 
                    WHEN ("Due Days" >= 90 AND "Due Days" < 120) 
                    THEN balance_from_credits_debits("BalDueCred", "BalDueDeb")
                END), 0.00) AS "91 to 120 days"
    , IFNULL(SUM(
                CASE 
                    WHEN "Due Days" >= 120 
                    THEN balance_from_credits_debits("BalDueCred", "BalDueDeb")
                END), 0.00) AS "120+ days" 
FROM 
    _customer_debits_credits

GROUP BY 
      "Customer Code"
    , "Customer Name" 
HAVING 
    SUM( balance_from_credits_debits("SYSCred", "SYSDeb" ) )  != 0 

ORDER BY 
    "Customer Code";