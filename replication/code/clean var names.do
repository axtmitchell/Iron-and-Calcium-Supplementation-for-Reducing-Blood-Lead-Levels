

	*--- Renaming variables to shorter, more convenient names ---*
	rename study                         study
	rename studyid 						 study_id_str
	rename studydesign                   design
	rename publicationyear				 publication_year
	rename country                       country
	rename controlgroupsamplesizeatou    N_ctrl
	rename treatmentgroupsamplesizeat    N_treat
	rename supplementationdurationmonths dur_months
	rename motherageatstartoftrial       mother_age
	rename childageatstartoftrial        child_age
	rename sexdistributionmale           male_pct

	rename wholesamplebllbaselinemean    bll_base_mean
	rename baselineblltreatmentgroupmea  bll_base_tx_mean
	rename baselineblltreatmentgroupsd   bll_base_tx_sd
	rename baselinebllcontrolgroupmean   bll_base_ct_mean
	rename baselinebllcontrolgroupsd     bll_base_ct_sd

	ren baselinecalciumintakeestimate 	ca_base_est
	ren calciumestnotes        		    calcium_est_notes
	ren irondeficient12lserrumf 		pct_iron_deficient
	ren anemic124orsohbdepen 			pct_anemic_old
	ren baselineironmeanhbgdl 			base_hemoglobin
	ren baselineironmeanserrumferre		base_iron
	ren pct_anemic_estimated11orso		pct_anemic_est

	rename postintblltrtgroupmeanµgd  	bll_post_tx_mean
	rename postblltrtgroupsd         	bll_post_tx_sd
	rename postintbllctrlgroupmeanµg  	bll_post_ct_mean
	rename postintbllctrlgroupsd      	bll_post_ct_sd

	rename maineffectdifferenceinmean     effect_str
	rename seofmaineffectonbllnotsd       se_effect_str
	rename statisticalsignificancepvalu   p_value_str
	rename lower95ciofmaineffect          ci_low
	rename higher95ciofmaineffect         ci_high
	rename notesonmaineffectseci          effect_notes

	rename bloodleadmeasurementtool       lead_measure_tool
	rename supplementelement              supplement_element	
	rename supplementcompound             supplement_compound
	rename dosageamountpertimeunit        dosage_amt
	rename durationofsupplementation      dur_months_str
	rename modeofadministration           admin_mode
	rename comparisongroupplacebonoin     comparison_group
	rename calciumintakeincontrolgroup    ctrl_ca_intake
	rename environmentalleadexposurehig   lead_exposure
	rename othernutrientsupplementation   other_supp
	rename representativestudy            study_repr
	rename dropoutrate                    dropout_rate
	rename werethekidsirondeficient       deficiency
	rename studysampleeligibilitycriteri  elig_criteria
	rename whatseperatesthisrowfromoth    effect_variant
	ren 	comliancerateestimate		  compliance_est

	destring(effect_str)	, gen(effect) force
	destring(se_effect_str)	, gen(se_effect) force
	destring(p_value_str)	, gen(p_value) force
	// destring(study_id_str)	, gen(study_id) force
	ren study_id_str study_id
	
	destring bll_base_tx_mean, gen(bll_base_tx_mean_n) force
	destring bll_post_tx_mean, gen(bll_post_tx_mean_n) force
	destring bll_base_ct_mean, gen(bll_base_ct_mean_n) force
	destring bll_post_ct_mean, gen(bll_post_ct_mean_n) force
	
	//destring bll_base_mean, gen(bll_base_mean_n) force
	ren 	bll_base_mean 		bll_base_mean_n

	ren  	N_ctrl 	nctrl
	ren 	N_treat ntrt
	
//	destring pct_anemic_est, replace
//	destring compliance_est, replace
