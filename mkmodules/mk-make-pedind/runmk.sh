#!/usr/bin/env bash

## find every vcf file
#find: -L option to include symlinks
find -L . \
  -type f \
  -name "*.fam" \
| sed 's#.fam#.pedind#' \
| xargs mk
