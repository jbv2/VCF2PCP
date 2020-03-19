#!/usr/bin/env bash

## find every vcf file
#find: -L option to include symlinks
find -L . \
  -type f \
  -name "*.admixture_plot.rds" \
 | sed 's#.[0-9*].admixture_plot.rds#.admixture_strip.svg#' \
 | sort -u \
 | xargs mk
