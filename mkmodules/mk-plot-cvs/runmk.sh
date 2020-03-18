#!/usr/bin/env bash

## find every vcf file
#find: -L option to include symlinks
find -L . \
  -type f \
  -name "*.log" \
| sed 's#.log#.svg#' \
| xargs mk
