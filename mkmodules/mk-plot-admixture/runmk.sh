#!/usr/bin/env bash

## find every vcf file
#find: -L option to include symlinks
find -L . \
  -type f \
  -name "*.Q" \
| sed 's#.Q#.admixture_plot.svg#' \
| xargs mk
