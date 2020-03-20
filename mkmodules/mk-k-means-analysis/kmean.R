## Load libraries
library("dplyr")
library("purrr")
library("cluster")
library("tidyr")
library("ggplot2")
library("svglite")
library("cowplot")

## Read args from command line
args = commandArgs(trailingOnly=TRUE)

## For debugging only
# args[1] <- "test/data/sampleWGS.LD.maf_filtered.evec.tmp" ## evec.tmp file
# args[2] <- "test/data/sampleWGS.LD.maf_filtered.tracy_widom_statistics"## .tracy_widom_statistics file file
# args[3] <- "test/data/sampleWGS.LD.maf_filtered.number_of_snps" ## .number_of_snps file
# args[4] <- "test/data/sampleWGS.LD.maf_filtered.kmeans.svg" ## .kmeans.svg file

## pass to named objects
evec_file <- args[1]
tw_file <- args[2]
number_of_snps_file <- args[3]
output_file <- args[4]

## identify last significant PC
## Should be able to load the table title to avoid missing the pvalue column due
# to changes in smartpca version
tw.df <- read.table(file = tw_file,
                    header = F,
                    sep = "\t", stringsAsFactors = F)

# Extract number of last significant PC
last_significant_pc <- tw.df %>%
  filter(V5 < 0.01) %>%
  select(V1) %>% max()

## read evec data
evec.df <- read.table(file = evec_file,
                      header = F, sep = "\t",
                      stringsAsFactors = F)

## get only data for sample and PC up to the last significant PC, and the last column with region data
evec.df <- evec.df %>% 
  select(c(1:(1+last_significant_pc), ncol(evec.df) ))

## extract the eigenval data
eigenvals <- evec.df %>% slice(1) %>% select(-c(1,ncol(evec.df)))

# reweight every eigenval
eigenrewight <- eigenvals * 100 /sum(eigenvals)

## extract the PC data
pca.df <- evec.df[-1,-1]

## create the base dataframe of reweighted PC values
weightpca.df <- as.data.frame(pca.df[,1] * as.numeric(eigenrewight[1]))

#calculate last PC col
lastpc_col <- ncol(pca.df) - 1
## loop throug the rest of the PCA columns
for (i in 2:lastpc_col){
  weightpca.df <- cbind(weightpca.df,
                        pca.df[,i] * as.numeric(eigenrewight[i]))
}

## rename the columns
# create vector with names
names_in_vector <- paste0("PC", 1:ncol(weightpca.df))
colnames(weightpca.df) <- names_in_vector

## rename the rows
rownames_in_vector <- evec.df %>% slice(-1) %>% select(1)
rownames(weightpca.df) <- rownames_in_vector[,1]

#########################3
## Begin with kmeans calc
#Define number of clusters to try
k.values <- 2:20

## define the function that will be used
avg_sil <- function(k, data) {
  km.res <- kmeans(data, centers = k, nstart = 200)
  ss <- silhouette(km.res$cluster, dist(data))
  mean(ss[, 3])
}

## calculate silhouette for the defined k
avg_sil_values.df <- data.frame(k_value = k.values,
                                Average_Silhouettes = map_dbl(k.values, avg_sil, weightpca.df))

## find the highest silohuette value
highest_sil.df <- avg_sil_values.df %>%
  arrange(desc(Average_Silhouettes)) %>%
  slice(1)

## create plot
sil.p <- ggplot(data = avg_sil_values.df,
                aes(x = k_value,
                    y = Average_Silhouettes)) +
  geom_line() +
  geom_point( data = highest_sil.df, color = "red4") +
  ggtitle( paste("Highest Avg. Sil. is K=", highest_sil.df$k_value)  ) +
  scale_x_continuous(name = "Number of clusters (k)",
                     breaks = k.values) +
  scale_y_continuous(name = "Average Silhouettes") +
  theme_bw()

################################ Getting the clusters with Kmeans ##############################################
## calculate clusters with the best observed k
kclusters <- kmeans(weightpca.df,
                    centers = highest_sil.df$k_value, nstart = 200)

## extract the cluster data
clustered_samples.df <- as.data.frame(kclusters$cluster)

## retag data
clustered_samples.df <- clustered_samples.df %>%
  mutate(sample = rownames(clustered_samples.df)) %>%
  rename( "cluster" = 1)

##get the tags df from the original evec df
tag.df <- evec.df %>%
  slice(-1) %>%
  select(c(1,ncol(evec.df)))

## add region to cluster data
## merge files
merged.df <- left_join(x = clustered_samples.df,
                       y = tag.df,
                       by = c("sample" = "V1"))

## rename lastcol as "tag"
colnames(merged.df)[ncol(merged.df)] <- "tag"

# sort samples by cluster
merged.df <- merged.df %>% arrange(cluster)

#save the clustered dataframe
## define output name
second_output_file <- gsub(pattern = ".kmeans.svg", replacement = ".kmeans.tsv", x = output_file)
#save df
write.table(x = merged.df, file = second_output_file,
            append = F, quote = F, sep = "\t", row.names = F, col.names = T)

######
## lets genearte PC1 vs PC2 plot with the groups tagged according to k-means approach
plotable.df <- evec.df %>% slice(-1) %>%
  select(1:3)

## tag data with cluster tags
plotable.df <- left_join(x = plotable.df,
                         y = clustered_samples.df,
                         by = c("V1" = "sample"))

## plot data

pca.p <- ggplot(data = plotable.df, aes(x=V2, y=V3, color = as.character(cluster) )) +
  geom_hline(yintercept = 0, alpha= 0.2) +
  geom_vline(xintercept = 0, alpha = 0.2) +
  geom_point() +
  ggtitle(label = "Clusters from best Avg. Sil") +
  scale_x_continuous(name = "PC1") +
  scale_y_continuous(name = "PC2") +
  scale_color_discrete(name = "cluster") +
  theme_bw()

## assemble a grid
grid.p <- plot_grid(sil.p, pca.p, nrow = 1)

## save plot as svg
ggsave(filename = output_file,
       plot = grid.p,
       device = "svg",
       width = 14, height = 7 , units = "in",
       dpi = 300)