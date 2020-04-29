# mk-plot-cvs
**Author(s):**

* Judith Ballesteros Villascán (judith.vballesteros@gmail.com)

**Date:** March 2020 

---

## Module description:
Plots cvs from admixture by using plotter.R

* plotter.R is a tool for plotting each CV from admixture results.

## Module Dependencies:
plotter.R

### Input(s):

* A `.log` file that contains cv from all K.

### Outputs:

* A `.tsv` of the value of CV for each K.

Example lines
```
K       CrossValidationError
2       0.58244
3       0.59174
...
```

* A `.svg` fwith the plot of CV for each K.

![Example of raw parallel_plot](../../dev_notes/cvs.svg)

## Module parameters:
NONE

## Testing the module:

1. Test this module locally by running,
```
bash testmodule.sh
```

2. `[>>>] Module Test Successful` should be printed in the console...

## mk-plot-cvs directory structure

````
mk-plot-cvs /				    ## Module main directory
├── mkfile						   		## File in mk format, specifying the rules for building every result requested by runmk.sh
├── readme.md							## This document. General workflow description.
├── runmk.sh								## Script to print every file required by this module
├── plotter.R					 ## Script used in this module.
├── test									## Test directory
│   ├── data								## Test data directory. Contains input files for testing.
└── testmodule.sh							## Script to test module functunality using test data
````
## References
* Purcell, S., Neale, B., Todd-Brown, K., Thomas, L., Ferreira, M. A., Bender, D., ... & Sham, P. C. (2007). PLINK: a tool set for whole-genome association and population-based linkage analyses. The American journal of human genetics, 81(3), 559-575.
* D.H. Alexander, J. Novembre, and K. Lange. Fast model-based estimation of ancestry in unrelated individuals. Genome Research, 19:1655–1664, 2009.