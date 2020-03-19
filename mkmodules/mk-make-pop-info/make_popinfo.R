## load libraries
library("dplyr")
library("tidyr")

## Read args from command line
args = commandArgs(trailingOnly=TRUE)

## Uncomment For debugging only
## Comment for production mode only
# args[1] <- "test/data/sample22.LD.maf_filtered.fam" ## %.fam file
# args[2] <- "test/reference/tag_data.tsv" ## $POPULATIONS file
# args[3] <- "test/data/sample22.LD.maf_filtered.autosomal.popinfo.txt" ## %.clust file

## read files
fam_data.df <- read.table(file = args[1],
                          header = F,
                          sep = "\t", stringsAsFactors = F)

fam_columns_need.df <- fam_data.df %>% select(1, 2)

tag_data.df <- read.table(file = args[2],
                          header = T,
                          sep = "\t", stringsAsFactors = F) %>% separate(sample, c("TAG", "V1"), ":")

tag_columns_need.df <- tag_data.df %>% select(2, 4)

## merge files
merged.df <- left_join(x = fam_columns_need.df,
                       y = tag_columns_need.df,
                       by = c("V2" = "V1"))
colnames(merged.df) <- c("FAMID","ID","POP")

## save table
write.table(x = merged.df,
            file = args[3],
            append = F, quote = F,
            sep = "\t",
            row.names = F, col.names = F)
