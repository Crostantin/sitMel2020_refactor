# sitMel2020_refactor
Example refactoring series taking a complex SQL and making it easier one step at a time.

On 15.02.2020, a rather rain-drenched stormy day in Melbourne, Australia, the [SAP Inside Tracek #sitMEL – Full Day Event](https://blogs.sap.com/2020/01/19/sap-inside-track-sitmel-full-day-event-in-melbourne-15th-feb-2020/) was held.

I was honored to get a speaker slot and the chance to talk about ["Humane DB design and programming"](--link to presentation). 

A main point of this presentation is to **refactor SQL code towards understanding**. In the presentation I walk through two examples of code refactoring.

This repository contains the code for the examples.

## Example 1: "dataInEditPeriod"-function
This example I found in the SAP Community Platform [forum](https://answers.sap.com/questions/387588/convert-oracle-if-statement-to-hana.html) and wrote about it before in my blog post [SQL Refactoring Example](https://lbreddemann.org/sql-refactoring-example/). 

This code however, goes a bit farther with the refactoring. 

## Example 2: "Customer Aging report/Account receivable report"
Another example from the SAP Community Platform [Q&A forum](https://answers.sap.com/questions/300196/customer-aging-report-for-hana.html).  
A rather classic report of outstanding payments by customer over time periods.  
This example covers more different refactoring steps and highlights newly gained insights along the process. 

## What is is for?
The examples covered here are for educational/entertainent purposes only.  
I do not claim that this is production-ready code, or a reference implementation of solutions or anything beyond being an example for how refactoring code can lead to easier maintainable code and a better understanding of what the code does.

I am happy for anyone to have a look at it but do not expect it to match your requirements.

## How to use the code? 
For each example there is a separate folder containing all files belonging to the example.

As the examples demonstrate steps of code change there is one file per step.  
The files are named `step00 - original.sql` - for the original SQL statement and `step X - <whatever happens in this step>.sql`.

The idea is to run the original code and the changed versions side by side to spot differences in the result set and the runtime quickly.

For example 2 there are also files (`create schema`) to create the tables referenced in the code and to populate them with some data.  
For ad hoc volume testing, there is also a file `create big schema.sql` that generates Millions of records in the referenced `JDT1` table.  

The mock data I used in this example has been created using [Mockaroo])(https://mockaroo.com/) and does **not have any real-life meaning at all**.

Speaking of the tables: the original question referred to a SAP Business One system and the referenced tables seem to stem from there.

As I do not have access to such a system, I googled the table definitions (found [here JDT1](http://www.saptables.co.uk/?schema=BusinessOne9.0&module_id=4&table=JDT1) and [here OCRD](http://www.saptables.co.uk/?schema=BusinessOne9.0&table=OCRD)) and removed any columns not referenced in the statements.  

This means, these are **not the tables that you can find in a SAP system**! Again, do not use these coding examples in your productive systems.
