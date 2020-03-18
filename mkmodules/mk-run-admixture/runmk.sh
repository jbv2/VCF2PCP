#!/usr/bin/env bash

## find every vcf file
#find: -L option to include symlinks
find -L . \
  -type f \
  -name "*.autosomal.kvalue_.bed" \
| sed 's#.autosomal.kvalue_.bed#.admixture.kvalue_.log#' \
| xargs mk
