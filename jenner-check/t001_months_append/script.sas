/************************************************************************************
***** Program:	Proc Append Macro - Example 1 (Append Monthly Dates)  *****
***** Source:	joshkylepearce/SAS-Proc-Append-Macro, "Proc Append Macro.sas"  *****
***** Adapted:	iteration count reduced from 12 to 3 months for a fast bundle run;
***** 		logic, macro body, and PROC APPEND step are otherwise unmodified.  *****
************************************************************************************/

data  dates_appended;
attrib
	start_month	length=8. format=date9.
	end_month 	length=8. format=date9.
;
stop;
run;

%macro months(iterations);

%do i = 1 %to &iterations;

data _null_;
	call symput('start_month',"'"||put(intnx('month',today(),-&i.,'b'),date9.)||"'d");
	call symput('end_month',"'"||put(intnx('month',today(),-&i.,'e'),date9.)||"'d");
	call symput('month',put(intnx('month',today(),-&i.,'e'),yymmn6.));
run;
%put &start_month. &end_month. &month.;

data date_&month.;
	format start_month end_month date9.;
	start_month=&start_month.;
	end_month=&end_month.;
run;

/*Append all monthly tables to create one collated table*/
proc append
	data=date_&month. base=dates_appended force;
run;

%end;

%mend;

%months(3);

proc print data=dates_appended;
run;
