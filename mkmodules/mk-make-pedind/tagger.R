## load libraries
library("dplyr")

## Read args from command line
args = commandArgs(trailingOnly=TRUE)

## Uncomment For debugging only
## Comment for production mode only
# args[1] <- "test/data/sample22.LD.maf_filtered.fam" ## %.fam file
# args[2] <- "test/reference/samples.txt" ## $TSV file
# args[3] <- "test/data/sample22.LD.maf_filtered.pedind" ## %.pedind file

## read files
fam_data.df <- read.table(file = args[1],
                          header = F,
                          sep = "\t", stringsAsFactors = F)

tag_data.df <- read.table(file = args[2],
                          header = F,
                          sep = " ", stringsAsFactors = F)

## merge files
merged.df <- left_join(x = fam_data.df,
                       y = tag_data.df,
                       by = c("V2" = "V1")) %>%
  select(-"V6")

## save table
write.table(x = merged.df,
            file = args[3],
            append = F, quote = F,
            sep = " ",
            row.names = F, col.names = F)
