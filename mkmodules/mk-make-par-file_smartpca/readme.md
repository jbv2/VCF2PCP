# mk-make-par-file_smartpca
**Author(s):**

* Judith Ballesteros Villascán (judith.vballesteros@gmail.com)
* Israel Aguilar-Ordoñez (iaguilaror@gmail.com)

**Date:** March 2020 

---

## Module description:
Makes par file to run smartpca, runs it and take best snps and Tracy-Widom statistics from stdout.

*Outputs will be uncompressed.

## Module Dependencies:
smartpca >
[Download and compile smartpca](https://data.broadinstitute.org/alkesgroup/EIGENSOFT/)

### Input(s):

* A binary `.bed` filtered by maf.
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

* A `.par` file.

Example line(s):

```
genotypename: ./test/data/sampleWGS.LD.maf_filtered.bed
snpname: ./test/data/sampleWGS.LD.maf_filtered.bim
indivname: ./test/data/sampleWGS.LD.maf_filtered.pedind
evecoutname: ./test/data/sampleWGS.LD.maf_filtered.evec
evaloutname: ./test/data/sampleWGS.LD.maf_filtered.eval
altnormstyle: NO
numoutlieriter: 0
numoutevec: 20
```

* A `.evec` file.

Example line(s):

```
#eigvals:     2.256     1.754     1.679     1.644     1.574     1.545     1.505     1.488     1.429     1.419     1.407     1.382     1.337     1.331     1.307     1.291     1.274     1.261     1.250     1.231 
GROUP1:sample1    -0.0767      0.0484     -0.1467     -0.1867     -0.1106     -0.0364     -0.0769     -0.0295     -0.0554     -0.1864     -0.0259     -0.1877     -0.0236     -0.1437     -0.0899     -0.0929     -0.0733     -0.0639     -0.2730     -0.0132            Sobgroup1
...
```
* A `.eval` file.

Example line(s):

```
2.256303
1.753770
...
```
* A `.smartpca.stdout` file.

* A `.bestsnps` file.

Example line(s):

```
Description	PC_number	Snp_id	Chromosome	Position	Weight
eigbestsnp	1	rs573819936	7	831033	5.392
...
```

* A `.tracy_widom_statistics` file.

Example line(s):

```
##Tracy-Widom	statistics:	rows:	80	cols:	8228
#N	eigenvalue	difference	twstat	p-value	effect.	n
1	2.256303	NA	17.915	7.633e-24	706.669
...
```

## Module parameters:
Variable of pca_number:

PCA_NUMBER="20"

## Testing the module:

1. Test this module locally by running,
```
bash testmodule.sh
```

2. `[>>>] Module Test Successful` should be printed in the console...

## mk-make-par-file_smartpca directory structure

````
mk-make-par-file_smartpca /				    ## Module main directory
├── mkfile						   		## File in mk format, specifying the rules for building every result requested by runmk.sh
├── readme.md							## This document. General workflow description.
├── runmk.sh								## Script to print every file required by this module
├── test									## Test directory
│   ├── data								## Test data directory. Contains input files for testing.
└── testmodule.sh							## Script to test module functunality using test data
````
## References
* Price, Alkes L., et al. "Principal components analysis corrects for stratification in genome-wide association studies." Nature genetics 38.8 (2006): 904-909.
* Patterson, Nick, Alkes L. Price, and David Reich. "Population structure and eigenanalysis." PLoS genetics 2.12 (2006): e190.