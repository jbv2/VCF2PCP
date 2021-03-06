#!/usr/bin/env bash

## find every vcf file
#find: -L option to include symlinks
find -L . \
  -type f \
  -name "*.bed" \
| sed 's#.bed#.bestsnps#' \
| xargs mk
