#!/bin/bash

find -L . \
  -type f \
  -name "*.parallel_plot.PCA_df.tsv" \
| sed "s#.parallel_plot.PCA_df.tsv#.regionalPCA.svg#" \
| xargs mk
