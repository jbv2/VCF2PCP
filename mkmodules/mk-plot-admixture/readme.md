# mk-plot-admixture
**Author(s):**

* Judith Ballesteros Villascán (judith.vballesteros@gmail.com)
* Israel Aguilar-Ordoñez (iaguilaror@gmail.com)

**Date:** March 2020 

---

## Module description:
Plots all admixture results by using admixture_plotter.R

* admixture_plotter.R is a tool for plotting each admixture result.

## Module Dependencies:
admixture_plotter.R

### Input(s):

* A `.Q` file with ancestry fractions for each K.

* A `.log` file that contains cv from all K.

### Outputs:

* A `.rds` file with onformation of the plot for each K.

* A `.svg` for the plot of each K.

![Example of raw parallel_plot](../../dev_notes/k9.svg)

## Module parameters:
NONE

## Testing the module:

1. Test this module locally by running,
```
bash testmodule.sh
```

2. `[>>>] Module Test Successful` should be printed in the console...

## mk-plot-admixture directory structure

````
mk-plot-admixture /				    ## Module main directory
├── mkfile						   		## File in mk format, specifying the rules for building every result requested by runmk.sh
├── readme.md							## This document. General workflow description.
├── runmk.sh								## Script to print every file required by this module
├── parallel_plotter.R					 ## Script used in this module.
├── test									## Test directory
│   ├── data								## Test data directory. Contains input files for testing.
└── testmodule.sh							## Script to test module functunality using test data
````
## References
* Purcell, S., Neale, B., Todd-Brown, K., Thomas, L., Ferreira, M. A., Bender, D., ... & Sham, P. C. (2007). PLINK: a tool set for whole-genome association and population-based linkage analyses. The American journal of human genetics, 81(3), 559-575.
* D.H. Alexander, J. Novembre, and K. Lange. Fast model-based estimation of ancestry in unrelated individuals. Genome Research, 19:1655–1664, 2009.