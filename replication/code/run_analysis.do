version 18

capture noisily do "setup_paths.do"
if _rc {
	capture noisily do "code/setup_paths.do"
}
if _rc {
	di as error "Unable to load setup_paths.do."
	exit _rc
}

di as text "Running replication package from: $path"

python: import os; os.environ['SUPPLEMENT_PATH'] = r"$path"
python:
import glob
import os

base = os.environ["SUPPLEMENT_PATH"]
out = os.path.join(base, "output")
res = os.path.join(out, "results")
os.makedirs(out, exist_ok=True)
os.makedirs(res, exist_ok=True)

for pattern in (
    os.path.join(out, "*.png"),
    os.path.join(out, "*.pdf"),
    os.path.join(out, "*.csv"),
    os.path.join(out, "*.dta"),
    os.path.join(out, "*.log"),
    os.path.join(out, "tmp_*.png"),
    os.path.join(out, "_*.csv"),
    os.path.join(res, "*.tex"),
):
    for path in glob.glob(pattern):
        try:
            os.remove(path)
        except FileNotFoundError:
            pass
end

do "$code_dir/1.0 supplement meta cleaning.do"
do "$code_dir/1.1 supplement meta analysis.do"

python: import os; os.environ['SUPPLEMENT_PATH'] = r"$path"
python script "$code_dir/create_funnel_plots.py"

cap erase "$output_dir/meta.dta"
cap erase "$output_dir/_funnel_study_level.csv"

di as result "Replication outputs written to $output_dir"
