## load libraries
library("dplyr")
library("tidyr")
library("ggplot2")
library("svglite")
library("cowplot")
library("ggsci")

## Read args from command line
args = commandArgs(trailingOnly=TRUE)

## Uncomment For debugging only
## Comment for production mode only
# args[1] <- "test/data/sampleWGS.LD.maf_filtered.autosomal.4.proportions.tmp" ## %.proportions.tmp file
# args[2] <- "4" ## $stem2 which is the number of K in the filename at args[1]
# args[3] <- "test/data/sampleWGS.LD.maf_filtered.autosomal.4.admixture_plot.svg" ## %.svg file

## Passing args to named objects
proportions_file <- args[1]
k_value <- args[2]
output_file <- args[3]

## Read data
data.df <- read.table(file = proportions_file, header = F, sep = "\t", stringsAsFactors = F)


## generate the colname vector

#dynamically set of numbered groups
vector_of_groups <- paste0("group", 4:ncol(data.df) - 3)
names_for_cols <- c("plink_code","sample","region",vector_of_groups)
colnames(data.df) <- names_for_cols

## pass from wide to long data
long.df <- data.df %>% pivot_longer(cols = 4:ncol(data.df),
                                    names_to = "group_k",
                                    values_to = "proportion")

## Define a custom function for plotting
myplotting_function <- function(data, kval, region_name) {
  
  ggplot(data, aes(x = sample, y = proportion)) +
    geom_col(aes(fill = group_k)) +
    scale_y_continuous(name = "Proportion", 
                       breaks = seq(0,1,by = 0.2),
                       labels = paste0(seq(0,1,by = 0.2) * 100, "%"),
                       expand = c(0, 0)) +
    ggtitle(label = region_name) +
    # scale_fill_discrete(name = paste("K=",kval)) +
    scale_fill_npg(name = paste("K=",kval)) +
    theme_bw() +
    theme(
      text = element_text(size = 5),
      axis.text.x = element_blank(),
      axis.ticks.x = element_blank(),
      axis.text.y = element_text(size = 5),
      axis.title.x = element_blank(),
      panel.background = element_blank(),
      legend.key.size = unit(0.3,"cm"),
      legend.box.margin=margin(-10,-10,-10,-10))

}

## define a vector with all available regions
allregions <- unique(long.df$region)

##create an empty list
my_plot_list <- list()

## plot every region
for (i in 1:length(allregions)) {
  region_in_turn <- allregions[i]
  # Debug message
  message(paste("[..] plotting", region_in_turn))
  #filter data for required region
  myplot.p <- long.df %>% 
        filter(region == region_in_turn) %>%
        myplotting_function(kval = k_value, region_name = region_in_turn)
  
  ## modify every panel but the last
  if (i != length(allregions)) {
    myplot.p <- myplot.p + theme(legend.position = "none",
                                 plot.margin = unit(c(0.1,0,0,0), "cm"))
  }
  
  ## ## modify every panel but the first
  if (i != 1) {
    myplot.p <- myplot.p + theme(axis.text.y = element_blank(),
                                 axis.title.y = element_blank(),
                                 axis.ticks.y = element_blank(),
                                 plot.margin = unit(c(0.1,0,0,0), "cm")
                            )
  }
  
  ## modify the last panel
  if (i == length(allregions)) {
    myplot.p <- myplot.p + theme(plot.margin = unit(c(0.1,0.5,0,0), "cm")
    )
  }
  
  ## pass the plot to plotlist
  my_plot_list[[i]] <- myplot.p
}

## plot every plot together
allregions.p <- plot_grid(plotlist = my_plot_list, nrow = 1)

##save plot as svg
ggsave(filename = output_file,
       plot = allregions.p,
       device = "svg",
       width = 14.4,
       height = 7.2,
       units = "cm", dpi = 300)

## save plot object for use in another R session
# generate a name for the second output file
second_output <- gsub(pattern = ".admixture_plot.svg",
                      replacement = ".admixture_plot.rds",
                      x = output_file)

# Save an object to a file
saveRDS(allregions.p, file = second_output)
