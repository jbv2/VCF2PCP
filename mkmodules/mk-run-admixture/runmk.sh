#!/usr/bin/env bash

## find every vcf file
#find: -L option to include symlinks
find -L . \
  -type f \
  -name "*.LD.maf_filtered.bed" \
  ! -name "*.autosomal.bed" \
  ! -name "*.converted.bed" \
| sed 's#.bed#.autosomal.log#' \
| xargs mk
