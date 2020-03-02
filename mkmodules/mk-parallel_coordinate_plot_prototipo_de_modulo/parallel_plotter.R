## Load libraries
library("dplyr")
library("tidyr")
library("ggplot2")
library("svglite")
library("cowplot")
library("scales")

## Read args from command line
args = commandArgs(trailingOnly=TRUE)

## For debugging only
# args[1] <- "test/data/76g_1000GP-population_set4_M2_AF05_AN855_76g4PELs.LD.maf_filtered.evec.tmp" ## evec.tmp file
# args[2] <- "test/data/76g_1000GP-population_set4_M2_AF05_AN855_76g4PELs.LD.maf_filtered.eval" ## eval file
# args[3] <- "test/data/76g_1000GP-population_set4_M2_AF05_AN855_76g4PELs.LD.maf_filtered.tracy_widom_statistics" ## tracy_widom_statistics file
# args[4] <- "test/data/76g_1000GP-population_set4_M2_AF05_AN855_76g4PELs.LD.maf_filtered.number_of_snps" ## number_of_snps file
# args[5] <- "test/data/76g_1000GP-population_set4_M2_AF05_AN855_76g4PELs.LD.maf_filtered.parallel_plot.svg" ## .parallel_plot.svg file

## Passing args to named objects
evec_file <- args[1]
eval_file <- args[2]
tw_file <- args[3]
nsnps_files <- args[4]
svg_file <- args[5]

## Load data
rawdata.df <- read.table(file = evec_file,
                         header = F,
                         sep = "\t", stringsAsFactors = F)

## make a screeplot
##Load eval data data
raw_evaldata.df <- read.table(file = eval_file,
                              header = F,
                              sep = "\t", stringsAsFactors = F)

## add a column with numbers
raw_evaldata.df$component_number <- as.numeric(rownames(raw_evaldata.df))

#filter evalues of 0 or less
raw_evaldata.df <- raw_evaldata.df %>% filter(V1 > 0)

## identify last significant PC
## Should be able to load the table title to avoid missing the pvalue column due
# to changes in smartpca version
tw.df <- read.table(file = tw_file,
                   header = F,
                   sep = "\t", stringsAsFactors = F)

# Extract number of last significant PC
last_significant_pc <- tw.df %>%
  filter(V5 < 0.05) %>%
  select(V1) %>% max()

last_significant_pvalue <- tw.df %>%
  filter(V5 < 0.05) %>%
  select(V5) %>% max()

## create message to inform last significant PC and p-value
scree_title <- paste0("Scree plot - last significant PC is PC",
                     last_significant_pc,
                     "\nwith p-value =",
                     last_significant_pvalue)

## plot scree
scree.p <- ggplot(data = raw_evaldata.df, aes(x = component_number, y = V1, group = 1)) +
  geom_vline(xintercept = last_significant_pc,
             lty = "dashed", color = "orange4") +
  geom_line( color = "blue" , size = 0.5) +
  geom_point( shape=19, color = "red4", size = 1) +
  ggtitle(label = scree_title) +
  scale_y_continuous(name = "eigenvalues") +
  scale_x_continuous(breaks = 1:max(raw_evaldata.df$component_number),
                     labels = 1:max(raw_evaldata.df$component_number)) +
  theme_classic() +
  theme(axis.text.x = element_text(angle = 90, size = 5),
        plot.title = element_text(size = 10))

## calculate % of variance for each PC
significant_pc.df <- tw.df %>%
  filter(V5 < 0.05) %>%
  select(V1, V2)

significant_pc.df$V1 <- paste0("PC", significant_pc.df$V1)
significant_pc.df$explained_variance_proportion <- significant_pc.df$V2 / sum(significant_pc.df$V2)
# calculate as percentage
significant_pc.df$variance_proportion_percent <- percent(significant_pc.df$explained_variance_proportion)
significant_pc.df$cumproportion <- cumsum(significant_pc.df$explained_variance_proportion)

## plot variance proportions
variance.p <- ggplot(data = significant_pc.df,
       aes(x = V1,
           y = explained_variance_proportion,
           label = variance_proportion_percent) ) +
  geom_bar(stat = "identity", color = "black", fill = NA) +
  geom_text(size = 3,
            position = position_stack(vjust = 0.5)) +
  geom_line(aes(y = cumproportion, group = 1), color = "red4", alpha = 0.5) +
  geom_point(aes(y = cumproportion), color = "red4") +
  scale_y_continuous(limits = c(0,1)) +
  ggtitle(label = "Explained variance for each significant PC") +
  theme_bw() +
  theme(axis.title.x = element_blank())

## save significant pc dataframe
o_file <- gsub(pattern = ".svg", replacement = ".significant_pc.tsv", svg_file)
write.table(x = significant_pc.df, file = o_file,
            append = F, quote = F, sep = "\t", row.names = F, col.names = T)

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
## Create title with number of samples and snps
number_of_snps.df <- read.table(file = nsnps_files,
                                header = T,
                                sep = "\t", stringsAsFactors = F)
snps_used <- prettyNum(number_of_snps.df$number[1],
                       big.mark = ",")

samples_used <- prettyNum(number_of_snps.df$number[2],
                       big.mark = ",")

plot_title <- paste("Parallel Coordinate Plot - using",
                    snps_used,
                    " SNPs, and ",
                    samples_used,
                    " Samples")

## plot PCP
PCP.p <- ggplot(data = long_plotable.df,
       aes(x = component_number,
           y = value, group = sample, color = tag)) +
  geom_line() +
  ggtitle(label = plot_title) +
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
grid_below <- plot_grid(scree.p, variance.p,
                        nrow = 1, rel_widths = c(0.3,0.7))
grid.p <- plot_grid(PCP.p, grid_below, ncol = 1)

## save plot
ggsave(filename = svg_file,
       plot = grid.p,
       device = "svg",
       width = 10, height = 7 , units = "in",
       dpi = 300)

##save the long dataframe
## create filename
o_file <- gsub(pattern = ".svg", replacement = ".tsv", svg_file)
write.table(x = long_plotable.df, file = o_file,
            append = F, quote = F, sep = "\t", row.names = F, col.names = T)

##save the wide dataframe
## create filename
o_file <- gsub(pattern = ".svg", replacement = ".PCA_df.tsv", svg_file)
write.table(x = plotable.df, file = o_file,
            append = F, quote = F, sep = "\t", row.names = F, col.names = T)