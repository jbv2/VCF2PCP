#!/usr/bin/env bash

## find every vcf file
#find: -L option to include symlinks
find -L . \
  -type f \
  -name "*.bed" \
  ! -name "*.autosomal.bed" \
| sed 's#.bed#.autosomal.bed#' \
| xargs mk
