Replication Materials
=====================

Iron and Calcium Supplementation for Reducing Blood Lead Levels:
A Systematic Review and Meta-Analysis of Randomized Controlled Trials
Lee Crawfurd and Theodore Mitchell


OVERVIEW
--------

This folder is a self-contained replication package for the quantitative
results used in the CGD working paper draft. It does not require access to
the main project tree or the Overleaf repository.

The package contains:
  - the cleaned extraction spreadsheet
  - Stata code for data cleaning, meta-analysis, and manuscript-linked result export
  - Python helpers for the two figures used in main.tex
  - an output/ directory that is cleaned on each run so only final manuscript artifacts remain


CONTENTS
--------

data/
  supplement rct data.xlsx         - Data extraction spreadsheet with all included studies

code/
  run_analysis.do                  - Master script for the full replication run
  setup_paths.do                   - Detects the replication root and creates output folders
  clean var names.do               - Variable renaming from Excel column headers
  1.0 supplement meta cleaning.do  - Data cleaning and variable construction
  1.1 supplement meta analysis.do  - Meta-analysis, forest plots, result exports
  stitch_panels_rve.py             - Combines Stata-exported forest plot panels
  create_funnel_plots.py           - Builds funnel plots from generated study-level data

output/
  (created or overwritten when the scripts are run)

requirements.txt
  Python package requirements for the helper scripts


QUICK START
-----------

Option A: from the replication root in Stata
  1. cd to this replication folder
  2. run: do code/run_analysis.do

Option B: from the code/ folder in Stata
  1. cd to code/
  2. run: do run_analysis.do

No manual path editing should be required.


SOFTWARE REQUIREMENTS
---------------------

Stata 18 or later with:
  - built-in meta suite
  - Python integration enabled
  - robumeta      (install via: ssc install robumeta)
  - metan         (install via: ssc install metan)

Python 3.8+ with:
  - matplotlib
  - numpy

The Python dependencies can be installed with:
  pip install -r requirements.txt


WHAT THE MASTER SCRIPT DOES
---------------------------

run_analysis.do performs the following steps:
  1. detects the replication root and clears prior generated outputs
  2. imports and cleans the Excel extraction sheet
  3. runs the analyses needed for the manuscript
  4. exports only the scalar .tex files referenced by Overleaf/main.tex
  5. creates only the two figures referenced by Overleaf/main.tex
  6. removes temporary intermediate files after the run finishes


PRINCIPAL OUTPUTS
-----------------

Figures used in main.tex:
  output/forest_all_estimates.png
  output/funnel_plots.png

Scalar result files used in main.tex:
  output/results/*.tex
    The script writes exactly the 75 result files referenced by
    Overleaf/main.tex and no additional .tex outputs.
    Examples:
    - ca_all_b.tex
    - ca_lowrob_b.tex
    - fe_all_b.tex
    - ca_all_iv_b.tex
    - ca_highrob_b.tex
    - pct_rosado.tex


KEY RESULTS TO VERIFY
---------------------

RVE pooled estimates (robumeta, rho=0.8):
  Calcium (all 7 studies):        -1.33 ug/dL (95% CI: -2.87, +0.21)
  Calcium (4 lower-risk studies): -0.36 ug/dL (95% CI: -1.11, +0.38)
  Iron (all 4 studies):           -0.31 ug/dL (95% CI: -0.61, -0.02)

DL pooled estimates (study-level means):
  Calcium:                        -1.32 ug/dL (95% CI: -2.23, -0.41; I2=83%)
  Iron:                           -0.31 ug/dL (95% CI: -0.50, -0.12; I2=0%)


STUDY INCLUSION
---------------

11 studies included (18 effect-size observations):

Iron supplementation:
  - Rosado et al. (2006) - Mexico
  - Alatorre Rico et al. (2006) - Mexico
  - Zimmermann et al. (2006) - India
  - Bouhouch et al. (2016) - Morocco

Calcium supplementation:
  - Markowitz et al. (2004) - USA
  - Sargent et al. (1999) - USA
  - Ettinger et al. (2009) - Mexico
  - Hernandez-Avila et al. (2003) - Mexico
  - Keating et al. (2011) - Nigeria
  - Haryanto et al. (2015) - Indonesia
  - Sofyani & Lelo (2017) / Sofyani et al. (2020) - Indonesia

Excluded:
  - Wolf et al. (2003) - Case-control design, not RCT
  - Duplicate or republication rows with missing variance information


NOTES
-----

  - The package is intentionally narrow: it is set up to reproduce only the
    figures and scalar result files used in Overleaf/main.tex.
  - Temporary files used during the run are deleted at the end, so output/
    should contain only the two final figures plus output/results/.
  - If you want to inspect or extend the intermediate analysis data, comment
    out the cleanup lines at the end of code/run_analysis.do.
