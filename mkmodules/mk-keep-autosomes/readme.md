# mk-keep-autosomes
**Author(s):**

* Judith Ballesteros Villascán (judith.vballesteros@gmail.com)

**Date:** March 2020 

---

## Module description:
Keeps only autosomal chromosomes for running admixture, as it is said in its documentation. (see references)

*Outputs will be uncompressed.

## Module Dependencies:
Plink2 >
[Download and compile plink2](https://www.cog-genomics.org/plink/2.0/)

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
* A `.pedind` file.
Example line(s):

```
GROUP1 sample1 0 0 0 Subgroup1
GROUP1 sample2 0 0 0 Subgroup2
GROUP1 sample3 0 0 0 Subgroup3
...
```

### Outputs:

* `.bed`, `.bim` and `.fam`files. Outputs will seem equal to inputs, but without sexual chromosomes.

## Module parameters:
Variable of threads for plink and plink version:

PLINK2="plink2"

THREADS_PLINK="1

## Testing the module:

1. Test this module locally by running,
```
bash testmodule.sh
```

2. `[>>>] Module Test Successful` should be printed in the console...

## mk-keep-autosomes directory structure

````
mk-keep-autosomes /				    ## Module main directory
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