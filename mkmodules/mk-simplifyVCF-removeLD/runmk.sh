#!/usr/bin/env bash

## find every vcf file
#find: -L option to include symlinks
find -L . \
  -type f \
  -name "*.vcf" \
  ! -name "*.noLD.vcf" \
| sed 's#.vcf#.noLD.vcf#' \
| xargs mk
