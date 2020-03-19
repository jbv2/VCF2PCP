## load libraries
library("dplyr")
library("ggplot2")
library("cowplot")

## Read args from command line
args = commandArgs(trailingOnly=TRUE)

## Uncomment For debugging only
## Comment for production mode only
# args[1] <- "test/data/sampleWGS.LD.maf_filtered.autosomal.2.admixture_plot.rds" ## an rds file file
# args[2] <- "test/data/sampleWGS.LD.maf_filtered.autosomal.3.admixture_plot.rds" ## another rds file
# args[3] <- "test/data/sampleWGS.LD.maf_filtered.autosomal.admixture_strip.svg" ## %.svg file

#get the last element -1 from args
last_rds_file <- length(args)-1
## vector of every args but the last one (the last one is the output file)
all_rds_files <- args[1:last_rds_file]

##get output file as the last element fro the args vecto
output_file <- args[length(args)]

## create empty list
my_plot_list <- list()

## plot every region
for (i in 1:length(all_rds_files)) {

  file_in_turn <- all_rds_files[i]
  message(paste("adding plot for", file_in_turn))
  
  ##load the plot
  # Restore it under a different name
  ## pass the plot to plotlist
  my_plot_list[[i]] <- readRDS(all_rds_files[i])

}

## make a grid with every K
grid.p <- plot_grid(plotlist = my_plot_list, ncol = 1)

##save plot as svg
ggsave(filename = output_file,
       plot = grid.p,
       device = "svg",
       width = 14.4,
       height = 28.8,
       units = "cm", dpi = 300)