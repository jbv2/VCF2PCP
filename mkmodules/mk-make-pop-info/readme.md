# mk-make-pop-info
**Author(s):**

* Judith Ballesteros Villascán (judith.vballesteros@gmail.com)

**Date:** March 2020 

---

## Module description:
Makes popinfo file for plotting admixture results by using make_popinfo.R

* make_popinfo.R is a tool that takes columns of fam file and the groups of samples and makes popinfo file.

## Module Dependencies:
make_popinfo.R

### Input(s):

* A fam file.
Example line(s):

```
GROUP1 sample1        0       0       0       -9
GROUP1 sample2        0       0       0       -9
GROUP1 sample3        0       0       0       -9
...
```
* A .tsv file with information of the group of the sample that it belongs to.

Example line(s):
```
sample	pop	region
GROUP1:Sample1	Subgroup1	Region1
GROUP2:Sample2	Subgroup2	Region2
GROUP3:Sample3	Subgroup3	Region3
...
```

### Outputs:

* A `.popinfo.txt` file separated by tabs. 

Example line(s):

```
GROUP1 Sample1        Region1
GROUP1 Sample2        Region2
GROUP1 Sample3        Region3
...
```

## Module parameters:

TAG_FILE="./test/reference/tag_data.tsv"

## Testing the module:

1. Test this module locally by running,
```
bash testmodule.sh
```

2. `[>>>] Module Test Successful` should be printed in the console...

## mk-make-pop-info directory structure

````
mk-make-pop-info /				    ## Module main directory
├── mkfile						   		## File in mk format, specifying the rules for building every result requested by runmk.sh
├── readme.md							## This document. General workflow description.
├── runmk.sh								## Script to print every file required by this module
├── make_popinfo.R					 ## Script used in this module.
├── test									## Test directory
│   ├── data								## Test data directory. Contains input files for testing.
└── testmodule.sh							## Script to test module functunality using test data
````
