#!/bin/bash

find -L . \
  -type f \
  -name "*.evec" \
| sed "s#.evec#.kmeans.svg#" \
| xargs mk
