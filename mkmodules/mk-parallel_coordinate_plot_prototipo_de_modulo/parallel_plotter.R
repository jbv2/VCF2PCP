## Load libraries
library("dplyr")
library("tidyr")
library("ggplot2")
library("svglite")
library("cowplot")

## Read args from command line
args = commandArgs(trailingOnly=TRUE)

## For debugging only
# args[1] <- "test/data/76g_1000GP-population_set4_M2_AF05_AN855_76g4PELs.maf25.evec.tmp" ## evec file
# args[2] <- "test/data/76g_1000GP-population_set4_M2_AF05_AN855_76g4PELs.maf25.eval" ## eval file
# args[3] <- "test/data/76g_1000GP-population_set4_M2_AF05_AN855_76g4PELs.maf25.parallel_plot.svg" ## eval file

## Load data
rawdata.df <- read.table(file = args[1],
                         header = F,
                         sep = "\t", stringsAsFactors = F)

## make a screeplot
##Load eval data data
raw_evaldata.df <- read.table(file = args[2],
                              header = F,
                              sep = "\t", stringsAsFactors = F)

## add a column with numbers
raw_evaldata.df$component_number <- as.numeric(rownames(raw_evaldata.df))

#filter evalues of 0 or less
raw_evaldata.df <- raw_evaldata.df %>% filter(V1 > 0)

## plot scree
scree.p <- ggplot(data = raw_evaldata.df, aes(x = component_number, y = V1, group = 1)) +
  geom_line( linetype = "dashed", color = "blue" , size = 1.2) +
  geom_point( shape=19, color = "red4", size = 3) +
  ggtitle(label = "screeplot") +
  scale_y_continuous(name = "eigenvalues") +
  scale_x_continuous(breaks = 1:max(raw_evaldata.df$component_number),
                     labels = 1:max(raw_evaldata.df$component_number)) +
  theme_classic() +
  theme(axis.text.x = element_text(angle = 90))

## process data for parallel coordinate plot
# remove first line, and remove last column
plotable.df <- rawdata.df[-1,]

## create a vector with the PC number required
pc_series <- paste0("PC", 1:(ncol(plotable.df)-2) )

##rename cols
colnames(plotable.df) <- c("sample", pc_series, "tag")

## from wide to long format
long_plotable.df <- gather(plotable.df,
                           component_number, value,
                           pc_series, factor_key=F)

##transform PC to factor and order for correct plotting
long_plotable.df$component_number <- factor(long_plotable.df$component_number,
                                               levels = pc_series)

## make parallel coordinate plot
## plot PCP
PCP.p <- ggplot(data = long_plotable.df,
       aes(x = component_number,
           y = value, group = sample, color = tag)) +
  geom_line() +
  ggtitle(label = "Parallel Coordinate Plot") +
  theme(legend.position = "none") +
  theme_classic() +
  theme(axis.text.x = element_text(angle = 90))

## generate PC 1 vs 2
PCA.p <- ggplot(data = plotable.df, aes(x = PC1, y = PC2)) +
  geom_point(aes(fill = tag),
             size = 1) +
  theme_bw() +
  theme(legend.position = "none")

## arrange grid
grid_below <- plot_grid(scree.p, PCA.p, nrow = 1)
grid.p <- plot_grid(PCP.p, grid_below, ncol = 1)

## save plot
ggsave(filename = args[3],
       plot = grid.p,
       device = "svg",
       width = 10, height = 7 , units = "in",
       dpi = 300)

##save the long dataframe
## create filename
o_file <- gsub(pattern = ".svg", replacement = ".tsv", args[3])
write.table(x = long_plotable.df, file = o_file,
            append = F, quote = F, sep = "\t", row.names = F, col.names = T)

##save the wide dataframe
## create filename
o_file <- gsub(pattern = ".svg", replacement = ".PCA_df.tsv", args[3])
write.table(x = plotable.df, file = o_file,
            append = F, quote = F, sep = "\t", row.names = F, col.names = T)