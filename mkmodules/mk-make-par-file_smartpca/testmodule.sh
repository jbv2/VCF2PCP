#!/usr/bin/env bash
## This small script runs a module test with the sample data

###
## environment variable setting
export PCA_NUMBER="20"
###

echo "[>..] test running this module with data in test/data"
## Remove old test results, if any; then create test/reults dir
rm -rf test/results
mkdir -p test/results
echo "[>>.] results will be created in test/results"
## Execute runmk.sh, it will find the basic example in test/data
## Move results from test/data to test/results
## results files are evec and evel files, bestsnps, and statics of PCs in *.tracy_widom_statistics and stdout.
bash runmk.sh \
&& mv test/data/*.ev* test/data/*.stdout test/data/*.tracy_widom_statistics test/data/*.bestsnps test/data/*.par test/results/ \
&& echo "[>>>] Module Test Successful"
