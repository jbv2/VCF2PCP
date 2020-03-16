# Original Script: Andres Moreno-Estrada (Nov 2012)

## load libraries
library("dplyr")
library("svglite")

## Read args from command line
args = commandArgs(trailingOnly=TRUE)

## Uncomment For debugging only
## Comment for production mode only
# args[1] <- "test/data/sample22.LD.maf_filtered.autosomal.3.Q" ## %.fam file
# args[2] <- "test/data/sample22.LD.maf_filtered.popinfo.txt" ## $POP_INFO file 
# args[3] <- "test/data/sample22.LD.maf_filtered.autosomal.admixture_plot.svg" ## %.svg file

 ## Passing args to named objects
q_file <- args[1]
pop_info <- read.table(args[2], header=TRUE)
svg_file <- args[3]

#Create the population tags from the popinfo file
popnames <- as.vector(pop_info$POP)
spaces <- c(0,diff(pop_info$POP))
spaces <- replace(c(0,diff(pop_info$POP)), spaces != 0, 2)
index <- c(1, diff(as.numeric(pop_info$POP)))
index[index !=0] <- 1
borders <- seq(1, length(index))[index==1]
offset <- round(diff(c(borders,length(index) ) )/2)
newnames <- rep("", length(popnames))
newnames[borders+offset] <- as.character(popnames[borders+offset])

#Read the data
data <- read.table(q_file,header=FALSE)

# Set the bars colors
barcolors <- c("red2","blue3","green4","blueviolet","darkorange","cyan2","gold"
               ,"deeppink1","chartreuse2","dodgerblue","saddlebrown")

#<OUTPUT>
#Generate Plot as a PDF
svglite(file = svg_file, width = 10, height = 7)
par(mar=c(2,2,2,0)+0.1)
barplot(t(data), col=barcolors, border=NA, space=spaces, las=2, 
        main= q_file, width=c(rep(1,dim(data)[1]-10),rep(4,10)),
        cex.names = 0.5, cex.axis= 0.5, cex.main = 0.7)
dev.off()


