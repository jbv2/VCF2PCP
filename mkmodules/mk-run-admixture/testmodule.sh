#!/usr/bin/env bash
## This small script runs a module test with the sample data

###
## environment variable setting
export SEED_VALUE="43"
export ADMIXTURE_THREADS="8"
###

echo "[>..] test running this module with data in test/data"
## Remove old test results, if any; then create test/reults dir
rm -rf test/results
mkdir -p test/results
echo "[>>.] results will be created in test/results"
## Execute runmk.sh, it will find the basic example in test/data
## Move results from test/data to test/results
## results files are *.bed, *.bim & *.fam without LD and maf filtered.
## Also, a vcf simplified and when there is no rsID, an ID has been assigned.
# (DEBUG) note: in iaguilar station it does not move the 7 and 8 .Q and .P files to test/results
bash runmk.sh \
&& mv test/data/*.log *.Q *.P test/results/ \
&& echo "[>>>] Module Test Successful"
