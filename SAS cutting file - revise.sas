/********Omar Hyder April 2025**********/
/*****File to cut NIS Dataset***********/
/**Extarcting thoracic surgical procs***/
/**********Include 2012-2022 at the end***/
/*****May need a tweak or two because 
it was edited to add 2021 and 2022****/
/**2021 and 2022 have hospitals merged into core***/
                  __
              ___( o)>
              \ <_. )
               `---;  


libname NIS 'F:\NIS_BDATS_00_22_040825';
libname THOR 'C:\Users\hyder\Documents\Research\Thoracic Surgery Malnutrition\SAS Archive';
libname HDD 'F:\Research 2021\Thoracic Surgery Main\SAS Local Data Folder';
libname HOSP 'F:\NIS_BDATS_00_22_040825\Hospital SAS';


/*******extractaing thoracic surgical procedures from 2016-2020*****/
%macro years2;

%do yr=2016 %to 2022;

	data NIS_&yr._core;
	set NIS.NIS_&yr._core;

		%do i= 1 %to 35;
	
	
			if I10_PR&i in (
			'0BTC0ZZ',
			'0BTC4ZZ',
			'0BTD0ZZ',
			'0BTD4ZZ',
			'0BTF0ZZ',
			'0BTF4ZZ',
			'0BTG0ZZ',
			'0BTG4ZZ',
			'0BTH0ZZ',
			'0BTH4ZZ',
			'0BTJ0ZZ',
			'0BTJ4ZZ') then lobe=1;
			
			if I10_PR&i in (
			'0BBC0ZX',
			'0BBC0ZZ',
			'0BBC4ZX',
			'0BBC4ZZ',
			'0BBD0ZX',
			'0BBD0ZZ',
			'0BBD4ZX',
			'0BBD4ZZ',
			'0BBF0ZX',
			'0BBF0ZZ',
			'0BBF4ZX',
			'0BBF4ZZ',
			'0BBG0ZX',
			'0BBG0ZZ',
			'0BBG4ZX',

			'0BBG4ZZ',
			'0BBH0ZX',
			'0BBH0ZZ',
			'0BBH4ZX',
			'0BBH4ZZ',
			'0BBJ0ZX',
			'0BBJ0ZZ',
			'0BBJ4ZX',
			'0BBJ4ZZ',
			'0BBK0ZX',
			'0BBK0ZZ',
			'0BBK4ZX',
			'0BBK4ZZ',
			'0BBL0ZX',
			'0BBL0ZZ',
			'0BBL4ZX',
			'0BBL4ZZ',
			'0BBM0ZX',
			'0BBM0ZZ',
			'0BBM4ZX',
			'0BBM4ZZ'

		) then wedge_segment=1;
		%end;
		
		if age lt 18 then delete;

		if lobe=1 or wedge_segment=1 then output;
	run;
%end;
%mend;

%years2;

proc freq data=nis_2022_core;
tables lobe wedge_segment;
run;

/********SORTING ALL THE DATASETS***/

%macro hospital_merged1;

%do year=2016 %to 2022;

proc sort data=HOSP.NIS_&YEAR._HOSPITAL; by HOSP_NIS; run;
proc sort data=NIS_&YEAR._CORE; by HOSP_NIS; run;
%END;

%MEND;
%HOSPITAL_MERGED1;

/*********MERGING CORE WITH HOSPITALS********/
/*********THIS STEP OVERWRITES THE TEMP CORE FILES***BEWARE OF ERRORS****/
%macro hospital_merged2;

%do year=2016 %to 2022;

data NIS_&YEAR._CORE;
merge 	NIS_&YEAR._CORE (in=match)
		HOSP.NIS_&YEAR._HOSPITAL;
by 		HOSP_NIS;
if 		match;
run;

%END;

%MEND;
%HOSPITAL_MERGED2;

/*******Merging everything together*****/
data THOR.merged_revise; 
set 	
		NIS_2016_core
		NIS_2017_core
		NIS_2018_core
		NIS_2019_core
		NIS_2020_core
		NIS_2021_core
		NIS_2022_core

;
/*if HOSP_TEACH=. then delete;*/
run;

/********Code bank*****/
			'0BTC0ZZ', Resection of Right Upper Lung Lobe, Open Approach
			'0BTC4ZZ', Resection of Right Upper Lung Lobe, Percutaneous Endoscopic Approach
			'0BTD0ZZ', Resection of Right Middle Lung Lobe, Open Approach.
			'0BTD4ZZ', Resection of Right Middle Lung Lobe, Percutaneous Endoscopic Approach
			'0BTF0ZZ', Resection of Right Lower Lung Lobe, Open Approach
			'0BTF4ZZ', Resection of Right Lower Lung Lobe, Percutaneous Endoscopic Approach
			'0BTG0ZZ', Resection of Left Upper Lung Lobe, Open Approach.
			'0BTG4ZZ', Resection of Left Upper Lung Lobe, Percutaneous Endoscopic Approach.
			'0BTH0ZZ', Resection of Lung Lingula, Open Approach
			'0BTH4ZZ', Resection of Lung Lingula, Percutaneous Endoscopic Approach
			'0BTJ0ZZ', Resection of Left Lower Lung Lobe, Open Approach.
			'0BTJ4ZZ' Resection of Left Lower Lung Lobe, Percutaneous Endoscopic Approach

/* 114113 adult patients */

/*********Labeling stuff - esophagectomies CCI********/
/*******CCI CID 10 from http://mchp-appserv.cpe.umanitoba.ca/Upload/SAS/_CharlsonICD10.sas.txt***/



%Macro labels;

data thor.merged1_revise; set thor.merged_revise;

/**********CCI ICD 9 Labels***********/
length acute_mi history_mi mi chf pvd cvd copd dementia paralysis diabetes diabetes_comp 
    renal_disease mild_liver_disease liver_disease ulcers rheum_disease aids Charlson 3.;

	acute_mi=0; history_mi=0; mi=0; chf=0; pvd=0; cvd=0; 
	copd=0; dementia=0; paralysis=0; diabetes=0; diabetes_comp=0; 
    renal_disease=0; mild_liver_disease=0; liver_disease=0; 
	ulcers=0; rheum_disease=0; aids=0; 

	Charlson=0; NCIIndex=0; cancer=0; metastatic_cancer=0; thor_cancer=0;
	pneumonia=0; resp_failure=0; sleep_apnea=0; osa=0; pot=0;

	 lung_Ca=0; resp_complication=0; complication=0;
					comp_of_care=0; 
	vats_proc=0;

	Comp_shock=0; Comp_resp_fail=0; Comp_renal=0; Comp_pulm=0; 
	Comp_infectious=0; Comp_PNA=0; Comp_GI=0; Comp_CV=0; COMP_other=0; 

	airleak=0; afibflutter=0; COMP_SEV=0;

/* Variables for Hopkins ACG score */
			ACG_Frail=0; *frailty indicator;

			Malnutrition_ = 0; 
			dementia_AMS_ = 0; 
			vision_impairment_ = 0;
			Decubitus_ulcer_ = 0;
			Urinaryincontinence_ = 0;  
			fecal_incont_ = 0;
			wt_loss_ = 0;
			homeless_ = 0;
			difficulty_walking_ = 0;
			fall_ = 0;


%do i= 1 %to 35;

 *** classifying VATS vs open procedures******;

if I10_PR&i in (
			'0BTC4ZZ',
			'0BTD4ZZ',
			'0BTF4ZZ',
			'0BTG4ZZ',
			'0BTH4ZZ',
			'0BTJ4ZZ',
			'0BBC4ZX',
			'0BBC4ZZ',
			'0BBD4ZX',
			'0BBD4ZZ',
			'0BBF4ZX',
			'0BBF4ZZ',
			'0BBG4ZX',
			'0BBG4ZZ',
			'0BBH4ZX',
			'0BBH4ZZ',
			'0BBJ4ZX',
			'0BBJ4ZZ',
			'0BBK4ZX',
			'0BBK4ZZ',
			'0BBL4ZX',
			'0BBL4ZZ',
			'0BBM4ZX',
			'0BBM4ZZ'
) then VATS_proc=1;

/****************This classifies laterality and lobe*****/

/* Assign Laterality (side): 1 = Right, 2 = Left, 3 = Bilateral */
if I10_PR&i in (
    /* Right - Excision */
    '0BBC0ZX','0BBC0ZZ','0BBC4ZX','0BBC4ZZ',  /* Upper */
    '0BBD0ZX','0BBD0ZZ','0BBD4ZX','0BBD4ZZ',  /* Middle */
    '0BBF0ZX','0BBF0ZZ','0BBF4ZX','0BBF4ZZ',  /* Lower */
    '0BBK0ZX','0BBK0ZZ','0BBK4ZX','0BBK4ZZ',  /* Whole lung */
    /* Right - Resection */
    '0BTC0ZZ','0BTC4ZZ',                      /* Upper */
    '0BTD0ZZ','0BTD4ZZ',                      /* Middle */
    '0BTF0ZZ','0BTF4ZZ'                       /* Lower */
) then side = 1;

if I10_PR&i in (
    /* Left - Excision */
    '0BBG0ZX','0BBG0ZZ','0BBG4ZX','0BBG4ZZ',  /* Upper */
    '0BBH0ZX','0BBH0ZZ','0BBH4ZX','0BBH4ZZ',  /* Lingula (Middle) */
    '0BBJ0ZX','0BBJ0ZZ','0BBJ4ZX','0BBJ4ZZ',  /* Lower */
    '0BBL0ZX','0BBL0ZZ','0BBL4ZX','0BBL4ZZ',  /* Whole lung */
    /* Left - Resection */
    '0BTG0ZZ','0BTG4ZZ',                      /* Upper */
    '0BTH0ZZ','0BTH4ZZ',                      /* Lingula */
    '0BTJ0ZZ','0BTJ4ZZ'                       /* Lower */
) then side = 2;

if I10_PR&i in (
    /* Bilateral - Excision only (no resection codes for bilateral) */
    '0BBM0ZX','0BBM0ZZ','0BBM4ZX','0BBM4ZZ'
) then side = 3;

/* Assign Lobe: 1 = Upper, 2 = Middle, 3 = Lower, 4 = Whole Lung, 5 = Bilateral */
if I10_PR&i in (
    /* Upper - Excision */
    '0BBC0ZX','0BBC0ZZ','0BBC4ZX','0BBC4ZZ',
    '0BBG0ZX','0BBG0ZZ','0BBG4ZX','0BBG4ZZ',
    /* Upper - Resection */
    '0BTC0ZZ','0BTC4ZZ',
    '0BTG0ZZ','0BTG4ZZ'
) then lobe_taken = 1;

if I10_PR&i in (
    /* Middle - Excision */
    '0BBD0ZX','0BBD0ZZ','0BBD4ZX','0BBD4ZZ',
    '0BBH0ZX','0BBH0ZZ','0BBH4ZX','0BBH4ZZ',
    /* Middle - Resection */
    '0BTD0ZZ','0BTD4ZZ',
    '0BTH0ZZ','0BTH4ZZ'
) then lobe_taken = 2;

if I10_PR&i in (
    /* Lower - Excision */
    '0BBF0ZX','0BBF0ZZ','0BBF4ZX','0BBF4ZZ',
    '0BBJ0ZX','0BBJ0ZZ','0BBJ4ZX','0BBJ4ZZ',
    /* Lower - Resection */
    '0BTF0ZZ','0BTF4ZZ',
    '0BTJ0ZZ','0BTJ4ZZ'
) then lobe_taken = 3;

if I10_PR&i in (
    /* Whole lung - Excision only */
    '0BBK0ZX','0BBK0ZZ','0BBK4ZX','0BBK4ZZ',
    '0BBL0ZX','0BBL0ZZ','0BBL4ZX','0BBL4ZZ'
) then lobe_taken = 4;

if I10_PR&i in (
    /* Bilateral - Excision only */
    '0BBM0ZX','0BBM0ZZ','0BBM4ZX','0BBM4ZZ'
) then lobe_taken = 5;


/**********CCI ICD 10 labels**********/

           /* Myocardial Infarction */
           if I10_DX&i IN: ('I21', ' I210', 
							'I2101', 
							'I2102', 
							'I2109',
							'I211', 'I2111', 'I2119', 
							'I212', 'I2121', 'I2129',
							'I213', 'I214', 'I219', 
							'I21A', 'I21A1', 'I21A9') then acute_mi=1;

		if I10_DX&i IN: ('I22', 'I220', 'I221', 'I222', 'I228', 'I229',
					'I252', 'I253') then history_mi = 1;
           LABEL CC_GRP_1 = 'Myocardial Infarction';

           /* Congestive Heart Failure */
           if I10_DX&i IN: ('I43','I50','I099','I110','I130','I132','I255','I420','I425','I426',
                         'I427','I428','I429','P290') then chf = 1;
           LABEL CC_GRP_2 = 'Congestive Heart Failure';

           /* Periphral Vascular Disease */
           if I10_DX&i IN: ('I70','I71','I731','I738','I739','I771','I790','I792','K551','K558',
                         'K559','Z958','Z959') then pvd = 1;
           LABEL CC_GRP_3 = 'Periphral Vascular Disease';

           /* Cerebrovascular Disease */
           if I10_DX&i IN: ('G45','G46','I60','I61','I62','I63','I64','I65','I66','I67','I68',
                         'I69','H340') then cvd = 1;
           LABEL CC_GRP_4 = 'Cerebrovascular Disease';

           /* Dementia */
           if I10_DX&i IN: ('F00','F01','F02','F03','G30','F051','G311')
                         then dementia = 1;
           LABEL CC_GRP_5 = 'Dementia';

           /* Chronic Pulmonary Disease */
           if I10_DX&i IN: ('J40','J41','J42','J43','J44','J45','J46','J47','J60','J61','J62','J63',
                         'J64','J65','J66','J67','I278','I279','J684','J701','J703')
                         then copd = 1;
           LABEL CC_GRP_6 = 'Chronic Pulmonary Disease';

           /* Connective Tissue Disease-Rheumatic Disease */
           if I10_DX&i IN: ('M05','M32','M33','M34','M06','M315','M351','M353','M360')
                         then rheum_disease = 1;
           LABEL CC_GRP_7 = 'Connective Tissue Disease-Rheumatic Disease';

           /* Peptic Ulcer Disease */
           if I10_DX&i IN: ('K25','K26','K27','K28') then ulcers = 1;
           LABEL CC_GRP_8 = 'Peptic Ulcer Disease';

           /* Mild Liver Disease */
           if I10_DX&i IN: ('B18','K73','K74','K700','K701','K702','K703','K709','K717','K713',
                         'K714','K715','K760','K762','K763','K764','K768','K769','Z944')
                         then mild_liver_disease = 1;
           LABEL CC_GRP_9 = 'Mild Liver Disease';

           /* Diabetes without complications */
           if I10_DX&i IN: ('E100','E101','E106','E108','E109','E110','E111','E116','E118','E119',
                         'E120','E121','E126','E128','E129','E130','E131','E136','E138','E139',
                         'E140','E141','E146','E148','E149') then diabetes = 1;
           LABEL CC_GRP_10 = 'Diabetes without complications';

           /* Diabetes with complications */
           if I10_DX&i IN: ('E102','E103','E104','E105','E107','E112','E113','E114','E115','E117',
                         'E122','E123','E124','E125','E127','E132','E133','E134','E135','E137',
                         'E142','E143','E144','E145','E147') then diabetes_comp = 1;
           LABEL CC_GRP_11 = 'Diabetes with complications';

           /* Paraplegia and Hemiplegia */
           if I10_DX&i IN: ('G81','G82','G041','G114','G801','G802','G830','G831','G832','G833',
                         'G834','G839') then paralysis = 1;
           LABEL CC_GRP_12 = 'Paraplegia and Hemiplegia';

           /* Renal Disease */
           if I10_DX&i IN: ('N18','N19','N052','N053','N054','N055','N056','N057','N250','I120',
                         'I131','N032','N033','N034','N035','N036','N037','Z490','Z491','Z492',
                         'Z940','Z992') then renal_disease = 1;
           LABEL CC_GRP_13 = 'Renal Disease';

           /* Cancer */
           if I10_DX&i IN: ('C00','C01','C02','C03','C04','C05','C06','C07','C08','C09','C10','C11',
                         'C12','C13','C14','C15','C16','C17','C18','C19','C20','C21','C22','C23',
                         'C24','C25','C26','C30','C31','C32','C33','C34','C37','C38','C39','C40',
                         'C41','C43','C45','C46','C47','C48','C49','C50','C51','C52','C53','C54',
                         'C55','C56','C57','C58','C60','C61','C62','C63','C64','C65','C66','C67',
                         'C68','C69','C70','C71','C72','C73','C74','C75','C76','C81','C82','C83',
                         'C84','C85','C88','C90','C91','C92','C93','C94','C95','C96','C97', 'C7A')
                         then cancer = 1;
           LABEL CC_GRP_14 = 'Cancer';

           /* Moderate or Severe Liver Disease */
           if I10_DX&i IN: ('K704','K711','K721','K729','K765','K766','K767','I850','I859','I864','I982')
                         then liver_disease = 1;
           LABEL CC_GRP_15 = 'Moderate or Severe Liver Disease';

           /* Metastatic Carcinoma */
           if I10_DX&i IN: ('C77','C78','C79','C80') then metastatic_cancer = 1;
           LABEL CC_GRP_16 = 'Metastatic Carcinoma';

           /* AIDS/HIV */
           if I10_DX&i IN: ('B20','B21','B22','B24') then aids = 1;
           LABEL CC_GRP_17 = 'AIDS/HIV';
 

/**********Coding for complications*********/
if 		  i10_dx&i in: ('J13', 'J14', 'J15', 'J16', 'J17', 'J18', 'J22', 'J69', 'J95851') 
then pneumonia=1;
	
if 		  i10_dx&i in: ('J96', 'J80', 'J81', 'J958', 'J981') 
then resp_failure=1;	/**Also includes lung collapse***/

if  I10_dx&i in: ('T80', 'T81', 'T82', 'T83', 'T84', 'T85', 'T86', 'T87',  'T88') then comp_of_care=1;


if I10_dx&i in: ('I469', 'E872', 'I959', 'E875', 'D62', 'A419', 'N179','J939','G9382','G931','E860','R6521',
							'R001','N170','K7200','I9581','I2699','J90','I97711','I97121','I4901','G935','Z8674','Z781',
							'Y92234','Y839','T17590A','R579','R0902','J9561','I9789','I9742','I97191','I509','I472',
							'I248','G936','F05','E8770') then misc_comp=1; 
							/*****i10 list of misc is in I:\Projects\Thoracic Surgery Cut xls complication pull..**/


		/********Maps to complications of medical and surgical care NOS********/

/* THESE FRAILTY CODES ARE NOT USED IN ANALYSIS - SEE SECOND CODE FILE */

if i10_dx&i in: ('C34') then lung_ca=1;


/*********Cording for complications, data driven********/
/********Formats for these codes are on ICD9 page 
I:\Projects\Thoracic Surgery Cut complications pull sheet xls**/

			if  I10_dx&i in: ('R6521', 'I959', 'R579', 'R570', 'I9581', 'T8119XA', 
							'R571', 'T8111XA', 'R6520', 'I97711', 'R578', 'I9589', 
							'J930', 'T8112XA') then Comp_shock=1; 


			if I10_dx&i in: ('J9601', 'J95821', 'J9621', 'J80', 'J810', 'J9600', 
							'J9690', 'J9622', 'J9691', 'Z9911', 'J951', 'J95851', 
							'J9584', 'J9620', 'R0902') then Comp_resp_fail=1;

			if I10_dx&i in: ('N179', 'E872', 'N170') then Comp_renal=1; 


			if I10_dx&i in: ('J441', 'J440', 'J942', 'T17890A', 'T17590A', 
			'J860', 'J948', 'J869', 'E870', 'J9589', 'T8132XA', 'Y836', 'J850', 
			'J95860', 'T17490A', 'T17990A', 'Y838', 'Y839') then Comp_pulm=1;


			if I10_dx&i in: ('A047', 'A419', 'A411', 'A4150') then Comp_infectious=1; 


			if I10_dx&i in: ('J189', 'J690', 'J156', 'J151', 'J15212', 'J155', 
							'J158', 'B371', 'J150', 'J154', 'J188') then Comp_PNA=1;


			if I10_dx&i in: ('G9340', 'G9341', 'F05', 'G931', 'I639', 'G92', 
						'Z781', 'G935', 'R4020', 'F10231', 'G7281') then Comp_Neuro=1;


			if I10_dx&i in: ('K7200', 'K567', 'K559', 'K55069', 'K913', 'K560', 
						'K7290', 'K922') then Comp_GI=1;


			if I10_dx&i in: ('R6510', 'I9789', 'D62', 'J9602', 'I469', 
							'I2699', 'I472', 'I214', 'I471', 'I4901', 'I97121', 
						'D65', 'I509', 'E8770', 'I9752', 'E860', 'I5023', 'I213', 
						'I319', 'I5021', 'I5031', 'I5033', 'I97191', 'I9742', 'J95830', 
						'K661', 'I2109', 'I2119', 'I219', 'I82401', 'I97131', 'I9788', 'J9561') then Comp_CV=1;

			if I10_dx&i in: ('J939', 'J95811', 'J95812', 'J9382', 'T8182XA', 'J9383')  then airleak=1;

			if I10_dx&i in: ('I4891', 'I480', 'I4892', 'I481')  then afibflutter=1;

 


/*******Categorizing*****/

/* ICD-10 Hopkins ACG as listed by Park et al */

/* Malnutrition */
if dx&i in: ('261', '262', '2638', '2639', 'V772')
 or i10_dx&i in: ('E41', 'E43', 'E44', 'E45', 'E46') then Malnutrition_=1;

/* Dementia */
if dx&i in: ('2901', '2902', '2903', '2904')
 or i10_dx&i in: ('F01', 'F02', 'F03', 'F05', 'G30', 'G310') then dementia_AMS_=1;

/* Severe Vision Impairment */
if dx&i in: ('3690', '36900', '36901', '36903', '36904', '36906', '36907', '36908')
 or i10_dx&i in: ('H540X', 'H541', 'H548') then vision_impairment_=1;

/* Decubitus Ulcer */
if dx&i in: ('7070', '70700', '70701', '70702', '70703', '70704', '70705', '70706',
             '70707', '70709', '70720', '70721', '70722', '70723', '70724', '70725')
 or i10_dx&i in: ('L89') then Decubitus_ulcer_=1;

/* Urinary Incontinence */
if dx&i in: ('5964', '5965', '78834', '78837')
 or i10_dx&i in: ('N31', 'N364', 'N3942', 'N3945', 'N3946') then Urinaryincontinence_=1;

/* Fecal Incontinence */
if dx&i in: ('7876')
 or i10_dx&i in: ('R15') then fecal_incont_=1;

/* Weight Loss */
if dx&i in: ('7832', '78321', '78322', '7833')
 or i10_dx&i in: ('R627', 'R630', 'R633', 'R634') then wt_loss_=1;

/* Social Needs Support (Homelessness) */
if dx&i in: ('V600', 'V601', 'V602')
 or i10_dx&i in: ('Z590', 'Z591', 'Z594', 'Z597', 'Z598', 'Z599', 'Z74', 'Z750', 'Z751', 'Z753',
                  'Z754', 'Y93E', 'Y93F', 'Y93G') then homeless_=1;

/* Difficulty in Walking */
if dx&i in: ('7197', '7812')
 or i10_dx&i in: ('R26', 'R27', 'Z993') then difficulty_walking_=1;

/* Falls */
if dx&i in: ('E880', 'E8800', 'E8801', 'E8809', 'E8843')
 or i10_dx&i in: ('W000XXA', 'W001XXA', 'W002XXA', 'W009XXA', 'W010XXA', 'W0110A', 'W0111A', 'W0118A',
                  'W03XXXA', 'W04XXXA', 'W05XXXA', 'W052XXA', 'W06XXXA', 'W07XXXA', 'W08XXXA',
                  'W10XXXA', 'W102XXA', 'W108XXA', 'W109XXA', 'W1781XA', 'W1789XA', 'W1800XA',
                  'W1801XA', 'W1802XA', 'W1809XA', 'W1811XA', 'W1820XA', 'W1831XA', 'W1839XA',
                  'W1841XA', 'W1849XA', 'W193XA') then fall_=1;



%end;

if Malnutrition_ = 1 or dementia_AMS_ = 1 or vision_impairment_ = 1 or Decubitus_ulcer_ = 1 or Urinaryincontinence_ = 1 or
   fecal_incont_ = 1 or wt_loss_ = 1 or homeless_ = 1 or difficulty_walking_ = 1 or fall_ = 1
then ACG_frail = 1;

	  /*******Cancer diagnoses*******/
	all_cancer=0;
	  	if cancer=1 or metastatic_cancer=1 then all_cancer=1;

	if acute_mi=1 or history_mi=1 then mi=1;
	

		if pneumonia=1 or resp_failure=1 then resp_complication=1;
		if pneumonia=1 or resp_failure=1 or acute_mi=1 or comp_of_care=1 or misc_comp =1 then complication=1;
		
/******Cumulative compliations*****/
	COMP_CUM= 	Comp_shock + 
				Comp_resp_fail + 
				Comp_renal + 
				Comp_pulm +  
				Comp_infectious + 
				Comp_PNA + 
				Comp_GI + 
				Comp_CV + 
				COMP_other;

IF COMP_CUM GT 0 THEN COMP_SEV=1;

	age_Cat=0;
	if age lt 50 then age_Cat=1;
	else if 50 le age le 59 then age_cat=2;
	else if 60 le age le 69 then age_cat=3;
	else if age ge 70 then age_Cat=4;

/*****1 white 2 black 3 hispanic 9 all other***/
	race_cat=9;
	if race=1 then race_Cat=1;
	else if race=2 then race_Cat=2;
	else if race=3 then race_cat=3;

/*****1 govt 3 pvt 9 all others/missing**/
	payer=9;
	if pay1=1 or pay1=2 then payer=1;
	else if pay1=3 then payer=3;


	los_cat=0; /*******Categorizing los into 0-7, 7-14, and >14*****/
	if 		0 le los le 7 then los_cat=1;
	else if 8 le los le 14 then los_cat=2;
	else if los gt 14 then los_cat=3;

	/*******Categorizing year of surgery*********/
				YEAR_CAT2=0;
				IF 2016 LE YEAR LE 2017 THEN YEAR_CAT2=1617;
				IF 2018 LE YEAR LE 2019 THEN YEAR_CAT2=1819;
				IF 2020 LE YEAR LE 2022 THEN YEAR_CAT2=2022;


			SES_LOW=0;
			if 1 le ZIPINC_QRTL le 2 THEN SES_LOW=1;

			PAYER_GOVT=0;
			IF PAYER=1 THEN PAYER_GOVT=1;

			HOSP_REGION_MWSO=0;
			IF 2 LE HOSP_REGION LE 3 THEN HOSP_REGION_MWSO=1;

			

			/******FTR rate***/
			FTR=.;
			IF COMP_SEV=1 AND DIED=0 THEN FTR=0;
			IF COMP_SEV=1 AND DIED=1 THEN FTR=1;

	/****Categorizing ROUTINE discharge******/
	routine_dc=9;
	if Dispuniform = 1 or dispuniform = 6 then routine_dc=1;

	  *** Calculate the Charlson Comorbidity Score for prior conditions;
    Charlson = 
      1*(/*acute_mi or*/ history_mi) +
      1*(chf) +
      1*(pvd) +
      1*(cvd) +
      1*(copd) +
      1*(dementia) +
      2*(paralysis) +
      1*(diabetes and not diabetes_comp) +
      2*(diabetes_comp) +
      2*(renal_disease) +
      1*(mild_liver_disease and not liver_disease) +
      3*(liver_disease) +
      1*(ulcers) +
      1*(rheum_disease) +
      6*(aids);

	  	/********High comorbidity is Charlson gt 2*****/
	high_comorb=0;
	if charlson gt 2 then high_comorb=1;

	CCIGT2=0;
			IF CHARLSON GE 3 THEN CCIGT2=1;



label 
    Charlson           = 'Charlson comorbidity score'
    NCIindex           = 'NCI comorbidity index'
    acute_mi           = 'Acute Myocardial Infarction'
    history_mi         = 'History of Myocardial Infarction'
    chf                = 'Congestive Heart Failure'
    pvd                = 'Peripheral Vascular Disease'
    cvd                = 'Cerebrovascular Disease'
    copd               = 'Chronic Obstructive Pulmonary Disease'
    dementia           = 'Dementia'
    paralysis          = 'Hemiplegia or Paraplegia'
    diabetes           = 'Diabetes'
    diabetes_comp      = 'Diabetes with Complications'
    renal_disease      = 'Moderate-Severe Renal Disease'
    mild_liver_disease = 'Mild Liver Disease'
    liver_disease      = 'Moderate-Severe Liver Disease'
    ulcers             = 'Peptic Ulcer Disease'
    rheum_disease      = 'Rheumatologic Disease'
    aids               = 'AIDS';

	run;


%mend;
%labels;

/* HFRS Calculation */
/*------------------------------------------------------------
 HFRS in NIS (no POA), 34 dx slots: I10_DX1–I10_DX34
 CSV of stems/points: set &HFRS_CSV macro variable accordingly.
------------------------------------------------------------*/
%let HFRS_CSV = C:\Users\hyder\Partners HealthCare Dropbox\Omar Hyder\Research\SAS Code Library\hospital_frailty_icd_points_clean.csv;

/* Macro:
   in=     input NIS dataset (must contain i10_dx1–i10_dx34)
   idvar=  observation identifier (default KEY_NIS)
   csv=    HFRS CSV path (default &HFRS_CSV)
   out=    output score dataset
   outdrv= optional: per-record matched drivers (one row per dx match)
*/
%macro NIS_HFRS(in=, idvar=KEY_NIS, csv=&HFRS_CSV, out=nis_hfrs_score, outdrv=nis_hfrs_drivers);

  %local _tmpdx _tmplong _tmpmatch _tmpbest _codesraw _codes;

  %let _tmpdx    = _hfrs_dxprep_;
  %let _tmplong  = _hfrs_long_;
  %let _codesraw = _hfrs_codes_raw_;
  %let _codes    = _hfrs_codes_norm_;
  %let _tmpmatch = _hfrs_matches_all_;
  %let _tmpbest  = _hfrs_matches_best_;

  /* 1) Import HFRS stems & normalize (uppercase, strip dots) */
  proc import datafile="&csv" out=&_codesraw dbms=csv replace;
    guessingrows=max; getnames=yes;
  run;

  data &_codes;
    set &_codesraw;
    length CODE_STEM $10;
    CODE_STEM = compress(upcase(ICD10_Code), '.');   /* e.g., N39 */
    CODE_LEN  = length(CODE_STEM);
    keep ICD10_Code ICD10_Description Points CODE_STEM CODE_LEN;
  run;

  /* 2) Clean NIS dx and make a long table (no POA; all codes count) */
  data &_tmpdx;
    set &in;
    length &idvar 8;
    array dx_raw[34]  $ I10_DX1-I10_DX34;
    array dx_norm[34] $ dx01-dx34;

    do _i=1 to 34;
      dx_norm[_i] = compress(upcase(dx_raw[_i]), '.'); /* 'N39.0'->'N390' */
    end;
    drop _i;
  run;

  proc sort data=&_tmpdx; by key_nis; run;

  proc transpose data=&_tmpdx out=&_tmplong(rename=(col1=CODE_NORM)) name=var;
    by &idvar;
    var dx01-dx34;
  run;

  data &_tmplong;
    set &_tmplong;
    if not missing(CODE_NORM);
    length Patient_Code $10;
    Patient_Code = CODE_NORM;  /* synonym for clarity */
  run;

  /* 3) Prefix-join each patient dx to HFRS stems */
  proc sql;
    create table &_tmpmatch as
    select n.&idvar,
           n.Patient_Code,
           f.ICD10_Code          as Stem_Code,
           f.ICD10_Description,
           f.Points,
           f.CODE_STEM,
           f.CODE_LEN
    from &_tmplong n
    left join &_codes f
      on substr(n.Patient_Code, 1, f.CODE_LEN) = f.CODE_STEM;
  quit;

  /* 4) Keep the LONGEST matched stem per patient code (avoid duplicates) */
  proc sql;
    create table &_tmpbest as
    select *
    from &_tmpmatch
    group by &idvar, Patient_Code
    having CODE_LEN = max(CODE_LEN);
  quit;

  /* 5) Separate matched vs unmatched (drivers optional) */
  data &outdrv._unmatched &outdrv._matched;
    set &_tmpbest;
    if missing(CODE_STEM) then output &outdrv._unmatched;
    else output &outdrv._matched;
  run;

  /* 6) Collapse to per-record HFRS score (sum points) */
  proc sql;
    create table &out as
    select &idvar,
           sum(Points) as HFRS_Score
    from &outdrv._matched
    group by &idvar;
  quit;

  /* Ensure all records appear; fill 0 when no HFRS codes matched */
  proc sql;
    create table &out as
    select a.&idvar,
           coalesce(b.HFRS_Score, 0) as HFRS_Score
    from (select distinct &idvar from &in) as a
    left join &out as b
      on a.&idvar=b.&idvar;
  quit;

  /* 7) Risk categories per Gilbert et al.:
        <5 = low, 5–15 = intermediate, >15 = high
  */
  data &out;
    set &out;
    length HFRS_Risk 8;
    if HFRS_Score < 5 then HFRS_Risk = 1;          /* Low */
    else if 5 <= HFRS_Score <= 15 then HFRS_Risk = 2; /* Intermediate */
    else if HFRS_Score > 15 then HFRS_Risk = 3;    /* High */
    label HFRS_Score = "Hospital Frailty Risk Score"
          HFRS_Risk  = "HFRS risk group (1=Low,2=Intermediate,3=High)";
  run;

%mend NIS_HFRS;


%NIS_HFRS(in=thor.merged1_revise, idvar=KEY_NIS, out=merged1_revise_hfrs, outdrv=nis_hfrs_drivers);

/* Quick QC */
proc contents data=merged1_revise_hfrs; run;

proc freq data=merged1_revise_hfrs;
  tables HFRS_Risk;
run;

proc means data=merged1_revise_hfrs n mean median p25 p75 min max;
  var HFRS_Score;
run;

proc sort data=merged1_revise_hfrs; by key_nis; run;
proc sort data=thor.merged1_revise; by key_nis; run;

/* Merge the HFRS score file back into the main data file */
data thor.merged1_revise;
    merge thor.merged1_revise (in=a)
          merged1_revise_hfrs;
    by key_nis;
    if a;
run;

%macro Summarize_HFRS_Drivers(in=, out=);

  /* Summarize frequency and total point contribution for each code stem */
  proc sql;
    create table &out as
    select 
      CODE_STEM,
      ICD10_Description,
      Points,
      count(*) as Match_Count,
      sum(Points) as Total_Points_Contributed
    from &in
    group by CODE_STEM, ICD10_Description, Points
    order by Total_Points_Contributed desc;
  quit;

%mend Summarize_HFRS_Drivers;

/* Example usage */
%Summarize_HFRS_Drivers(
  in=nis_hfrs_drivers_matched, 
  out=summary_hfrs_code_contributors
);
proc contents data=summary_hfrs_code_contributors; run;
proc print data=summary_hfrs_code_contributors; run;
/* Hospital volume calculation - using all lung resections included in the dataset */ 
/* Step 1: Count annual procedure volume per hospital */

proc sql;
    create table hosp_volume as
    select 
        Year,
        HOSP_NIS,
        count(*) as n_procedures
    from thor.merged1_revise
    where 2016 <= Year <= 2022
    group by Year, HOSP_NIS;
quit;

/* Step 2: Assign volume quartiles (0 = Q1, 3 = Q4) */
proc rank data=hosp_volume out=ranked_volume groups=4;
    by Year;
    var n_procedures;
    ranks volume_quartile;
run;

/* Step 3: Sort for top 10% ranking */
proc sort data=hosp_volume;
    by Year descending n_procedures;
run;

/* Step 4: Assign rank within year to track top performers */
data hosp_volume_ranked;
    set hosp_volume;
    by Year;
    if first.Year then rank = 1;
    else rank + 1;
run;

/* Step 5: Count hospitals per year */
proc sql;
    create table yearly_counts as
    select Year, count(*) as total_hospitals
    from hosp_volume
    group by Year;
quit;

/* Step 6: Merge total count and flag top 10% */
proc sql;
    create table merged_volume as
    select a.*, b.total_hospitals
    from hosp_volume_ranked a
    left join yearly_counts b
    on a.Year = b.Year;
quit;

data hosp_volume_with_flags;
    set merged_volume;
    if rank <= ceil(0.10 * total_hospitals) then top10 = 1;
    else top10 = 0;
run;

/* Step 7: Merge in quartile variable */
proc sort data=hosp_volume_with_flags; by Year HOSP_NIS; run;
proc sort data=ranked_volume; by Year HOSP_NIS; run;

data thor.hosp_volume_categorized;
    merge hosp_volume_with_flags(in=a)
          ranked_volume(keep=Year HOSP_NIS volume_quartile);
    by Year HOSP_NIS;
    if a;
run;

/* Step 8: Merge back into the main dataset */
proc sort data=thor.merged1_revise; by Year HOSP_NIS; run;
proc sort data=thor.hosp_volume_categorized; by Year HOSP_NIS; run;

data thor.merged2_revise;
    merge thor.merged1_revise(in=a)
          thor.hosp_volume_categorized;
    by Year HOSP_NIS;
    if a;
rename top10=topten;
if lobe=. then lobe=0;
if wedge_segment=. then wedge_segment=0;
run;

proc freq data=thor.merged2_Revise; 
tables died female zipinc_qrtl HOSP_BEDSIZE HOSP_LOCTEACH HOSP_REGION payer race_cat;
run;


/********This generates imputation for the Zipincome quartile variable******/
proc mi data=thor.merged2_revise seed=1305417 nimpute=1 out=outex4;
   class ZIPINC_QRTL;
   monotone reg( HOSP_REGION/ details)
            logistic( ZIPINC_QRTL= HOSP_BEDSIZE HOSP_LOCTEACH HOSP_REGION payer race_cat/ details);
   var HOSP_BEDSIZE HOSP_LOCTEACH HOSP_REGION payer race_cat ZIPINC_QRTL;
run;

/* Calculate total number of lobes for first sentence in discussion */
PROC surveyFREQ DATA=thor.merged2_revise;
tables lobe wedge_segment ;
strata NIS_STRATUM;
cluster HOSP_NIS;
weight DISCWT;		
run;



/* Total weighted procedure count among adults 570565. 235575 lobes. 375070 sublobar */

/* Missing 1239/86252 (1.43%) Zipinc QRTL, imputed - missing died 43/86252 (0.05%) and Female 29 (0.03%) excluded */ 

DATA THOR.merged21_revise; SET outex4;*THIS IS WHERE REMOVALS START - HERE YOU HAVE 114,113 PTS;
	
	SES_LOW=0;

	if 1 le ZIPINC_QRTL le 2 THEN SES_LOW=1;

	if age lt 65 then delete; *165,136 ADULTS;
	
		age_Cat1=0;
	if 65 le age le 69 then age_Cat1=1;
	else if 70 le age le 74 then age_cat1=2;
	else if age gt 74 then age_cat1=3;


	
	IF ELECTIVE NE 1 THEN DELETE;*Deleteing non-elective cases;

	if prday1 ne 0 then delete; *Deleting cases not operated upon on the day of admission;
	


	if los lt 0 then delete; * WITH NON-MISSING LOS;

	IF LOS GT 14 THEN DELETE; * With prolonged hospital stay;

	if lung_ca=1 then output; * 34357 pulmonary procedures in >65 year olds;

RUN;

proc freq data=thor.merged21_revise;
where lobe=1;
tables year died;
run;

data thor.merged3_revise; set thor.merged21_revise;	

	if died lt 0 then delete; * LOS AVAILABLE;
		
	if female lt 0 then delete; * WITH AVAILABLE DATA ON GENDER;
run;



%Macro FLOWCHART(vars);
PROC surveyFREQ DATA=outex4;
WHERE &VARS;
TABLES YEAR;
strata NIS_STRATUM;
cluster HOSP_NIS;
weight DISCWT;
RUN;
%mend FLOWCHART;
end;

%FLOWCHART ();
%FLOWCHART (AGE lt 65);
%FLOWCHART (lung_ca lt 1);
%FLOWCHART (FEMALE lt 0);
%FLOWCHART (died lt 0); 

/* Exclusionary procedural features */

%FLOWCHART (AGE GE 65 AND Lung_ca = 1 and lobe = 1 and died gt . and female gt .); *128,120;

%FLOWCHART (AGE GE 65 AND Lung_ca = 1 and lobe = 1 and died gt . and female gt . and (elective ne 1 or prday1 ne 0)); *13020;

%FLOWCHART (AGE GE 65 AND Lung_ca = 1 and lobe = 1 and died gt . and female gt . and elective = 1 and prday1 = 0 and (los >14 or los lt 0)); *13020;


/* Taking forward to the analysis dataset: THOR.Merged3_revise with  34357 patients */


PROC surveyFREQ DATA=thor.merged3_revise;
where lobe = 1;
tables wedge_segment ;
strata NIS_STRATUM;
cluster HOSP_NIS;
weight DISCWT;		
run;
