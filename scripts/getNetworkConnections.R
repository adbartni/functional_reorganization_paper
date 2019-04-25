dependencies <- c(
  "dplyr",
  "stringr"
)

for (package in dependencies) {
  if (!package %in% (.packages())) {
    library(package,
            character.only = T)
  }
}


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


getIntraNetworkPairs <- function(network) {
  
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


getInterNetworkPairs <- function(network) {
  
  network.pairs <- c()
  for (region in network) {
    
    for (pair in pairs) {
      
      if (str_detect(pair, paste("_",region,sep=""))) {
        left <- str_split(
          pair,
          paste("_",region,sep=""),
          simplify = T
        )[1]
        if (!left %in% network) {
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
        if (!right %in% network) {
          if (!pair %in% network.pairs) {
            network.pairs <- append(network.pairs, pair)
          }
        }
      }
    }
  }
  return (network.pairs)
}

quickScatterPlot <- function(inputData, network, x.axis, y.axis) {
  model <- lm(
    data = inputData,
    fc ~ discon
  )
  
  rsq <- summary(model)$r.square
  
  pval <- str_split(
    summary(model)[4], " ", simplify = T)[8]
  
  ggplot(inputData) +
    geom_point(
      aes(x = discon,
          y = fc)
    ) + 
    geom_smooth(method = "lm",
                aes(x = discon,
                    y = fc)) + 
    labs(title = network,
         x = x.axis,
         y = y.axis) + 
    geom_label(
      aes(x = Inf,
          y = Inf,
          label = paste("R2 = ",rsq)),
      inherit.aes = F,
      hjust = "inward",
      vjust = "inward"
    ) + 
    geom_label(
      aes(x = Inf,
          y = -Inf,
          label = paste("P = ",pval)),
      inherit.aes = F,
      hjust = "inward",
      vjust = "inward"
    )
}


plotIntraNetworkSums <- function(network.name) {
  
  subjects <- intersect(rownames(fcDev),
                        rownames(discon))
  intranetwork.pairs <- getIntraNetworkPairs(getNetworkRegions(network.name))

  fc.network <- fcDev[subjects, intranetwork.pairs]
  discon.network <- discon[subjects, intranetwork.pairs]
  data <- data.frame(fc = rowMeans(fc.network),
                     discon = rowMeans(discon.network))
  
  quickScatterPlot(data, network.name,
                   x.axis = "Structural Disruption to Regions Within Network",
                   y.axis = "Change in Functional Connectivity to Regions Within Network")

}


plotInterNetworkSums <- function(network.name) {
  
  subjects <- intersect(rownames(fcDev),
                        rownames(discon))
  internetwork.pairs <- getInterNetworkPairs(getNetworkRegions(network.name))
  
  fc.outter <- fcDev[subjects, internetwork.pairs]
  discon.outter <- discon[subjects, internetwork.pairs]
  data <- data.frame(fc = rowMeans(fc.outter),
                     discon = rowMeans(discon.outter))
  
  quickScatterPlot(data, network.name,
                   x.axis = "Structural Disruption to Regions Outside of Network",
                   y.axis = "Change in Functional Connectivity to Regions Outside of Network")
  
}


plotNetworkSums <- function(network.name) {
  
  subjects <- intersect(rownames(fcDev),
                        rownames(discon))
  
  isolateNetworkPairs <- function(network, inputData) {
    networkData <- data.frame(row.names = rownames(inputData))
    
    for (region in getNetworkRegions(network)) {
      networkData <- cbind(
        inputData[, grep(region, names(inputData))],
        networkData
      )
    }
    return (networkData)
  }
  
  fc.pairs <- isolateNetworkPairs(network.name, fcDev)
  discon.pairs <- isolateNetworkPairs(network.name, discon)
  fc.pairs <- fc.pairs[subjects,]
  discon.pairs <- discon.pairs[subjects,]
  data <- data.frame(fc = rowMeans(fc.pairs),
                     discon = rowMeans(discon.pairs))
  
  quickScatterPlot(data, network.name,
                   x.axis = "Structural Disruption to All Pairs with Regions Involved in Network",
                   y.axis = "Change in Functional Connectivity to All Pairs with Regions Involved in Network")
  
}

