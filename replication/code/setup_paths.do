version 18

local cwd = subinstr("`c(pwd)'", "\", "/", .)
local root ""

if regexm("`cwd'", "/code/?$") {
	local root = regexr("`cwd'", "/code/?$", "")
}
else if fileexists("`cwd'/data/supplement rct data.xlsx") & fileexists("`cwd'/code/run_analysis.do") {
	local root "`cwd'"
}

if "`root'" == "" {
	di as error "Could not locate the replication root."
	di as error "Set the working directory to the replication folder or replication/code, then rerun."
	exit 198
}

global path "`root'"
global code_dir "$path/code"
global data_dir "$path/data"
global output_dir "$path/output"
global results_dir "$output_dir/results"

cap mkdir "$output_dir"
cap mkdir "$results_dir"
