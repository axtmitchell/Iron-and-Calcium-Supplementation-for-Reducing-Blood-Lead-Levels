version 18

if "$path" == "" | "$code_dir" == "" {
	capture noisily do "setup_paths.do"
	if _rc {
		capture noisily do "code/setup_paths.do"
	}
	if _rc {
		di as error "Unable to load setup_paths.do."
		exit _rc
	}
}

import excel "$data_dir/supplement rct data.xlsx", sheet("All variables") firstrow case(lower) clear

do "$code_dir/clean var names.do"

*------------------------------------------------------------------------------------------------------------------------------------*
*		 Clean variables
*------------------------------------------------------------------------------------------------------------------------------------*

generate var_effect = se_effect^2
drop if var_effect == .

gen mother = (population_group == "mother")

gen 	type = "Iron" if regexm(supplement_element, "iron")
replace type = "Calcium" if supplement_element == "calcium"
drop if type == ""

gen 	studycountrylabel = study + ", " + country
gen 	studylabel = studycountrylabel + ", " + effect_variant_short if effect_variant_short != ""
replace studylabel = studycountrylabel if missing(studylabel)

ren (country studycountrylabel) (country_raw Country)
ren type Type

gen 	lowcalcium = 0 if ca_base_est != .
replace lowcalcium = 1 if ca_base_est < 440 & population_group == "child"
replace lowcalcium = 1 if ca_base_est < 900 & population_group == "mother"

lab define lowcalcium 0 "Adequate baseline intake + Lower risk of bias" 1 "Calcium deficient population + High risk of bias", replace
lab values lowcalcium lowcalcium

gen 	calcium_std = ca_base_est / 440 if population_group == "child"
replace calcium_std = ca_base_est / 940 if population_group == "mother"
replace calcium_std = calcium_std * 100

gen sample = nctrl + ntrt
order sample

gen 	nosubsamples = 1
replace nosubsamples = 0 if regexm(studylabel, "<") | regexm(studylabel, ">") | regexm(studylabel, "≥") | regexm(studylabel, "excl") | regexm(studylabel, "avg")

gen compliant = (compliance_est > 80)

gen rob = "low"
replace rob = "some" if regexm(study, "Zimmermann")
replace rob = "high" if regexm(study, "Haryanto") | regexm(study, "Sofyani") | regexm(study, "Keating")

gen 	pct_change_bll = (effect / bll_base_mean_n) * 100
lab var pct_change_bll "Percent change in BLL using effect and pooled (weighted) full sample baseline"

gen 	var_pct_change_bll = var_effect * (100 / bll_base_mean_n)^2
lab var var_pct_change_bll "Variance of percent change effect using pooled full sample baseline"

gen se_pct_change_bll = sqrt(var_pct_change_bll)

save "$output_dir/meta.dta", replace
