set schema refactor;
-- step 11 - pull customer debit function up, change _customer_debits_credits to _customer_credits_debits

drop function balance_from_credits_debits;

create function balance_from_credits_debits 
            (IN CREDITS DECIMAL(19,6)
           , IN DEBITS DECIMAL(19,6))
        
        returns balance DECIMAL(19,6) 
as 
begin
    balance = case 
                when :CREDITS != 0.0 
                then TO_DECIMAL (:CREDITS * -1.0, 19, 6)
                else :DEBITS
              end;
end;

WITH _customer_credits_debits
("Customer Code", "Customer Name", "SYS Balance Due", "Cust Balance Due", "Due Days") AS 
    (SELECT 
          OCRD."CardCode" AS "Customer Code"
        , OCRD."CardName" AS "Customer Name"
        , balance_from_credits_debits("SYSCred", "SYSDeb" ) as "SYS Balance Due"
        , balance_from_credits_debits("BalDueCred", "BalDueDeb") as "Cust Balance Due"
        , DAYS_BETWEEN(JDT1."DueDate", current_date) AS "Due Days"
     FROM 
            JDT1 INNER JOIN  OCRD 
        ON  JDT1."ShortName" = OCRD."CardCode" 
        AND OCRD."CardType" = 'c' 
    )

SELECT 
      "Customer Code"
    , "Customer Name"
    , SUM("SYS Balance Due") AS "Balance Due"
    , SUM(CASE 
            WHEN ("Due Days" < 0)
            THEN "Cust Balance Due"
          END) AS "Future Remit"
    , SUM(CASE 
            WHEN ("Due Days" BETWEEN 0 AND 30) 
            THEN "Cust Balance Due"
          END) AS "0-30 days"
    , SUM(CASE 
            WHEN ("Due Days" BETWEEN 31 AND 60) 
            THEN "Cust Balance Due"
          END) AS "31 to 60 days"
    , SUM(CASE 
            WHEN ("Due Days" BETWEEN 61 AND 90) 
            THEN "Cust Balance Due"
          END) AS "61 to 90 days"
    , SUM(CASE 
            WHEN ("Due Days" BETWEEN 91 AND 120) 
            THEN "Cust Balance Due"
          END) AS "91 to 120 days"
    , SUM(CASE 
            WHEN ("Due Days" > 121)
            THEN "Cust Balance Due"
           END) AS "121+ days" 
FROM 
    _customer_credits_debits
GROUP BY 
      "Customer Code"
    , "Customer Name" 
HAVING 
    SUM("SYS Balance Due")  != 0 
ORDER BY 
    "Customer Code";

/*
--> small data set

 */

/*
--> large data set
 
 OPERATOR_NAME         	OPERATOR_DETAILS                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  	OPERATOR_PROPERTIES                   	EXECUTION_ENGINE	DATABASE_NAME	SCHEMA_NAME	TABLE_NAME	TABLE_TYPE  	TABLE_SIZE	OUTPUT_SIZE	SUBTREE_COST         
COLUMN SEARCH         	_CUSTOMER_CREDITS_DEBITS.Customer Code, _CUSTOMER_CREDITS_DEBITS.Customer Name, SUM("REFACTOR"."BALANCE_FROM_CREDITS_DEBITS"(JDT1.SYSCred, JDT1.SYSDeb).BALANCE), SUM(CASE WHEN DAYS_BETWEEN(JDT1.DueDate, CURRENT_DATE) < 0 THEN "REFACTOR"."BALANCE_FROM_CREDITS_DEBITS"(JDT1.BalDueCred, JDT1.BalDueDeb).BALANCE ELSE 0.00 END), SUM(CASE WHEN DAYS_BETWEEN(JDT1.DueDate, CURRENT_DATE) >= 0 AND DAYS_BETWEEN(JDT1.DueDate, CURRENT_DATE) <= 30 THEN "REFACTOR"."BALANCE_FROM_CREDITS_DEBITS"(JDT1.BalDueCred, JDT1.BalDueDeb).BALANCE ELSE NULL END), SUM(CASE WHEN DAYS_BETWEEN(JDT1.DueDate, CURRENT_DATE) >= 31 AND DAYS_BETWEEN(JDT1.DueDate, CURRENT_DATE) <= 60 THEN "REFACTOR"."BALANCE_FROM_CREDITS_DEBITS"(JDT1.BalDueCred, JDT1.BalDueDeb).BALANCE ELSE NULL END), SUM(CASE WHEN DAYS_BETWEEN(JDT1.DueDate, CURRENT_DATE) >= 61 AND DAYS_BETWEEN(JDT1.DueDate, CURRENT_DATE) <= 90 THEN "REFACTOR"."BALANCE_FROM_CREDITS_DEBITS"(JDT1.BalDueCred, JDT1.BalDueDeb).BALANCE ELSE NULL END), SUM(CASE WHEN DAYS_BETWEEN(JDT1.DueDate, CURRENT_DATE) >= 91 AND DAYS_BETWEEN(JDT1.DueDate, CURRENT_DATE) <= 120 THEN "REFACTOR"."BALANCE_FROM_CREDITS_DEBITS"(JDT1.BalDueCred, JDT1.BalDueDeb).BALANCE ELSE NULL END), SUM(CASE WHEN DAYS_BETWEEN(JDT1.DueDate, CURRENT_DATE) > 121 THEN "REFACTOR"."BALANCE_FROM_CREDITS_DEBITS"(JDT1.BalDueCred, JDT1.BalDueDeb).BALANCE ELSE NULL END)	LATE MATERIALIZATION, ENUM_BY: CS_JOIN	OLAP            	HXE          	?          	?         	?           	?         	1,381      	0.3273790943751432   
  ORDER BY            	_CUSTOMER_CREDITS_DEBITS.Customer Code ASC                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        	                                      	OLAP            	             	?          	?         	?           	?         	1,381      	0.31707376796184317  
    HAVING            	SUM("REFACTOR"."BALANCE_FROM_CREDITS_DEBITS"(JDT1.SYSCred, JDT1.SYSDeb).BALANCE) != 0                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             	                                      	OLAP            	             	?          	?         	?           	?         	1,381      	0.3169870051659172   
      AGGREGATION     	GROUPING: _CUSTOMER_CREDITS_DEBITS.Customer Code, AGGREGATION: SUM("REFACTOR"."BALANCE_FROM_CREDITS_DEBITS"(JDT1.SYSCred, JDT1.SYSDeb).BALANCE), SUM(CASE WHEN DAYS_BETWEEN(JDT1.DueDate, CURRENT_DATE) < 0 THEN "REFACTOR"."BALANCE_FROM_CREDITS_DEBITS"(JDT1.BalDueCred, JDT1.BalDueDeb).BALANCE ELSE 0.00 END), SUM(CASE WHEN DAYS_BETWEEN(JDT1.DueDate, CURRENT_DATE) >= 0 AND DAYS_BETWEEN(JDT1.DueDate, CURRENT_DATE) <= 30 THEN "REFACTOR"."BALANCE_FROM_CREDITS_DEBITS"(JDT1.BalDueCred, JDT1.BalDueDeb).BALANCE ELSE NULL END), SUM(CASE WHEN DAYS_BETWEEN(JDT1.DueDate, CURRENT_DATE) >= 31 AND DAYS_BETWEEN(JDT1.DueDate, CURRENT_DATE) <= 60 THEN "REFACTOR"."BALANCE_FROM_CREDITS_DEBITS"(JDT1.BalDueCred, JDT1.BalDueDeb).BALANCE ELSE NULL END), SUM(CASE WHEN DAYS_BETWEEN(JDT1.DueDate, CURRENT_DATE) >= 61 AND DAYS_BETWEEN(JDT1.DueDate, CURRENT_DATE) <= 90 THEN "REFACTOR"."BALANCE_FROM_CREDITS_DEBITS"(JDT1.BalDueCred, JDT1.BalDueDeb).BALANCE ELSE NULL END), SUM(CASE WHEN DAYS_BETWEEN(JDT1.DueDate, CURRENT_DATE) >= 91 AND DAYS_BETWEEN(JDT1.DueDate, CURRENT_DATE) <= 120 THEN "REFACTOR"."BALANCE_FROM_CREDITS_DEBITS"(JDT1.BalDueCred, JDT1.BalDueDeb).BALANCE ELSE NULL END), SUM(CASE WHEN DAYS_BETWEEN(JDT1.DueDate, CURRENT_DATE) > 121 THEN "REFACTOR"."BALANCE_FROM_CREDITS_DEBITS"(JDT1.BalDueCred, JDT1.BalDueDeb).BALANCE ELSE NULL END)                 	                                      	OLAP            	             	?          	?         	?           	?         	1,382      	0.3169713006204627   
        JOIN          	JOIN CONDITION: (INNER many-to-one) JDT1.ShortName = OCRD.CardCode                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                	                                      	OLAP            	             	?          	?         	?           	?         	3,453,618  	0.0016443543925119804
          COLUMN TABLE	[FACT]                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            	                                      	OLAP            	HXE          	REFACTOR   	JDT1      	COLUMN TABLE	3,453,618 	3,453,618  	?                    
          COLUMN TABLE	FILTER CONDITION: OCRD.CardType = 'c'                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             	                                      	OLAP            	HXE          	REFACTOR   	OCRD      	COLUMN TABLE	1,382     	1,382      	?                    
 */