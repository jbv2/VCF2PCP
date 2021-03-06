#!/usr/bin/env bash
## This small script runs a module test with the sample data

###
## environment variable setting
export PLINK2="plink2"
export THREADS_PLINK="1"
###

echo "[>..] test running this module with data in test/data"
## Remove old test results, if any; then create test/reults dir
rm -rf test/results
mkdir -p test/results
echo "[>>.] results will be created in test/results"
## Execute runmk.sh, it will find the basic example in test/data
## Move results from test/data to test/results
## results files are *.bed, *.bim & *.fam without LD and maf filtered.
bash runmk.sh \
&& rm test/data/*.log \
&& mv test/data/*.autosomal.* test/results/ \
&& echo "[>>>] Module Test Successful"
