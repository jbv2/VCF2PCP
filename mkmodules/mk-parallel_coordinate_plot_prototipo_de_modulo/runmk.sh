#!/bin/bash

find -L . \
  -type f \
  -name "*.evec" \
| sed "s#.evec#.parallel_plot.svg#" \
| xargs mk
