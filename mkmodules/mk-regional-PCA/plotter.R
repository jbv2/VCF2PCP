## load libraries
library("dplyr")
library("ggplot2")
library("gtools")
library("cowplot")
library("svglite")

## Read args from command line
args = commandArgs(trailingOnly=TRUE)

## Uncomment For debugging only
## Comment for production mode only
# args[1] <- "test/data/76g_1000GP-population_set4_M2_AF05_AN855_76g4PELs.LD.maf_filtered.parallel_plot.PCA_df.tsv" ## %.parallel_plot.PCA_df.tsv file
# args[2] <- "test/data/76g_1000GP-population_set4_M2_AF05_AN855_76g4PELs.LD.maf_filtered.parallel_plot.significant_pc.tsv" ## %.parallel_plot.significant_pc.tsv file
# args[3] <- "test/data/76g_1000GP-population_set4_M2_AF05_AN855_76g4PELs.LD.maf_filtered.parallel_plot.tsv" ## %.parallel_plot.tsv file
# args[4] <- "test/reference/tag_data.tsv" ## $TAG_FILE file
# args[5] <- "test/data/76g_1000GP-population_set4_M2_AF05_AN855_76g4PELs.LD.maf_filtered.regionalPCA.svg" ## %.regionalPCA.svg file

## Passing args to named objects
pcadf_file <- args[1]
signifpc_file <- args[2]
pcpdf <- args[3]
tag_file <- args[4]
svg_file <- args[5]

# define color scale
cols <- c("Northern" = "blue3",
          "Central" = "red4",
          "Southern" = "green3",
          "NatPEL" = "purple")

## read data
pcp_data.df <- read.table(file = pcpdf,
                         header = T,
                         sep = "\t", stringsAsFactors = F)

## read tag data
tag_data.df <- read.table(file = tag_file,
                         header = T,
                         sep = "\t", stringsAsFactors = T)

## tag pc data by region
merged_data.df <- merge(x = pcp_data.df, y = tag_data.df[,c(1,3)],
                        by.x = "sample", by.y = "sample")

##transform PC to factor and order for correct plotting
pc_series <- merged_data.df$component_number %>% mixedsort() %>% unique()
merged_data.df$component_number <- factor(merged_data.df$component_number,
                                            levels = pc_series)

# ## store maxmin values
max_evec <- max(merged_data.df$value)
min_evec <- min(merged_data.df$value)

####
## PLOT MEAN PCP ----

### Calculate mean of each region
means_per_region.df <- merged_data.df %>%
  group_by(component_number, region) %>%
  summarise( mean_per_region = mean(value),
             max_per_region = max(value),
             min_per_region = min(value))

## plot means and ranges
means.p <- ggplot( data = means_per_region.df,
                   aes( x = component_number, y = mean_per_region,
                        group = region, color = region) ) +
  geom_line() +
  scale_y_continuous(limits = c(min_evec, max_evec)) +
  scale_colour_manual(values = cols) +
  ggtitle(label = "Parallel Coordinate Plot") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 90))

means_maxmin.p <- ggplot( data = means_per_region.df,
                          aes( x = component_number, y = mean_per_region,
                               group = region, color = region) ) +
  geom_line() +
  geom_line( aes( y = max_per_region),
             lty = "dashed", alpha = 0.3 ) +
  geom_line( aes( y = min_per_region),
             lty = "dashed", alpha = 0.3) +
  scale_y_continuous(limits = c(min_evec, max_evec)) +
  scale_colour_manual(values = cols) +
  ggtitle(label = "Parallel Coordinate Plot") +
  theme(axis.text.x = element_text(angle = 90))

## save PCP plots in long format
# put into grido
grid_pcp.p <- plot_grid(means.p, means_maxmin.p, ncol = 1)

## save plot
ggsave(filename = svg_file,
       plot = grid_pcp.p,
       device = "svg",
       width = 10, height = 14 , units = "in",
       dpi = 300)

####
## Automate PCA generation ----
## read data
pca_data.df <- read.table(file = pcadf_file,
                          header = T,
                          sep = "\t", stringsAsFactors = F)

## tag pc data by region
pca_merged_data.df <- merge(x = pca_data.df, y = tag_data.df[,c(1,3)],
                        by.x = "sample", by.y = "sample")

# as PC1 vs every other PC
# define main function
my_pca_function <- function( pca_data, pc_x, pc_y, x_name, y_name) {
  ##pc_x and pc_y must be a string with the colname to plot
pca_data %>%
  ggplot(aes(x=pc_x, y=pc_y, color = region)) +
  geom_point() +
  scale_x_continuous(name = x_name, limits = c(min_evec,max_evec)) +
  scale_y_continuous(name = y_name, limits = c(min_evec,max_evec)) +
  scale_colour_manual(values = cols)

}

##looping trough every PC after 1
# define starting PC col number
start_pc_coln <- 3
# define ending PC col number
end_pc_coln <- ncol(pca_merged_data.df) -2

for (i in start_pc_coln:end_pc_coln) {

  PC_x_name <- "PC1"
  PC_y_name <- colnames(pca_merged_data.df[i])
  message(paste("[debug-R] plotting PC1 vs", PC_y_name))

  ## generate plot
  my_plot.p <- my_pca_function(pca_data = pca_merged_data.df,
                  pc_x = pca_merged_data.df[ ,PC_x_name],
                  pc_y = pca_merged_data.df[ ,PC_y_name],
                  x_name = PC_x_name,
                  y_name = PC_y_name)

  ## generate dynamic out file name
  #generate extension
  new_ext <- paste0(".",PC_x_name,"vs",PC_y_name,".svg")

  out_file <- gsub(pattern = ".svg",
                 replacement = new_ext,
                  svg_file)

  ## save plot
  ggsave(filename = out_file,
         plot = my_plot.p,
         device = "svg",
         width = 7, height = 7 , units = "in",
         dpi = 300)
}
