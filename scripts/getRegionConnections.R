## Select columns by region, gather/spread, graph scatter of discon vs. fcDev
## As well as adding a column for R sqaured and Mutual Information
## Now the p value for b1 as well

library(tidyr)
library(entropy)
library(ggplot2)

source('scripts/boxCoxTransform.R')


#' Selects alls columns of a specified dataframe that contain the input region
#' as a string in the column name, then gathers the columns according to
#' the source of the input data
#' 
#' @param region The name of the brain region to want to select all columns of connections
#' for as a string
#' @param inputData The dataframe that you are selecting the columns from
#' @param rowname "subject" by default. What the row names will be in the new dataframe
#' @param inputName What the column names will be in the newly created dataframe
#' @return A dataframe with four (4) columns:
#'  - subject/ID
#'  - pair/connection
#'  - value of connection/disconnection
#'  - conType - either disconnectivity or change in funtional connectivity
getRegion <- function(region, inputData, rowname = 'subject', inputName) {
  
  selectedRegion <- subset(inputData, select = grep(region, names(inputData)))
  selectedRegion <- cbind(rownames(selectedRegion), selectedRegion)
  
  colnames(selectedRegion)[1] <- rowname
  
  if (inputName == "discon") {
    outData <- selectedRegion %>%
      gather(key = "pair", value, -subject) %>%
      mutate(conType = "discon")
  }
  else if (inputName == "fcDev") {
    outData <- selectedRegion %>%
      gather(key = "pair", value, -subject) %>%
      mutate(conType = "fc")
  }
  return (outData)
}



#' Calculates the R squared and Mutual Information of a joint distribution
#' and adds each as a column to the input dataframe
#' 
#' @param data The dataframe containing columns for each of the discon score
#' and functional connectivity change
#' @return The input dataframe with two columns containing the R squared and mutual
#' information for the joint distribution of disconnectivity and functional connectivity
#' for each pair in the dataframe
addRsq_MI_cols <- function(data) {
  
  data <- data %>%
    group_by(pair) %>%
    arrange(pair) %>%
    mutate(rsquare = paste("R2 = ",
                           summary(lm(fc ~ discon))$r.squared)
    ) %>%
    mutate(mi = paste("MI = ", mi.plugin(
      rbind(
        as.factor(discon), as.factor(fc))))
    ) %>%
    mutate(pval = paste("P = ", str_split(
      summary(lm(fc ~ discon))[4],
      " ",
      simplify = T
    )[8]))
  
  return (data)
}



#' Uses ggplot to plot a scatter of every connection to a given region.
#' Also annotates each scatter with the R squared and mutual information
#' of the joint distribution of each connection disconnectivity and
#' deviation in functional connectivity.
#' 
#' 
#' @param region The region for which to view the scatter of every
#' connection to that region's structural disconnection vs.
#' deviation in functional connectivity.
#' @param discon.source Either dti or discon. Which disconnectivity
#' measure to plot against change in functional connectivity.
#' @return none, plots a facet_wrap of scatters for every connection
#' to a particular region
plotRegionConnections <- function(region, discon.source) {
  
  subjects <- intersect(rownames(fcDev),
                        rownames(discon.source))
  fcDev <- fcDev[subjects,]
  discon.source <- discon.source[subjects,]
  
  region.discon <- getRegion(region, discon.source, inputName = "discon")
  # region.discon <- bcTransform(region.discon)
  
  region.fc <- getRegion(region, fcDev, inputName = "fcDev")
  # region.fc <- bcTransform(region.fc)
  # region.discon <- subset(region.discon, select = -c(value))
  # region.fc <- subset(region.fc, select = -c(value))
  
  region.data <- rbind(region.discon, region.fc)
  data <- spread(region.data, "conType", "value")
  
  data <- addRsq_MI_cols(data)
  
  ggplot(data %>% drop_na(),
         aes(x = discon,
             y = fc)) +
    geom_point() +
    geom_smooth(method = "lm") + 
    facet_wrap("~pair", scales = "free") +
    labs(x = "Structural Disruption", 
         y = "Devation in Functional Connectivity") +
    geom_label(aes(x = -Inf,
                   y = Inf,
                   label = rsquare),
               inherit.aes = F,
               hjust = "inward",
               vjust = "inward") +
    geom_label(aes(x = Inf,
                   y = Inf,
                   label = mi),
               inherit.aes = F,
               hjust = "inward",
               vjust = "inward") +
    geom_label(aes(x = Inf,
                   y = -Inf,
                   label = pval),
               inherit.aes = F,
               hjust = "inward",
               vjust = "inward")
  
}

