library(dplyr)
library(stringr)


getNetworkRegions <- function(network.name) {
  
  for (network in dir('data/SmithNetworks')) {
    if (str_detect(network, network.name)) {
      
      network.regions <- c(
        readLines(paste('data/SmithNetworks', network, sep = '/'))
      )
    }
  }
  
  return (network.regions)
}


getNetworkPairs <- function(network) {
  
  network.pairs <- c()
  for (region in network) {
    
    for (pair in pairs) {
      
      if (str_detect(pair, paste("_",region,sep=""))) {
        left <- str_split(
          pair,
          paste("_",region,sep=""),
          simplify = T
        )[1]
        if (left %in% network) {
          if (!pair %in% network.pairs) {
            network.pairs <- append(network.pairs, pair)
          }
        }
        
      } else if (str_detect(pair, paste(region,"_",sep=""))) {
        right <- str_split(
          pair,
          paste(region,"_",sep=""),
          simplify = T
        )[1]
        if (right %in% network) {
          if (!pair %in% network.pairs) {
            network.pairs <- append(network.pairs, pair)
          }
        }
      }
    }
  }
  return (network.pairs)
}


plotNetworkSums <- function(network.name) {
  
  subjects <- intersect(rownames(fcDev),
                        rownames(discon))
  network.pairs <- getNetworkPairs(getNetworkRegions(network.name))
  
  fc.network <- fcDev[subjects, network.pairs]
  discon.network <- discon[subjects, network.pairs]
  
  c
  
}


