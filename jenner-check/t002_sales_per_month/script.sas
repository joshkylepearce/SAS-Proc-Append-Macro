/************************************************************************************
***** Program:	Proc Append Macro - Example 2 (Total Sales Per Month)  *****
***** Source:	joshkylepearce/SAS-Proc-Append-Macro, "Proc Append Macro.sas"  *****
***** Adapted:	iteration count reduced from 12 to 3 months for a fast bundle run;
***** 		the simulated sales-per-day data step, the PROC SQL rollup, and the
***** 		PROC APPEND step are otherwise unmodified.  *****
************************************************************************************/

/*Generate the total number of sales per day*/

/*Create date periods matching dates in the append step above*/
data _null_;
	call symput('sales_start',"'"||put(intnx('month',today(),-1.,'e'),date9.)||"'d");
	call symput('sales_end',"'"||put(intnx('month',today(),-3,'b'),date9.)||"'d");
run;
%put &sales_start. &sales_end.;

/*Sales per day*/
data sales_per_day;
do date = &sales_end. to &sales_start.;
	sales=rand("integer",1,100);
	output;
end;
format date date9.;
run;

/*Generate the total number of sales per month*/

data  sales_per_month;
attrib
	month		length=8.
	total_sales length=8.
;
stop;
run;

%macro sales_per_month(iterations);

%do i = 1 %to &iterations;

data _null_;
	call symput('start_month',"'"||put(intnx('month',today(),-&i.,'b'),date9.)||"'d");
	call symput('end_month',"'"||put(intnx('month',today(),-&i.,'e'),date9.)||"'d");
	call symput('month',put(intnx('month',today(),-&i.,'e'),yymmn6.));
run;
%put &start_month. &end_month. &month.;

data monthly_sales_&month.;
	set sales_per_day;
	where date between &start_month. and &end_month.;
run;

proc sql;
create table total_sales_&month. as
select
	&month. as month
	,sum(sales) as total_sales
from
	monthly_sales_&month.
;
quit;

/*Append all monthly tables to create one collated table*/
proc append
	data=total_sales_&month. base=sales_per_month force;
run;
%end;

%mend;

%sales_per_month(3);

proc print data=sales_per_month;
run;
