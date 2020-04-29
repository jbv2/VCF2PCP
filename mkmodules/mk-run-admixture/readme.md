# mk-run-admixture
**Author(s):**

* Judith Ballesteros Villascán (judith.vballesteros@gmail.com)
* Israel Aguilar-Ordoñez (iaguilaror@gmail.com)

**Date:** March 2020 

---

## Module description:
Runs admixture with K 2:9 by default and gathers all logs.

*Outputs will be uncompressed.

## Module Dependencies:
admixture >
[Download and compile admixture](http://software.genetics.ucla.edu/admixture/)

### Input(s):

* A binary `.bed`.
* A `.bim` file.

Example line(s):

```
1       rs74512038      0       778597  T       C
1       rs553642122     0       790021  T       C
1       rs4951859       0       794299  G       C
...
```
* A `.fam` file.

Example line(s):

```
GROUP1 sample1        0       0       0       -9
GROUP1 sample2        0       0       0       -9
GROUP1 sample3        0       0       0       -9
...
```


### Outputs:

* A `.Q` file with ancestry fractions for each K.

Example line(s):

```
0.762595 0.237405
0.812681 0.187319
...
```
* A `.P` file with allele frequencies for each K.

Example line(s):

```
0.872056 0.999990
0.593289 0.999990
...
```
* A `.log` file that contains cv from all K.

## Module parameters:
Variable of threads for admixture and seed value:

* SEED_VALUE="43"
* ADMIXTURE_THREADS="8"

## Testing the module:

1. Test this module locally by running,
```
bash testmodule.sh
```

2. `[>>>] Module Test Successful` should be printed in the console...

## mk-run-admixture directory structure

````
mk-run-admixture /				    ## Module main directory
├── mkfile						   		## File in mk format, specifying the rules for building every result requested by runmk.sh
├── readme.md							## This document. General workflow description.
├── runmk.sh								## Script to print every file required by this module
├── test									## Test directory
│   ├── data								## Test data directory. Contains input files for testing.
└── testmodule.sh							## Script to test module functunality using test data
````
## References
* Purcell, S., Neale, B., Todd-Brown, K., Thomas, L., Ferreira, M. A., Bender, D., ... & Sham, P. C. (2007). PLINK: a tool set for whole-genome association and population-based linkage analyses. The American journal of human genetics, 81(3), 559-575.
* D.H. Alexander, J. Novembre, and K. Lange. Fast model-based estimation of ancestry in unrelated individuals. Genome Research, 19:1655–1664, 2009.