# Script Description ----------------------
# This R script generates barplots using ggplot2 package to visualise the category level
# intensity analysis of changes between 6 land cover types derived from ESA CCI land
# cover data (1992-2015) covering Tanintharyi, Myanmar. The original land cover classes
# were reclassified/aggregated into six classes: Forest (FOR), Mosaic Vegetation (MOS),
# Shrubland (SHB), Other Vegetation (OTH), Cropland (CRP), and Non-Vegetation (NON). 
# Intensity analysis was calculated using an Excel spreadsheet with a VBA macro (see 
# https://sites.google.com/site/intensityanalysis/) and the 24 annual ESA CCI land cover
# data layers. The domain of the analysis is the landscape extent within the Tanintharyi
# Region, Myanmar.
#
# Script By:      Jose Don T De Alban
# Date Created:   13 Mar 2018
# Last Modified:  19 Mar 2018

# Set Working Directory -------------------

setwd("/Users/dondealban/Dropbox/Research/myanmar/intensity analysis/barplots/esa cci/tanintharyi/set 01 again/")

# Load Libraries --------------------------

library(ggplot2)
library(plyr)

# Read Input Data -------------------------

dataCATl <- read.csv(file="Category_Level_Losses.csv", header=TRUE, sep=",")
dataCATg <- read.csv(file="Category_Level_Gains.csv", header=TRUE, sep=",")

# Clean and Subset Data -------------------

# 1. Select columns: include all columns except Category ID
dfL <- subset(dataCATl, select=c(1,3:11))
dfG <- subset(dataCATg, select=c(1,3:11))

# 2. Add Change Type column
type1 <- rep("Loss", nrow(dfL))
type2 <- rep("Gain", nrow(dfG))
dfL <- cbind(dfL, type1)
dfG <- cbind(dfG, type2)

# 3. Add years of interval in the dataframe
# Create lookup table
Interval. <- c(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23)
Year <- c("1992-1993","1993-1994","1994-1995","1995-1996","1996-1997","1997-1998",
          "1998-1999","1999-2000","2000-2001","2001-2002","2002-2003","2003-2004",
          "2004-2005","2005-2006","2006-2007","2007-2008","2008-2009","2009-2010",
          "2010-2011","2011-2012","2012-2013","2013-2014","2014-2015")
lookup <- as.data.frame(cbind(Interval.,Year), stringsAsFactors=FALSE)

# Match time interval with year in new column based on lookup table 
dfL <- join(dfL, lookup, by='Interval.') # Need plyr package
dfG <- join(dfG, lookup, by='Interval.')

# 4. Reorder columns before renaming
dfL <- dfL[,c(1,12,2,11,3:10)]
dfG <- dfG[,c(1,12,2,11,3:10)]

# 5. Change column names for easier reference

# Note the following description of category level column names
# ColA - Interval
# ColB - Years of Time Interval
# ColC - Category Name
# ColD - Change Type
# ColE - Observed Annual Loss/Gain [number of elements]
# ColF - Loss/Gain Intensity [percent of t1/t2 category]
# ColG - Uniform Intensity [percent of interval domain]
# ColH - Uniform Annual Loss/Gain [number of elements]
# ColI - Hypothesized Annual Error [number of elements]
# ColJ - Commission Intensity [percent of t1/t2 category]
# ColK - Omission Intensity [percent of t1/t2 category]
# ColL - Hypothesized t1/t2 Error [percent of interval domain]

list <- c("ColA","ColB","ColC","ColD","ColE","ColF","ColG","ColH","ColI","ColJ","ColK","ColL")
colnames(dfL) <- c(list)
colnames(dfG) <- c(list)

# 6. Combine separate Loss and Gain datasets into one dataframe
dfCAT <- rbind(dfL, dfG)

# Generate Plots ------------------------

# Plot 1: Gain and Loss Intensities only (grouped per time interval)
plotCAT <- ggplot() + geom_bar(data=dfCAT, aes(x=ColC, y=ColF, fill=ColD), stat="identity", position=position_dodge())
plotCAT <- plotCAT  + geom_hline(data=dfCAT, aes(yintercept=ColG, colour="#000000"), linetype="dashed") # Uniform line
plotCAT <- plotCAT  + facet_wrap(~ColB)
plotCAT <- plotCAT  + labs(x="Category", y="Category Intensity (% of Category)")
plotCAT <- plotCAT  + scale_x_discrete(labels=c("CRP","FOR","MOS","NON","OTH","SHB"))
plotCAT <- plotCAT  + scale_fill_manual(values=c("#b43507","#8acd66"), labels=c("Loss Intensity","Gain Intensity"))
plotCAT <- plotCAT  + scale_colour_manual(values=c("#000000"), labels=c("Uniform Line"))
plotCAT <- plotCAT  + theme(panel.grid.minor=element_blank())
plotCAT <- plotCAT  + theme(legend.title=element_blank(), legend.position=c(0.8,0.1), legend.box="horizontal")

# Plot 2: Loss Intensity only
plotL <- ggplot() + geom_bar(data=dfL, aes(x=ColC, y=ColF, fill=ColD), stat="identity")
plotL <- plotL + geom_hline(data=dfL, aes(yintercept=ColG, colour="#000000"), linetype="dashed") # Uniform line
plotL <- plotL + facet_wrap(~ColB)
plotL <- plotL + labs(x="Category", y="Category Intensity (% of Category)")
plotL <- plotL + scale_x_discrete(labels=c("CRP","FOR","MOS","NON","OTH","SHB"))
plotL <- plotL + scale_fill_manual(values=c("#b43507"), name="", labels=c("Loss Intensity"))
plotL <- plotL + scale_colour_manual(values=c("#000000"), name="", labels=c("Uniform Line"))
plotL <- plotL + theme(panel.grid.minor=element_blank(), legend.position=c(0.8,0.1), legend.box="horizontal")

# Plot 3: Gain Intensity only
plotG <- ggplot() + geom_bar(data=dfG, aes(x=ColC, y=ColF, fill=ColD), stat="identity")
plotG <- plotG + geom_hline(data=dfG, aes(yintercept=ColG, colour="#000000"), linetype="dashed") # Uniform line
plotG <- plotG + facet_wrap(~ColB)
plotG <- plotG + labs(x="Category", y="Category Intensity (% of Category)")
plotG <- plotG + scale_x_discrete(labels=c("CRP","FOR","MOS","NON","OTH","SHB"))
plotG <- plotG + scale_fill_manual(values=c("#8acd66"), name="", labels=c("Gain Intensity"))
plotG <- plotG + scale_colour_manual(values=c("#000000"), name="", labels=c("Uniform Line"))
plotG <- plotG + theme(panel.grid.minor=element_blank(), legend.position=c(0.8,0.1), legend.box="horizontal")

# Plot 4: Combined Gain and Loss Intensities (grouped per category)
plotCOM <- ggplot() + geom_bar(data=dfG, aes(x=ColB, y=ColF, fill="#8acd66"), stat="identity")
plotCOM <- plotCOM  + geom_bar(data=dfL, aes(x=ColB, y=-ColF, fill="#b43507"), stat="identity")
plotCOM <- plotCOM  + geom_errorbar(data=dfG, aes(ymax=ColG, ymin=ColG), colour="#009404", linetype="dashed") # Uniform line
#plotCOM <- plotCOM  + geom_hline(data=dfG, aes(yintercept=ColG, colour="#009404"), linetype="dashed") # Uniform line
plotCOM <- plotCOM  + facet_grid(ColC ~., scales="free_y")
#plotCOM <- plotCOM  + facet_grid(ColC ~.)
plotCOM <- plotCOM  + labs(x="Time Interval", y="Category Intensity (% of Category)")
plotCOM <- plotCOM  + scale_fill_manual(values=c("#8acd66","#b43507"), name="", labels = c("Category Gain","Category Loss"))
#plotCOM <- plotCOM  + scale_colour_manual(values=c("#000000"), name="", labels = c("Uniform Line"))
plotCOM <- plotCOM  + scale_x_discrete(breaks=c("1992-1993","1997-1998","2001-2002","2004-2005","2009-2010","2014-2015"))
plotCOM <- plotCOM  + theme(panel.grid.minor=element_blank())


# Testing
plotCOM <- ggplot() + geom_bar(data=dfG, aes(x=ColB, y=ColF, fill="#8acd66"), stat="identity")
plotCOM <- plotCOM  + geom_bar(data=dfL, aes(x=ColB, y=-ColF, fill="#b43507"), stat="identity")
plotCOM <- plotCOM  + geom_errorbar(data=dfG, aes(ymax=ColG, ymin=ColG), colour="#009404", linetype="dashed") # Uniform line
plotCOM <- plotCOM  + facet_grid(ColC ~., scales="free_y")
plotCOM <- plotCOM  + labs(x="Time Interval", y="Category Intensity (% of Category)")
plotCOM <- plotCOM  + scale_fill_manual(values=c("#8acd66","#b43507"), name="", labels = c("Category Gain","Category Loss"))
plotCOM <- plotCOM  + scale_x_discrete(breaks=c("1992-1993","1997-1998","2001-2002","2004-2005","2009-2010","2014-2015"))
plotCOM <- plotCOM  + theme(panel.grid.minor=element_blank())




# # Plot 5: Combined Observed Gain and Loss Area in Pixels (grouped per category)
# plotPIX <- ggplot() + geom_bar(data=dfG, aes(x=ColB, y=ColE, fill="#8acd66"), stat="identity")
# plotPIX <- plotPIX  + geom_bar(data=dfL, aes(x=ColB, y=-ColE, fill="#b43507"), stat="identity")
# plotPIX <- plotPIX  + geom_hline(data=dfG, aes(yintercept=ColG, colour="#009404"), linetype="dashed") # Uniform line
# #plotPIX <- plotPIX  + facet_grid(ColC ~., scales="free_y")
# plotPIX <- plotPIX  + facet_grid(ColC ~.)
# plotPIX <- plotPIX  + labs(x="Time Interval", y="Category Area (Number of Pixels in Category)")
# plotPIX <- plotPIX  + scale_fill_manual(values=c("#8acd66","#b43507"), name="", labels = c("Category Gain","Category Loss"))
# #plotPIX <- plotPIX  + scale_colour_manual(values=c("#000000"), name="", labels = c("Uniform Line"))
# plotPIX <- plotPIX  + scale_x_discrete(breaks=c("1992-1993","1997-1998","2001-2002","2004-2005","2009-2010","2014-2015"))
# plotPIX <- plotPIX  + theme(panel.grid.minor=element_blank())

# Save Outputs --------------------------

# Output boxplots to a PDF file
ggsave(plotCAT, file="IntensityAnalysis-Category-LossGain-PerInterval.pdf", width=29.89, height=25, units="cm", dpi=300)
ggsave(plotL,   file="IntensityAnalysis-Category-Loss.pdf", width=29.89, height=25, units="cm", dpi=300)
ggsave(plotG,   file="IntensityAnalysis-Category-Gain.pdf", width=29.89, height=25, units="cm", dpi=300)
ggsave(plotCOM, file="IntensityAnalysis-Category-LossGain-PerCategory1.pdf", width=29.89, height=25, units="cm", dpi=300)
ggsave(plotCOM, file="IntensityAnalysis-Category-LossGain-PerCategory2.pdf", width=24, height=30.89, units="cm", dpi=300)


# Export dataframe to CSV file
write.csv(dfCAT, file="Category_Level.csv")
