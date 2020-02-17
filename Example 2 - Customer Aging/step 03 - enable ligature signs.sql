set schema refactor;
-- step 03 - replace != with != for editors with ligature support

SELECT 
      OCRD."CardCode" AS "Customer Code"
    , OCRD."CardName" AS "Customer Name"
    , SUM(CASE 
		        WHEN "SYSCred" != 0 THEN "SYSCred" * -1 
		        ELSE "SYSDeb" 
		    END) AS "Balance Due"
    , IFNULL(SUM(CASE 
			        WHEN DAYS_BETWEEN(JDT1."DueDate", current_timestamp) < 0 THEN 
			        CASE 
			            WHEN JDT1."BalDueCred" != 0 THEN JDT1."BalDueCred" * -1 
			            ELSE JDT1."BalDueDeb" 
			        END 
			    END), 0.00) AS "Future Remit"
    , IFNULL(SUM(
			    CASE 
			        WHEN (DAYS_BETWEEN(JDT1."DueDate", current_timestamp) >= 0 AND
			         DAYS_BETWEEN(JDT1."DueDate", current_timestamp) < 30) THEN 
			        CASE 
			            WHEN JDT1."BalDueCred" != 0 THEN JDT1."BalDueCred" * -1 
			            ELSE JDT1."BalDueDeb" 
			        END 
			    END), 0.00) AS "0-30 days"
    , IFNULL(SUM(
			    CASE 
			        WHEN (DAYS_BETWEEN(JDT1."DueDate", current_timestamp) >= 30 AND
			         DAYS_BETWEEN(JDT1."DueDate", current_timestamp) < 60) THEN 
			        CASE 
			            WHEN JDT1."BalDueCred" != 0 THEN JDT1."BalDueCred" * -1 
			            ELSE JDT1."BalDueDeb" 
			        END 
			    END), 0.00) AS "31 to 60 days"
    , IFNULL(SUM(
			    CASE 
			        WHEN (DAYS_BETWEEN(JDT1."DueDate", current_timestamp) >= 60 AND
			         DAYS_BETWEEN(JDT1."DueDate", current_timestamp) < 90) THEN 
			        CASE 
			            WHEN JDT1."BalDueCred" != 0 THEN JDT1."BalDueCred" * -1 
			            ELSE JDT1."BalDueDeb" 
			        END 
			    END), 0.00) AS "61 to 90 days"
    , IFNULL(SUM(
			    CASE 
			        WHEN (DAYS_BETWEEN(JDT1."DueDate", current_timestamp) >= 90 AND
			         DAYS_BETWEEN(JDT1."DueDate", current_timestamp) < 120) THEN 
			        CASE 
			            WHEN JDT1."BalDueCred" != 0 THEN JDT1."BalDueCred" * -1 
			            ELSE JDT1."BalDueDeb" 
			        END 
			    END), 0.00) AS "91 to 120 days"
    , IFNULL(SUM(
			    CASE 
			        WHEN DAYS_BETWEEN(JDT1."DueDate", current_timestamp) >= 120 THEN 
			        CASE 
			            WHEN "BalDueCred" != 0 THEN "BalDueCred" * -1 
			            ELSE "BalDueDeb" 
			        END 
			    END), 0.00) AS "120+ days" 

FROM JDT1, 
    OCRD 
WHERE 
    JDT1."ShortName" = OCRD."CardCode" 
    AND OCRD."CardType" = 'c' 
GROUP BY 
    OCRD."CardCode", OCRD."CardName" 

HAVING SUM(
		CASE 
		    WHEN "SYSCred" != 0 THEN "SYSCred" * -1 
		    ELSE "SYSDeb" 
		END) > 0 
	OR SUM(
		CASE 
		    WHEN "SYSCred" != 0 THEN "SYSCred" * -1 
		    ELSE "SYSDeb" 
		END) < 0 
ORDER BY 
    OCRD."CardCode";