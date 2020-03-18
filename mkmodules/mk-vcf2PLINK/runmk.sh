#!/usr/bin/env bash

## find every vcf file
#find: -L option to include symlinks
find -L . \
  -type f \
  -name "*.noLD.vcf" \
| sed 's#.noLD.vcf#.LD.maf_filtered.bed#' \
| xargs mk
