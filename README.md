# Iron and Calcium Supplementation for Reducing Blood Lead Levels

This repository hosts the replication package and supplementary review files
for the CGD working paper:

_Iron and Calcium Supplementation for Reducing Blood Lead Levels:
A Systematic Review and Meta-Analysis of Randomized Controlled Trials_

## Repository contents

- `replication/`
  - self-contained replication package for the manuscript-linked quantitative results
  - includes the cleaned extraction spreadsheet, Stata code, Python helpers,
    and generated manuscript outputs
- `risk_of_bias/filled_rob2_pdfs/`
  - filled RoB 2 assessment forms for the included randomized trials

## Replication package

The replication package is intentionally narrow. It is set up to reproduce only
the figures and scalar result files used in the manuscript.

From Stata, run:

```stata
do code/run_analysis.do
```

from within the `replication/` folder, or:

```stata
do run_analysis.do
```

from within `replication/code/`.

See `replication/README.txt` for package details, software requirements, and
expected outputs.
