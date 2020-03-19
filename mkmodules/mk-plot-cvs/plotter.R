## load libraries
library("dplyr")
library("ggplot2")

## Read args from command line
args = commandArgs(trailingOnly=TRUE)

## Uncomment For debugging only
## Comment for production mode only
# args[1] <- "test/data/sampleWGS.LD.maf_filtered.autosomal.admixture.tsv" ## %.tsv values file
# args[2] <- "test/data/sampleWGS.LD.maf_filtered.autosomal.kvalue_.svg" ## %.svg file

## Passing args to named objects
 tsv_file <- args[1]
 svg_file <- args[2]

## Loading data
 cvs_values.df <- read.table(file = tsv_file,
   header = T,
   sep = "\t",
   stringsAsFactors = F)

## get the minimum CV value
## order dataframe ascending by CrossValidationError
lowest_row <- cvs_values.df %>%
   select(K, CrossValidationError) %>%
   arrange(CrossValidationError)

# Extract number of lowest cv
lowest_cv <- lowest_row[1,"CrossValidationError"]
lowest_k <- lowest_row[1,"K"]
 
 
## Make plot
 cvs.p <- ggplot(data = cvs_values.df,
                      aes(x = K,
                          y = CrossValidationError)) +
   ylab("Cross Validation Error") +
   xlab("K") +
   geom_line(color = "red4", alpha = 0.5)+
   geom_point(color = "red4")+
   scale_y_continuous(limits = c(0,1)) +
   ggtitle(label = paste("K",lowest_k,"had the lowest cv value =", lowest_cv))+
   theme(plot.title = element_text(hjust = 0.5, size = 15)) +
   theme_bw()

## save plot
ggsave(filename = svg_file,
       plot = cvs.p,
       device = "svg",
       width = 10, height = 7 , units = "in",
       dpi = 300)
