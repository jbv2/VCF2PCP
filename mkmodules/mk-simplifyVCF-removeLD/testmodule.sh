#!/usr/bin/env bash
## This small script runs a module test with the sample data

###
## environment variable setting
export LD="0.8"
export WINDOW="2000"
export N_SITES="2000"
###

echo "[>..] test running this module with data in test/data"
## Remove old test results, if any; then create test/reults dir
rm -rf test/results
mkdir -p test/results
echo "[>>.] results will be created in test/results"*.vcf
## Execute runmk.sh, it will find the basic example in test/data
## Move results from test/data to test/results
## results files are *.noLD.vcf with variants passing the LD filter
bash runmk.sh \
&& mv test/data/*.noLD.vcf test/results/ \
&& echo "[>>>] Module Test Successful"
