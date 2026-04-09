/********Barragan-Bradford et al. 07/27/25 **********/
/*****File to analyze NIS Dataset*****/
/***thoracic surgical procs***********/
/******* =< 14 days*******************/
/* GitHub Ready */
                  __
              ___( o)>
              \ <_. )
               `---;  


libname THOR 'C:\Users\hyder\Documents\Research\Thoracic Surgery Malnutrition\SAS Archive';

/******Porting from SAS cutting file is THOR.MERGED3_revise********/

DATA THOR.MERGED4_revise; SET THOR.merged3_revise;

HFRS_Frail15=0;
if HFRS_risk = 3 then HFRS_Frail15=1;

HFRS_frail5=0; if 2 le HFRS_risk le 3 then HFRS_Frail5=1;


if lobe=1 then output;


RUN;


proc freq data=thor.merged4_Revise;
tables hfrs_frail5; run;


proc freq data=thor.merged4_revise;
where ACG_FRAIL=0;
tables malnutrition_ wt_loss_ ;
run;

PROC MEANS DATA=thor.merged4_revise median p25 p75 min max;
VAR AGE los;
RUN;

PROC MEANS DATA=thor.merged4_revise median p25 p75 min max;
by year;
VAR AGE los;
RUN;

PROC MEANS DATA=thor.merged4_revise median p25 p75;
CLASS ACG_FRAIL;
VAR AGE;
RUN;

/* Counts for flow chart */
PROC surveyFREQ DATA=thor.merged4_revise;
WHERE /* and ACG_FRAIL=1*/;
TABLES
		AGE_CAT
		;
strata NIS_STRATUM;
cluster HOSP_NIS;
weight DISCWT;
		
		RUN;

/*******TAble 1 Col 1*******/
PROC surveyFREQ DATA=thor.merged4_revise;
TABLES
		AGE_cat1
		RACE_CAT
		FEMALE
		CCIGT2
		VATS_PROC
		SIDE
		LOBE_TAKEN
		YEAR_CAT2
		ZIPINC_QRTL
		PAYER
		WEDGE_SEGMENT
		HOSP_BEDSIZE
		HOSP_LOCTEACH
		HOSP_REGION
		TOPTEN
	
		
		ACG_FRAIL
		died
		FTR
		HFRS_Frail5
		HFRS_frail15;
strata NIS_STRATUM;
cluster HOSP_NIS;
weight DISCWT;
		format zipinc_qrtl zipincq_fmt.
race_cat racecat_fmt.
female female_fmt.
payer payor_fmt.
elective elective_fmt.
hosp_locteach locteach_fmt.
hosp_bedsize bedsize_fmt.
hosp_region hosp_region.
side side.
lobe_taken lobe_taken.
FTR FTR.
Died died.
ccigt2 ccigt2_fmt.
acg_frail acg_frail.
age_cat1 agecat1_Fmt.
topten topten.
vats_proc vats_proc.;

		RUN;

PROC FREQ DATA=thor.merged4_revise;
tables vats_proc * year
		side * lobe_taken/ norow nocum nopercent;
		format side side.
lobe_taken lobe_taken.;
		run;

PROC surveyFREQ DATA=thor.merged4_revise;
TABLES
		ACG_FRAIL
		died
		FTR
		HFRS_Frail5
		HFRS_frail15;
strata NIS_STRATUM;
cluster HOSP_NIS;
weight DISCWT;
run;

proc means data=thor.merged4_revise median p25 p75 min max;
	var HFRS_score;
run;

/* Frequency of components of frailty */
proc surveyfreq data=thor.merged4_revise; 
where acg_frail=1;
tables 	Malnutrition_   
		dementia_AMS_   
		vision_impairment_   
		Decubitus_ulcer_   
		Urinaryincontinence_  
   		fecal_incont_   
		wt_loss_   
		homeless_   
		difficulty_walking_   
		fall_;
strata NIS_STRATUM;
cluster HOSP_NIS;
weight DISCWT;
run;

proc freq data=thor.merged4_revise; 
tables year*topten/nocol nopercent nocum chisq;
run;


/* RISK FACTORS ASSOC/W FRAILTY */
/* Univariate - Not reported in paper */

%Macro thisset0(vars);

proc logistic data=thor.merged4_revise desc;
class 	COMP_SEV (REF='0')
		AGE_CAT1 (REF='1')
		female (ref='1')
		RACE_CAT (REF='1')
		YEAR_CAT2 (REF='1214')
		ZIPINC_QRTL (REF='4')
		PAYER (REF='3')
		CCIGT2 (REF='0')
		HOSP_BEDSIZE (REF='3')
		HOSP_LOCTEACH (REF='3')
		HOSP_REGION (REF='1')
		TOPTEN (REF='0')
		VATS_PROC (REF='1');

model ACG_FRAIL=&vars/clodds=wald orpvalue;
RUN;
%mend thisset0;

%thisset0 (AGE_CAT1);
%thisset0 (female);
%thisset0 (RACE_CAT);
%thisset0 (YEAR_CAT2);
%thisset0 (ZIPINC_QRTL);
%thisset0 (PAYER);
%thisset0 (CCIGT2);
%thisset0 (HOSP_BEDSIZE);
%thisset0 (HOSP_LOCTEACH);
%thisset0 (HOSP_REGION);
%thisset0 (TOPTEN);

/* Multivariate logistic regression model for results */
proc logistic data=thor.merged4_revise desc;
class 	COMP_SEV (REF='0')
		ACG_FRAIL 
		AGE_CAT1 (ref='1')
		female (ref='1')
		RACE_CAT (REF='1')
		YEAR_CAT2
		ZIPINC_QRTL (REF='4')
		PAYER (REF='3')
		CCIGT2 (REF='0')
		HOSP_BEDSIZE (REF='3')
		HOSP_LOCTEACH (REF='3')
		HOSP_REGION (REF='1')
		TOPTEN (REF='0')
		VATS_PROC (REF='1');
model ACG_FRAIL = AGE_CAT1  payer female RACE_CAT YEAR_CAT2 ZIPINC_QRTL CCIGT2 HOSP_BEDSIZE
				HOSP_LOCTEACH HOSP_REGION TOPTEN /selection=stepwise slentry=0.05 slstay=0.05 clodds=wald orpvalue;

RUN;

proc logistic data=thor.merged4_revise desc;
class 	COMP_SEV (REF='0')
		ACG_FRAIL 
		AGE_CAT1 (ref='1')
		female (ref='0')
		RACE_CAT (REF='1')
		YEAR_CAT2
		ZIPINC_QRTL (REF='4')
		PAYER (REF='3')
		CCIGT2 (REF='0')
		HOSP_BEDSIZE (REF='3')
		HOSP_LOCTEACH (REF='3')
		HOSP_REGION (REF='1')
		TOPTEN (REF='1')
		VATS_PROC (REF='1');
model HFRS_Frail5 = AGE_CAT1  payer female RACE_CAT YEAR_CAT2 ZIPINC_QRTL CCIGT2 HOSP_BEDSIZE
				HOSP_LOCTEACH HOSP_REGION TOPTEN /selection=stepwise slentry=0.05 slstay=0.05 clodds=wald orpvalue;

RUN;

/* Complication paragraph */
PROC surveyFREQ DATA=thor.merged4_revise; *Col 1;
/*WHERE ACG_FRAIL=1;*/
TABLES	COMP_SEV
		Comp_pulm
		Comp_CV
		Comp_GI
		Comp_renal

		COMP_RESP_FAIL
		COMP_PNA
		COMP_SHOCK
		AFIBFLUTTER
		AIRLEAK
		LOS_CAT
		ROUTINE_DC
		DIED
		FTR;
strata NIS_STRATUM;
cluster HOSP_NIS;
weight DISCWT;
		
		RUN;

PROC surveyFREQ DATA=thor.merged4_revise; *Col 2;
WHERE ACG_FRAIL=0;
TABLES	COMP_SEV
		Comp_pulm
		Comp_CV
		Comp_GI
		Comp_renal

		COMP_RESP_FAIL
		COMP_PNA
		COMP_SHOCK
		AFIBFLUTTER
		AIRLEAK
		LOS_CAT
		ROUTINE_DC
		DIED
		FTR;
strata NIS_STRATUM;
cluster HOSP_NIS;
weight DISCWT;
		
		RUN;
proc sort data=thor.merged4_revise; by hfrs_frail5;
run;

PROC surveyFREQ DATA=thor.merged4_revise; *Col 3;
by hfrs_frail5;;
TABLES	/*COMP_SEV
		Comp_pulm
		Comp_CV
		Comp_GI
		Comp_renal

		COMP_RESP_FAIL
		COMP_PNA
		COMP_SHOCK
		AFIBFLUTTER
		AIRLEAK
		LOS_CAT*/
		ROUTINE_DC
		DIED
		FTR;
strata NIS_STRATUM;
cluster HOSP_NIS;
weight DISCWT;
		
		RUN;

PROC FREQ DATA=thor.merged4_revise; *p-value calculation;
WHERE;
TABLES  
		/*COMP_SEV*ACG_FRAIL
		COMP_SEV*HFRS_Frail5*/
		Comp_pulm*ACG_FRAIL
		Comp_CV*ACG_FRAIL
		Comp_renal*ACG_FRAIL
		Comp_GI*ACG_FRAIL

		COMP_PNA*ACG_FRAIL
		COMP_SHOCK*ACG_FRAIL
		AFIBFLUTTER*ACG_FRAIL
		AIRLEAK*ACG_FRAIL
		/*LOS_CAT*ACG_FRAIL
		ROUTINE_DC*ACG_FRAIL
		DIED*ACG_FRAIL
		FTR*ACG_FRAIL*/
		/norow nocum nopercent CHISQ;
RUN;

/* LOS calculator for the complications table */
proc means data=thor.merged4_revise MEDIAN p25 p75 MAXDEC=2;
var LOS;
run;

/* Calculate coefficient of variation, median, and IQR with the last row in the table - copy to excel, transpose - use JS via Claude */
Proc freq data=thor.merged4_revise; *complications freq by year;
by year;
tables comp_sev*amonth;
run;

proc sort data=thor.merged4_revise; by age_cat1;
run;

/* For age categories and complication description */
PROC FREQ DATA=thor.merged4_revise; *Col 2;
TABLES	COMP_SEV*age_cat1
		Comp_pulm*age_cat1
		Comp_CV*age_cat1
		Comp_GI*age_cat1
		Comp_renal*age_cat1

		COMP_RESP_FAIL*age_cat1
		COMP_PNA*age_cat1
		COMP_SHOCK*age_cat1
		AFIBFLUTTER*age_cat1
		AIRLEAK*age_cat1/norow nopercent nocum chisq;
		
		RUN;

/* Univariate (not shown in paper) and multivariable logistic regression analysis of frailty and complications */

%Macro thisset1(vars);

proc logistic data=thor.merged4_revise desc;
class 	COMP_SEV (REF='0')
		ACG_FRAIL (REF='0')
		AGE_CAT (REF='1')
		female (ref='1')
		RACE_CAT (REF='1')
		YEAR_CAT2 (REF='1214')
		ZIPINC_QRTL (REF='4')
		PAYER (REF='3')
		CCIGT2 (REF='0')
		HOSP_BEDSIZE (REF='3')
		HOSP_LOCTEACH (REF='3')
		HOSP_REGION (REF='1')
		TOPTEN (REF='0')
		VATS_PROC (REF='1');

model COMP_SEV=&vars /clodds=wald orpvalue;
RUN;
%mend thisset1;

%thisset1 (ACG_FRAIL);
%thisset1 (AGE_CAT);
%thisset1 (female);
%thisset1 (RACE_CAT);
%thisset1 (YEAR_CAT2);
%thisset1 (ZIPINC_QRTL);
%thisset1 (PAYER);
%thisset1 (CCIGT2);
%thisset1 (HOSP_BEDSIZE);
%thisset1 (HOSP_LOCTEACH);
%thisset1 (HOSP_REGION);
%thisset1 (TOPTEN);
%thisset1 (VATS_PROC);

/* ACG frail */
proc logistic data=thor.merged4_revise desc;
class 	COMP_SEV (REF='0')
		ACG_FRAIL (REF='0')
		AGE_CAT1 (REF='1')
		female (ref='1')
		RACE_CAT (REF='1')
		YEAR_CAT2
		ZIPINC_QRTL (REF='1')
		PAYER (REF='3')
		CCIGT2 (REF='0')
		HOSP_BEDSIZE (REF='3')
		HOSP_LOCTEACH (REF='3')
		HOSP_REGION (REF='1')
		TOPTEN (REF='0')
		VATS_PROC (REF='1');
model COMP_SEV= ACG_FRAIL AGE_CAT1 female RACE_CAT YEAR_CAT2 ZIPINC_QRTL PAYER CCIGT2 HOSP_BEDSIZE
				HOSP_LOCTEACH HOSP_REGION TOPTEN VATS_PROC/selection=stepwise clodds=wald orpvalue;
RUN;

/* HFRS frail5 */
proc logistic data=thor.merged4_revise desc;
class 	COMP_SEV (REF='0')
		ACG_FRAIL (REF='0')
		AGE_CAT1 (REF='1')
		female (ref='1')
		RACE_CAT (REF='1')
		YEAR_CAT2
		ZIPINC_QRTL (REF='1')
		PAYER (REF='3')
		CCIGT2 (REF='0')
		HOSP_BEDSIZE (REF='3')
		HOSP_LOCTEACH (REF='3')
		HOSP_REGION (REF='1')
		TOPTEN (REF='0')
		VATS_PROC (REF='1');
model COMP_SEV= HFRS_frail5 AGE_CAT1 female RACE_CAT YEAR_CAT2 ZIPINC_QRTL PAYER CCIGT2 HOSP_BEDSIZE
				HOSP_LOCTEACH HOSP_REGION TOPTEN VATS_PROC/selection=stepwise clodds=wald orpvalue;
RUN;


/* In-hospital cost calculator - HRFS */
proc sort data=thor.merged4_revise; by HFRS_frail5; run;

proc means data=thor.merged4_revise MEDIAN p25 p75 MAXDEC=2;
by HFRS_Frail5;
var totchg los;
/*class los_Cat comp_sev;*/
run;


PROC NPAR1WAY DATA=thor.merged4_revise wilcoxon; *p-value calculation;
where;
class HFRS_frail5;
var totchg;
run;

/* Mediation analysis for relationship between HFRS and increased costs */
/* Model 1: Total Effect (HFRS ? Charges) */
proc reg data=thor.merged4_revise;
  model totchg = HFRS_score;
  title "Model 1: Total Effect of HFRS on Charges";
run;

/* Model 2: Mediator (HFRS ? LOS) */
proc reg data=thor.merged4_revise;
  model los = HFRS_score;
  title "Model 2: Effect of HFRS on LOS";
run;

/* Model 3: Direct Effect (HFRS ? Charges adjusted for LOS) */
proc reg data=thor.merged4_revise;
  model totchg = HFRS_score los;
  title "Model 3: Direct Effect of HFRS on Charges (adjusted for LOS)";
run;






/* This generates the ACG and HFRS FTR data */

/* ACG */
proc sort data=thor.merged4_revise; by ACG_frail; run;

PROC surveyFREQ DATA=thor.merged4_revise; 
by ACG_frail;
TABLES
		FTR;
strata NIS_STRATUM;
cluster HOSP_NIS;
weight DISCWT;
		
		RUN;

/* HFRS */
proc sort data=thor.merged4_revise; by hfrs_risk; run;

PROC surveyFREQ DATA=thor.merged4_revise; 
by hfrs_risk;
TABLES
		FTR;
strata NIS_STRATUM;
cluster HOSP_NIS;
weight DISCWT;
		
		RUN;

proc sort data=thor.merged4_revise; by hfrs_frail5; run;


PROC surveyFREQ DATA=thor.merged4_revise; 
by hfrs_frail5;
TABLES
		FTR;
strata NIS_STRATUM;
cluster HOSP_NIS;
weight DISCWT;
		
		RUN;
/* Failure to rescue calculation */

proc sort data=thor.merged4_revise; by acg_frail; run;
/* Overall FTR rate */
PROC surveyFREQ DATA=thor.merged4_revise;
WHERE comp_Sev=1 ;
tables died;
strata NIS_STRATUM;
cluster HOSP_NIS;
weight DISCWT;		
run;

/* FTR rate by ACG */
proc sort data=thor.merged4_revise; by acg_frail; run;

PROC surveyFREQ DATA=thor.merged4_revise;
WHERE comp_Sev=1;
by acg_frail;
tables died;
strata NIS_STRATUM;
cluster HOSP_NIS;
weight DISCWT;		
run;

/* FTR rate by HFRS risk categories */
proc sort data=thor.merged4_revise; by HFRS_frail5; run;

PROC surveyFREQ DATA=thor.merged4_revise;
WHERE comp_Sev=1;
by HFRS_frail5;
tables died;
strata NIS_STRATUM;
cluster HOSP_NIS;
weight DISCWT;		
run;

/**********Unnivariate*********/
%Macro thisset5(vars);

proc logistic data=thor.merged4_revise desc;
where Comp_sev=1;
class 	
		ACG_FRAIL (REF='0')
		AGE_CAT1 (REF='1')
		female (ref='1')
		RACE_CAT (REF='1')
		YEAR_CAT2 (REF='1214')
		ZIPINC_QRTL (REF='4')
		PAYER (REF='3')
		CCIGT2 (REF='0')
		HOSP_BEDSIZE (REF='3')
		HOSP_LOCTEACH (REF='3')
		HOSP_REGION (REF='1')
		TOPTEN (REF='0')
		VATS_PROC (REF='1')
		LOS_CAT (REF='1')
		;

model died=&vars /clodds=wald orpvalue;
RUN;
%mend thisset5;

%thisset5 (ACG_FRAIL);
%thisset5 (AGE_CAT1);
%thisset5 (female);
%thisset5 (RACE_CAT);
%thisset5 (YEAR_CAT2);
%thisset5 (ZIPINC_QRTL);
%thisset5 (PAYER);
%thisset5 (CCIGT2);
%thisset5 (HOSP_BEDSIZE);
%thisset5 (HOSP_LOCTEACH);
%thisset5 (HOSP_REGION);
%thisset5 (TOPTEN);
%thisset5 (VATS_PROC);

/******Multivariate analysis of frailty and FTR at different shorter LOS****/
%macro thisset52 (var);
proc logistic data=THOR.MERGED4_revise desc;
where comp_sev=1 AND los &var;
class 	
		ACG_FRAIL (REF='0')
		AGE_CAT1 (REF='1')
		female (ref='1')
		RACE_CAT (REF='1')
		YEAR_CAT2 
		ZIPINC_QRTL (REF='1')
		PAYER (REF='3')
		CCIGT2 (REF='0')
		HOSP_BEDSIZE (REF='3')
		HOSP_LOCTEACH (REF='3')
		HOSP_REGION (REF='1')
		TOPTEN (REF='1')
		VATS_PROC (REF='1');
model DIED= ACG_FRAIL AGE_CAT1 female payer RACE_CAT YEAR_CAT2 ZIPINC_QRTL CCIGT2 HOSP_BEDSIZE
				HOSP_LOCTEACH HOSP_REGION TOPTEN VATS_PROC/selection=stepwise clodds=wald orpvalue;
RUN;

%mend thisset52;
%thisset52 (le 14);	*LOS =<14 days;

%macro thisset52 (var);
proc logistic data=THOR.MERGED4_revise desc;
where comp_sev=1 AND los &var;
class 	
		ACG_FRAIL (REF='0')
		AGE_CAT1 (REF='1')
		female (ref='1')
		RACE_CAT (REF='1')
		YEAR_CAT2 
		ZIPINC_QRTL (REF='1')
		PAYER (REF='3')
		CCIGT2 (REF='0')
		HOSP_BEDSIZE (REF='3')
		HOSP_LOCTEACH (REF='3')
		HOSP_REGION (REF='1')
		TOPTEN (REF='1')
		VATS_PROC (REF='1');
model DIED= HFRS_frail5 AGE_CAT1 female payer RACE_CAT YEAR_CAT2 ZIPINC_QRTL CCIGT2 HOSP_BEDSIZE
				HOSP_LOCTEACH HOSP_REGION TOPTEN VATS_PROC/selection=stepwise clodds=wald orpvalue;
RUN;

%mend thisset52;
%thisset52 (le 14);	*LOS =<14 days;

/* Routine discharge */
PROC surveyFREQ DATA=thor.merged4_revise;
where died ne 1;
by acg_frail;
TABLES	routine_dc;
strata NIS_STRATUM;
cluster HOSP_NIS;
weight DISCWT;
		
		RUN;


/*********table (suppl 2) factors associated with inpatient mortality*******/
/****Table 2 analysis of risk factors associated with complications********/
/*****Univariate analysis***********/

		proc freq data=thor.merged4_revise;
		where comp_sev=1;
		tables died;
		run;

PROC surveyFREQ DATA=thor.merged4_revise; *Overall mortality;

TABLES	died died*ftr/chisq;
strata NIS_STRATUM;
cluster HOSP_NIS;
weight DISCWT;
RUN;

proc sort data=thor.merged4_revise; by acg_frail; run;

PROC surveyFREQ DATA=thor.merged4_revise; *by frailty;
by acg_frail;
TABLES	died;
strata NIS_STRATUM;
cluster HOSP_NIS;
weight DISCWT;
RUN;

proc sort data=thor.merged4_revise; by hfrs_frail5; run;


PROC surveyFREQ DATA=thor.merged4_revise; 
by hfrs_frail5;
TABLES
		died;
strata NIS_STRATUM;
cluster HOSP_NIS;
weight DISCWT;
		
		RUN;
/* Univariable - not shown in paper */
%Macro thisset4(vars);

proc logistic data=thor.merged4_revise desc;
where lobe=1;
class 	COMP_SEV (REF='0')
		ACG_FRAIL (REF='0')
		AGE_CAT1 (REF='1')
		female (ref='1')
		RACE_CAT (REF='1')
		YEAR_CAT2
		ZIPINC_QRTL (REF='1')
		PAYER (REF='3')
		CCIGT2 (REF='0')
		HOSP_BEDSIZE (REF='3')
		HOSP_LOCTEACH (REF='3')
		HOSP_REGION (REF='1')
		TOPTEN (REF='0')
		VATS_PROC (REF='1');

model died=&vars/clodds=wald orpvalue;
RUN;
%mend thisset4;

%thisset4 (ACG_FRAIL);
%thisset4 (AGE_CAT);
%thisset4 (female);
%thisset4 (RACE_CAT);
%thisset4 (YEAR_CAT2);
%thisset4 (ZIPINC_QRTL);
%thisset4 (PAYER);
%thisset4 (CCIGT2);
%thisset4 (HOSP_BEDSIZE);
%thisset4 (HOSP_LOCTEACH);
%thisset4 (HOSP_REGION);
%thisset4 (TOPTEN);
%thisset4 (VATS_PROC);
%thisset4 (HFRS_frail5);



proc logistic data=THOR.MERGED4_revise desc; **Multivariate;
class 	COMP_SEV (REF='0')
		AGE_CAT1 (REF='1')
		female (ref='1')
		RACE_CAT (REF='1')
		YEAR_CAT2
		ZIPINC_QRTL (REF='1')
		PAYER (REF='3')
		CCIGT2 (REF='0')
		HOSP_BEDSIZE (REF='3')
		HOSP_LOCTEACH (REF='3')
		HOSP_REGION (REF='1')
		TOPTEN (REF='1')
		VATS_PROC (REF='1')
		ACG_FRAIL (REF = '0');
model died = ACG_FRAIL AGE_CAT1 female RACE_CAT YEAR_CAT2 ZIPINC_QRTL PAYER CCIGT2 HOSP_BEDSIZE
				HOSP_LOCTEACH HOSP_REGION TOPTEN VATS_PROC/selection=stepwise clodds=wald orpvalue;
RUN;

proc logistic data=THOR.MERGED4_revise desc; **Multivariate;
class 	COMP_SEV (REF='0')
		AGE_CAT1 (REF='1')
		female (ref='1')
		RACE_CAT (REF='1')
		YEAR_CAT2
		ZIPINC_QRTL (REF='1')
		PAYER (REF='3')
		CCIGT2 (REF='0')
		HOSP_BEDSIZE (REF='3')
		HOSP_LOCTEACH (REF='3')
		HOSP_REGION (REF='1')
		TOPTEN (REF='1')
		VATS_PROC (REF='1')
		ACG_FRAIL (REF = '0')
		HFRS_Frail5 (ref='0');
model died = HFRS_frail5 AGE_CAT1 female RACE_CAT YEAR_CAT2 ZIPINC_QRTL PAYER CCIGT2 HOSP_BEDSIZE
				HOSP_LOCTEACH HOSP_REGION TOPTEN VATS_PROC/selection=stepwise clodds=wald orpvalue;
RUN;

proc means data=THOR.MERGED4_revise min max mean median std ;
where lobe=1;
var hfrs_score;
run;

/* HFRS exponential relationship visualization */
%let indata = THOR.MERGED4_revise;

/* STEP 1: Comprehensive HFRS distribution ================================ */

proc univariate data=&indata;
  where lobe=1;
  var HFRS_score;
  histogram HFRS_score / normal;
  title "HFRS Distribution - Visual Inspection";
run;

/* STEP 2: Crude mortality by fine-grained HFRS categories ================ */

data hfrs_cat;
  set &indata;
  
  if HFRS_score = 0 then hfrs_group = '00: 0';
  else if 0 < HFRS_score <= 1 then hfrs_group = '01: 0-1';
  else if 1 < HFRS_score <= 2 then hfrs_group = '02: 1-2';
  else if 2 < HFRS_score <= 3 then hfrs_group = '03: 2-3';
  else if 3 < HFRS_score <= 4 then hfrs_group = '04: 3-4';
  else if 4 < HFRS_score <= 5 then hfrs_group = '05: 4-5';
  else if 5 < HFRS_score <= 7 then hfrs_group = '06: 5-7';
  else if 7 < HFRS_score <= 10 then hfrs_group = '07: 7-10';
  else if 10 < HFRS_score <= 15 then hfrs_group = '08: 10-15';
  else if 15 < HFRS_score <= 20 then hfrs_group = '09: 15-20';
  else hfrs_group = '10: 20+';
   
run;

/* Mortality rate by category */
proc freq data=hfrs_cat;
  where lobe=1;
  tables hfrs_group*died / out=crude_rates outpct;
  title "Crude Mortality Rates by HFRS Category";
run;

/* Better formatted output */
data crude_print;
  set crude_rates;
  where died=1;
  
  pct_of_category = COUNT / total_in_category * 100;
  
  label hfrs_group = 'HFRS Range'
        COUNT = 'Deaths'
        total_in_category = 'Total'
        pct_of_category = 'Mortality %';
run;

proc sort data=hfrs_cat;
  by hfrs_group;
run;

proc means data=hfrs_cat nway;
  where lobe=1;
  class hfrs_group;
  var died;
  output out=mortality_by_group mean=mortality_rate n=n sum=deaths;
  title "Mortality Rate by HFRS Category";
run;

proc print data=mortality_by_group;
  var hfrs_group n deaths mortality_rate;
  format mortality_rate percent8.2;
  title "KEY OUTPUT: Look for where mortality rate suddenly increases";
  title2 "This identifies the threshold";
run;

/* STEP 3: Visually plot crude mortality by category ======================= */

proc sgplot data=mortality_by_group;
  series x=hfrs_group y=mortality_rate;
  scatter x=hfrs_group y=mortality_rate / markerattrs=(size=8);
  yaxis label='Mortality Rate' labelattrs=(size=12);
  xaxis label='HFRS Score Category' labelattrs=(size=12);
  title "KEY FIGURE: Crude Mortality Across HFRS Categories";
  title2 "Look for: Flat then sudden jump (threshold) vs. smooth curve (RCS)";
run;


/******Attributable risk calculation*****/
proc freq data=thor.merged4_revise;
/*where comp_sev=1;*/
tables age_cat1*died*ACG_FRAIL;
run;

/*Set up the dataset using the above tables. Analyse using the code in the link below:
https://documentation.sas.com/doc/en/pgmsascdc/9.4_3.4/statug/statug_stdrate_examples03.htm */


data attr; 
input age_cat1 $ Event_E Count_E Event_NE Count_NE;
datalines;
1	5	276	41	6654
2	9	382	37	6966
3	13	591	64	7214
;


2.146263-0.681578=1.46468

0.76498
ods graphics on;
proc stdrate data=attr
             refdata=attr
             method=indirect(af)
             stat=risk
             plots(stratum=horizontal)
             ;
   population event=Event_E  total=Count_E;
   reference  event=Event_NE total=Count_NE;
   strata Age_cat1 / stats;
run;

/* Subgroup analyses - MIS vs open */


PROC FREQ DATA=thor.merged4_revise;
TABLES 	VATS_PROC*COMP_SEV
		VATS_PROC*FTR
		VATS_PROC*ACG_FRAIL
		VATS_PROC*HFRS_FRAIL5/NOCOL NOCUM NOPERCENT;
RUN;



PROC SORT DATA=THOR.MERGED4_REVISE; BY VATS_PROC; RUN;


PROC FREQ DATA=thor.merged4_revise;
BY VATS_PROC;
TABLES 	ACG_fRAIL*COMP_SEV
		HFRS_FRAIL5*COMP_SEV
		ACG_fRAIL*FTR
		HFRS_FRAIL5*FTR
/NOCOL NOCUM NOPERCENT;
RUN;


/* Testing for interaction */
proc logistic data=THOR.MERGED4_revise desc; **Multivariate;
class 	COMP_SEV (REF='0')
		AGE_CAT1 (REF='1')
		female (ref='1')
		RACE_CAT (REF='1')
		YEAR_CAT2
		ZIPINC_QRTL (REF='1')
		PAYER (REF='3')
		CCIGT2 (REF='0')
		HOSP_BEDSIZE (REF='3')
		HOSP_LOCTEACH (REF='3')
		HOSP_REGION (REF='1')
		TOPTEN (REF='1')
		VATS_PROC (REF='1')
		ACG_FRAIL (REF = '0')
		HFRS_Frail5 (ref='0');
model died = HFRS_frail5 VATS_PROC HFRS_frail5*VATS_PROC AGE_CAT1 female RACE_CAT YEAR_CAT2 ZIPINC_QRTL PAYER CCIGT2 HOSP_BEDSIZE
				HOSP_LOCTEACH HOSP_REGION TOPTEN /selection=stepwise clodds=wald orpvalue;
RUN;


/* Testing for interaction */
proc logistic data=THOR.MERGED4_revise desc; **Multivariate;
class 	COMP_SEV (REF='0')
		AGE_CAT1 (REF='1')
		female (ref='1')
		RACE_CAT (REF='1')
		YEAR_CAT2
		ZIPINC_QRTL (REF='1')
		PAYER (REF='3')
		CCIGT2 (REF='0')
		HOSP_BEDSIZE (REF='3')
		HOSP_LOCTEACH (REF='3')
		HOSP_REGION (REF='1')
		TOPTEN (REF='1')
		VATS_PROC (REF='1')
		ACG_FRAIL (REF = '0')
		HFRS_Frail5 (ref='0');
model died = ACG_frail VATS_PROC ACG_frail*VATS_PROC AGE_CAT1 female RACE_CAT YEAR_CAT2 ZIPINC_QRTL PAYER CCIGT2 HOSP_BEDSIZE
				HOSP_LOCTEACH HOSP_REGION TOPTEN /*/selection=stepwise clodds=wald orpvalue*/;
RUN;



















/*********Complications: Code for generating tables of diagnoses among those who died*******/

proc sort data=thor.neo_merged3;
by key_nis;
run;

proc transpose data=thor.neo_merged3 out=inter;
where died=1;
  by key_nis;

  var I10_dx2-I10_dx15; /***Plug in the appropriate dx& or I10_dx& var here to get list***/

run;

proc sql;
  create table WANT as
  select  COL1 as dx_TYPE,
          COUNT(COL1) as FREQUENCY
  from    WORK.INTER
  group by COL1;
quit;

proc print data=work.want;
run;

 data _null_;
      rc=dlgcdir();
      put rc=;
   run;

libname work list;
proc options option=work;
run;

proc datasets library=work kill;

run;

 data _null_; 
      rc=dlgcdir("F:\SAS Work Folder");
      put rc=;
   run;

   libname C19 'I:\Projects\COVID19 2020';

   proc sort data=thor.neo_merged4; by hosp_nis; run;

   data merged99; 
		merge 	thor.neo_merged4 (in=a) 
				c19.hosp_all (in=b);
   by hosp_nis;
   if a;

   run;

/***********end of working code for collating complications*****/
