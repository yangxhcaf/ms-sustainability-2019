# Script Description --------------------
# This script creates a stacked area graph of time-series land cover data, particularly
# the ESA CCI land cover data (1992-2015), reclassifed to follow IPCC broad land cover
# categories. 
#
# Script By:      Jose Don T De Alban
# Date Created:   22 Nov 2017
# Last Modified:  23 Jun 2018 


# Set Working Directory -----------------
setwd("/Users/dondealban/Dropbox/Research/myanmar/intensity analysis/stacked area/tanintharyi/aggregate kawthoung/")

# Load Libraries and Data ---------------
library(ggplot2)
library(reshape2)
library(plyr)

# Read csv files in the directory and store as a list
filenames <- list.files()

# Function to read data
readdata <- function(filename) {
  df <- read.csv(filename, sep="\t")
  vec <- df[, 3]           # Read column with percentage values
  names(vec) <- df[, 1]    # Read column with class codes
  return(vec)
}

# Combine as class codes and percentage values in a matrix
temp <- do.call(rbind, lapply(filenames, readdata))
colnames(temp) <- c("5","2","3","4","1","6")

# Add years as another column
row.names(temp) <- c("1992","1993","1994","1995","1996","1997","1998","1999",
                     "2000","2001","2002","2003","2004","2005","2006","2007",
                     "2008","2009","2010","2011","2012","2013","2014","2015")

# Convert wide format data frame into long format data frame
data <- melt(temp, id.vars="years", variable.name="class", value.name="percentage")
colnames(data) <- c("Years","Class","Percentage")

# Create Stacked Area Graphs ------------
aggreg <- ggplot() + geom_area(aes(x=Years, y=Percentage, fill=factor(Class, labels=c("Cropland","Mosaic Vegetation","Shrubland","Other Vegetation","Forest","Non-Vegetation"))), data=data)
aggreg <- aggreg + labs(x="Year", y="Percentage of Landscape", fill="Land Cover")
aggreg <- aggreg + theme_bw() +scale_fill_manual(values=c("#ffff64","#8ca000","#784b00","#ffb432","#006400","#0046c8"))

ggsave(aggreg, file="StackedArea-Aggregate-Kawthoung.pdf", width=19.89, height=15, units="cm", dpi=300)
