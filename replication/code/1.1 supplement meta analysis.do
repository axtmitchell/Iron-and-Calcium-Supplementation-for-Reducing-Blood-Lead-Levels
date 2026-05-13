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

use "$output_dir/meta.dta", clear

replace study = " - " + study

*------------------------------------------------------------------------------------------------------------------------------------*
*		 Pooled estimates used in main forest plot
*------------------------------------------------------------------------------------------------------------------------------------*

qui robumeta effect if Type=="Calcium" & nosubsamples==1 & rob!="high", ///
	study(study_id) variance(var_effect) weighttype(random) rho(0.8)
local _b  = _b[_cons]
local _se = _se[_cons]
local _df = e(dfs)[1,1]
local rve_calr    = `_b'
local rve_calr_lo = `_b' - invttail(`_df', 0.025)*`_se'
local rve_calr_hi = `_b' + invttail(`_df', 0.025)*`_se'

qui robumeta effect if Type=="Calcium" & nosubsamples==1 & rob=="high", ///
	study(study_id) variance(var_effect) weighttype(random) rho(0.8)
local _b  = _b[_cons]
local _se = _se[_cons]
local _df = e(dfs)[1,1]
local rve_cahr    = `_b'
local rve_cahr_lo = `_b' - invttail(`_df', 0.025)*`_se'
local rve_cahr_hi = `_b' + invttail(`_df', 0.025)*`_se'

qui robumeta effect if Type=="Iron" & nosubsamples==1, ///
	study(study_id) variance(var_effect) weighttype(random) rho(0.8)
local _b  = _b[_cons]
local _se = _se[_cons]
local _df = e(dfs)[1,1]
local rve_fe    = `_b'
local rve_fe_lo = `_b' - invttail(`_df', 0.025)*`_se'
local rve_fe_hi = `_b' + invttail(`_df', 0.025)*`_se'

*------------------------------------------------------------------------------------------------------------------------------------*
*		 Main manuscript forest plot only
*------------------------------------------------------------------------------------------------------------------------------------*

preserve
	keep if nosubsamples == 1
	gen group = "Iron" if Type == "Iron"
	replace group = "Calcium (low RoB)" if Type == "Calcium" & rob != "high"
	replace group = "Calcium (high RoB)" if Type == "Calcium" & rob == "high"

	rename studylabel _lbl
	replace _lbl = subinstr(_lbl, ", iron, unadjusted", ", unadjusted", .)
	replace _lbl = subinstr(_lbl, ", iron", "", .)
	replace _lbl = subinstr(_lbl, ", 3m full sample", ", 3 months", .)
	replace _lbl = subinstr(_lbl, ", 6m full sample", ", 6 months", .)
	replace _lbl = subinstr(_lbl, ", full sample, T2", ", 2nd trimester", .)
	replace _lbl = subinstr(_lbl, ", full sample, T3", ", 3rd trimester", .)
	replace _lbl = subinstr(_lbl, ", 3months", ", 3 months", .)
	replace _lbl = subinstr(_lbl, ", 6months", ", 6 months", .)
	replace _lbl = subinstr(_lbl, ", 4m", ", 4 months", .)
	replace _lbl = subinstr(_lbl, ", 9m", ", 9 months", .)
	replace _lbl = subinstr(_lbl, ", 14wks", ", 14 weeks", .)
	replace _lbl = subinstr(_lbl, ", 30wks", ", 30 weeks", .)
	replace _lbl = subinstr(_lbl, ", sofyani 2020 dropped", "", .)
	replace _lbl = " - " + _lbl
	meta set effect se_effect, studylabel(_lbl)

	local xopts xscale(range(-9 3)) xlabel(-9(3)3, format(%3.0f))

	meta forestplot if group == "Calcium (low RoB)", ///
		title("Calcium: settings with good prior nutrition", size(large) position(11)) ///
		xline(0, lcolor(gs8)) markeropts(mcolor("11 76 91")) ///
		nooverall customoverall(`rve_calr' `rve_calr_lo' `rve_calr_hi', ///
			label("RVE pooled ({&rho}=0.8)") mcolor("255 181 44")) ///
		noohetstats noohomtest noosigtest nonotes ///
		graphregion(color(white)) `xopts'
	graph export "$output_dir/tmp_panel_allest_calr.png", replace width(2000)

	meta forestplot if group == "Calcium (high RoB)", ///
		title("Calcium: settings with poor prior nutrition", size(large) position(11)) ///
		xline(0, lcolor(gs8)) markeropts(mcolor("11 76 91")) ///
		nooverall customoverall(`rve_cahr' `rve_cahr_lo' `rve_cahr_hi', ///
			label("RVE pooled ({&rho}=0.8)") mcolor("255 181 44")) ///
		noohetstats noohomtest noosigtest nonotes ///
		graphregion(color(white)) `xopts'
	graph export "$output_dir/tmp_panel_allest_cahr.png", replace width(2000)

	meta forestplot if group == "Iron", ///
		title("Iron", size(large) position(11)) ///
		xline(0, lcolor(gs8)) markeropts(mcolor("11 76 91")) ///
		nooverall customoverall(`rve_fe' `rve_fe_lo' `rve_fe_hi', ///
			label("RVE pooled ({&rho}=0.8)") mcolor("255 181 44")) ///
		noohetstats noohomtest noosigtest nonotes ///
		graphregion(color(white)) `xopts'
	graph export "$output_dir/tmp_panel_allest_fe.png", replace width(2000)
restore

python: import os; os.environ['SUPPLEMENT_PATH'] = r"$path"
python script "$code_dir/stitch_panels_rve.py"

cap erase "$output_dir/tmp_panel_allest_calr.png"
cap erase "$output_dir/tmp_panel_allest_cahr.png"
cap erase "$output_dir/tmp_panel_allest_fe.png"

*------------------------------------------------------------------------------------------------------------------------------------*
*		 Derived quantities for manuscript-linked scalar results
*------------------------------------------------------------------------------------------------------------------------------------*

gen 	effect_iv = effect / (compliance_est / 100)
gen 	se_effect_iv = se_effect / (compliance_est / 100)
gen 	var_effect_iv = se_effect_iv^2

*------------------------------------------------------------------------------------------------------------------------------------*
*    Temporary study-level file for funnel plot only
*------------------------------------------------------------------------------------------------------------------------------------*

preserve
	collapse (mean) effect se_effect bll_base_mean_n compliance_est ///
		(firstnm) Type Country rob, by(study)
	replace study = subinstr(study, " - ", "", 1)
	export delimited using "$output_dir/_funnel_study_level.csv", replace
restore

*------------------------------------------------------------------------------------------------------------------------------------*
*    Export manuscript-linked scalar results referenced in main.tex
*------------------------------------------------------------------------------------------------------------------------------------*

cap mkdir "$results_dir"
local R "$results_dir"

cap mata: mata drop writeres()
mata:
void writeres(string scalar fpath, real scalar val, real scalar showplus) {
    real scalar fh, av
    string scalar prefix, num
    av  = abs(val)
    num = strtrim(strofreal(av, "%9.2f"))
    if      (val < 0)   prefix = "$-$"
    else if (showplus)  prefix = "$+$"
    else                prefix = ""
    (void) unlink(fpath)
    fh = fopen(fpath, "w")
    fwrite(fh, prefix + num)
    fclose(fh)
}
end

qui robumeta effect if Type=="Calcium" & nosubsamples==1, ///
	study(study_id) variance(var_effect) weighttype(random) rho(0.8)
local b  = _b[_cons]
local se = _se[_cons]
local df = e(dfs)[1,1]
local cil = `b' - invttail(`df', 0.025)*`se'
local cih = `b' + invttail(`df', 0.025)*`se'
local p_ca = round(2*ttail(`df', abs(`b'/`se')), 0.001)
mata: writeres("`R'/ca_all_b.tex", `b', 0)
mata: writeres("`R'/ca_all_b_abs.tex", abs(`b'), 0)
scalar _bca = abs(`b')
mata: writeres("`R'/ca_all_cil.tex", `cil', 1)
mata: writeres("`R'/ca_all_cih.tex", `cih', 1)

qui robumeta effect if Type=="Calcium" & nosubsamples==1 & rob!="high", ///
	study(study_id) variance(var_effect) weighttype(random) rho(0.8)
local b  = _b[_cons]
local se = _se[_cons]
local df = e(dfs)[1,1]
local cil = `b' - invttail(`df', 0.025)*`se'
local cih = `b' + invttail(`df', 0.025)*`se'
local p_calr = round(2*ttail(`df', abs(`b'/`se')), 0.001)
mata: writeres("`R'/ca_lowrob_b.tex", `b', 0)
mata: writeres("`R'/ca_lowrob_b_abs.tex", abs(`b'), 0)
scalar _blr = abs(`b')
mata: writeres("`R'/ca_lowrob_cil.tex", `cil', 1)
mata: writeres("`R'/ca_lowrob_cih.tex", `cih', 1)

qui robumeta effect if Type=="Calcium" & nosubsamples==1 & rob=="high", ///
	study(study_id) variance(var_effect) weighttype(random) rho(0.8)
local b  = _b[_cons]
local se = _se[_cons]
local df = e(dfs)[1,1]
local cil = `b' - invttail(`df', 0.025)*`se'
local cih = `b' + invttail(`df', 0.025)*`se'
mata: writeres("`R'/ca_highrob_b.tex", `b', 0)
mata: writeres("`R'/ca_highrob_cil.tex", `cil', 1)
mata: writeres("`R'/ca_highrob_cih.tex", `cih', 1)

qui robumeta effect if Type=="Iron" & nosubsamples==1, ///
	study(study_id) variance(var_effect) weighttype(random) rho(0.8)
local b  = _b[_cons]
local se = _se[_cons]
local df = e(dfs)[1,1]
local cil = `b' - invttail(`df', 0.025)*`se'
local cih = `b' + invttail(`df', 0.025)*`se'
local p_fe = round(2*ttail(`df', abs(`b'/`se')), 0.001)
mata: writeres("`R'/fe_all_b.tex", `b', 0)
scalar _bfe = abs(`b')
mata: writeres("`R'/fe_all_cil.tex", `cil', 1)
mata: writeres("`R'/fe_all_cih.tex", `cih', 1)

qui robumeta effect_iv if Type=="Calcium" & nosubsamples==1, ///
	study(study_id) variance(var_effect_iv) weighttype(random) rho(0.8)
local b  = _b[_cons]
local se = _se[_cons]
local df = e(dfs)[1,1]
local cil = `b' - invttail(`df', 0.025)*`se'
local cih = `b' + invttail(`df', 0.025)*`se'
mata: writeres("`R'/ca_all_iv_b.tex", `b', 0)
mata: writeres("`R'/ca_all_iv_cil.tex", `cil', 1)
mata: writeres("`R'/ca_all_iv_cih.tex", `cih', 1)

qui robumeta effect_iv if Type=="Calcium" & nosubsamples==1 & rob!="high", ///
	study(study_id) variance(var_effect_iv) weighttype(random) rho(0.8)
local b  = _b[_cons]
local se = _se[_cons]
local df = e(dfs)[1,1]
local cil = `b' - invttail(`df', 0.025)*`se'
local cih = `b' + invttail(`df', 0.025)*`se'
mata: writeres("`R'/ca_lowrob_iv_b.tex", `b', 0)
mata: writeres("`R'/ca_lowrob_iv_cil.tex", `cil', 1)
mata: writeres("`R'/ca_lowrob_iv_cih.tex", `cih', 1)

qui robumeta effect_iv if Type=="Calcium" & nosubsamples==1 & rob=="high", ///
	study(study_id) variance(var_effect_iv) weighttype(random) rho(0.8)
local b  = _b[_cons]
local se = _se[_cons]
local df = e(dfs)[1,1]
local cil = `b' - invttail(`df', 0.025)*`se'
local cih = `b' + invttail(`df', 0.025)*`se'
mata: writeres("`R'/ca_highrob_iv_b.tex", `b', 0)
mata: writeres("`R'/ca_highrob_iv_cil.tex", `cil', 1)
mata: writeres("`R'/ca_highrob_iv_cih.tex", `cih', 1)

qui robumeta effect_iv if Type=="Iron" & nosubsamples==1, ///
	study(study_id) variance(var_effect_iv) weighttype(random) rho(0.8)
local b  = _b[_cons]
local se = _se[_cons]
local df = e(dfs)[1,1]
local cil = `b' - invttail(`df', 0.025)*`se'
local cih = `b' + invttail(`df', 0.025)*`se'
mata: writeres("`R'/fe_all_iv_b.tex", `b', 0)
mata: writeres("`R'/fe_all_iv_cil.tex", `cil', 1)
mata: writeres("`R'/fe_all_iv_cih.tex", `cih', 1)

cap file close _f
file open _f using "`R'/ca_all_p.tex", write replace
file write _f "`p_ca'"
file close _f
file open _f using "`R'/ca_lowrob_p.tex", write replace
file write _f "`p_calr'"
file close _f
file open _f using "`R'/fe_all_p.tex", write replace
file write _f "`p_fe'"
file close _f

preserve
	collapse effect se_effect nosubsamples (firstnm) rob, by(Type study)

	qui metan effect se_effect if nosubsamples==1 & Type=="Calcium", random nograph
	local isq_ca  = string(round(r(i_sq), 1))
	file open _f using "`R'/ca_all_isq.tex", write replace
	file write _f "`isq_ca'"
	file close _f

	qui metan effect se_effect if nosubsamples==1 & Type=="Calcium" & rob!="high", random nograph
	local isq_calr = string(round(r(i_sq), 1))
	file open _f using "`R'/ca_lowrob_isq.tex", write replace
	file write _f "`isq_calr'"
	file close _f

	qui metan effect se_effect if nosubsamples==1 & Type=="Calcium" & rob=="high", random nograph
	local isq_cahr = string(round(r(i_sq), 1))
	file open _f using "`R'/ca_highrob_isq.tex", write replace
	file write _f "`isq_cahr'"
	file close _f

	qui metan effect se_effect if nosubsamples==1 & Type=="Iron", random nograph
	local isq_fe  = string(round(r(i_sq), 1))
	file open _f using "`R'/fe_all_isq.tex", write replace
	file write _f "`isq_fe'"
	file close _f

	qui sum effect if regexm(study, "Keating") & Type=="Calcium"
	mata: writeres("`R'/mean_keating.tex", `=r(mean)', 0)
	qui sum effect if regexm(study, "Haryanto") & Type=="Calcium"
	mata: writeres("`R'/mean_haryanto.tex", `=r(mean)', 0)
	qui sum effect if regexm(study, "Sofyani") & Type=="Calcium"
	mata: writeres("`R'/mean_sofyani.tex", `=r(mean)', 0)

	qui sum effect if nosubsamples==1 & Type=="Calcium"
	local _min_ca_abs = abs(r(max))
	local _max_ca_abs = abs(r(min))
	mata: writeres("`R'/ca_min_mean.tex", `_min_ca_abs', 0)
	mata: writeres("`R'/ca_max_mean.tex", `_max_ca_abs', 0)
restore

cap mata: mata drop writeres1dp()
mata:
void writeres1dp(string scalar fpath, real scalar val) {
	real scalar fh
	string scalar num
	num = strtrim(strofreal(abs(val), "%9.1f"))
	(void) unlink(fpath)
	fh = fopen(fpath, "w")
	fwrite(fh, num)
	fclose(fh)
}
end
mata: writeres1dp("`R'/ca_all_b_1dp.tex", st_numscalar("_bca"))
mata: writeres1dp("`R'/ca_lowrob_b_1dp.tex", st_numscalar("_blr"))
mata: writeres1dp("`R'/fe_all_b_1dp.tex", st_numscalar("_bfe"))

local _bfe_10ths = round(`=scalar(_bfe)'*10, 1)
local _bca_10ths = round(`=scalar(_bca)'*10, 1)
local _pct_fe : display %5.0f `_bfe_10ths'/10/5*100
local _pct_ca : display %5.0f `_bca_10ths'/10/5*100
local _pct_fe = strtrim("`_pct_fe'")
local _pct_ca = strtrim("`_pct_ca'")
file open _f using "`R'/fe_pct.tex", write replace
file write _f "`_pct_fe'"
file close _f
file open _f using "`R'/ca_pct.tex", write replace
file write _f "`_pct_ca'"
file close _f

local _iq_min_val = round(`_bfe_10ths'*0.5, 1)/10
local _iq_max_val = round(`_bca_10ths'*1.0, 1)/10
local _iq_min : display %4.1f `_iq_min_val'
local _iq_max : display %4.1f `_iq_max_val'
local _iq_min = strtrim("`_iq_min'")
local _iq_max = strtrim("`_iq_max'")
file open _f using "`R'/iq_min.tex", write replace
file write _f "`_iq_min'"
file close _f
file open _f using "`R'/iq_max.tex", write replace
file write _f "`_iq_max'"
file close _f

qui robumeta pct_change_bll if Type=="Calcium" & nosubsamples==1, ///
    study(study_id) variance(var_pct_change_bll) weighttype(random) rho(0.8)
local b  = _b[_cons]
local se = _se[_cons]
local df = e(dfs)[1,1]
local cil = `b' - invttail(`df', 0.025)*`se'
local cih = `b' + invttail(`df', 0.025)*`se'
local p_ca_pct = round(2*ttail(`df', abs(`b'/`se')), 0.001)
mata: writeres("`R'/ca_all_pct_b.tex", `b', 0)
mata: writeres("`R'/ca_all_pct_cil.tex", `cil', 1)
mata: writeres("`R'/ca_all_pct_cih.tex", `cih', 1)
cap file close _f
file open _f using "`R'/ca_all_pct_p.tex", write replace
file write _f "`p_ca_pct'"
file close _f

qui robumeta pct_change_bll if Type=="Iron" & nosubsamples==1, ///
    study(study_id) variance(var_pct_change_bll) weighttype(random) rho(0.8)
local b  = _b[_cons]
local se = _se[_cons]
local df = e(dfs)[1,1]
local cil = `b' - invttail(`df', 0.025)*`se'
local cih = `b' + invttail(`df', 0.025)*`se'
local p_fe_pct = round(2*ttail(`df', abs(`b'/`se')), 0.001)
mata: writeres("`R'/fe_all_pct_b.tex", `b', 0)
mata: writeres("`R'/fe_all_pct_cil.tex", `cil', 1)
mata: writeres("`R'/fe_all_pct_cih.tex", `cih', 1)
cap file close _f
file open _f using "`R'/fe_all_pct_p.tex", write replace
file write _f "`p_fe_pct'"
file close _f

cap mata: mata drop writeres_pct()
mata:
void writeres_pct(string scalar fpath, real scalar val) {
    real scalar fh
    string scalar prefix, num
    num    = strtrim(strofreal(abs(val), "%9.1f"))
    prefix = (val < 0) ? "$-$" : ""
    (void) unlink(fpath)
    fh = fopen(fpath, "w")
    fwrite(fh, prefix + num)
    fclose(fh)
}
end

preserve
    collapse (mean) bll_base_mean_n pct_change_bll effect nosubsamples ///
             (firstnm) Type, by(study)
    keep if nosubsamples == 1

    local studies   "rosado alatorre zimmermann bouhouch markowitz sargent ettinger hernavila keating haryanto sofyani"
    local patterns  "Rosado Rico Zimmermann Bouhouch Markowitz Sargent Ettinger Hern Keating Haryanto Sofyani"

    local n : word count `studies'
    forval i = 1/`n' {
        local key : word `i' of `studies'
        local pat : word `i' of `patterns'
        qui sum pct_change_bll if regexm(study, "`pat'"), meanonly
        if r(N) > 0 mata: writeres_pct("`R'/pct_`key'.tex", `r(mean)')
        qui sum bll_base_mean_n if regexm(study, "`pat'"), meanonly
        if r(N) > 0 mata: writeres1dp("`R'/bll_base_`key'.tex", `r(mean)')
    }
restore

di as result "Results written to `R'/"
