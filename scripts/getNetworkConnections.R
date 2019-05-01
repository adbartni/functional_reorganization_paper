## This code is very WET;
## Needs to be cleaned soon;


#' Load in dependencies
#' Skip if already loaded to save time
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


#' Gets the names of regions involved in a given network
#' @param network.name The name of the interested network as a string
#' @return vector of strings with each region's name
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


########################
## Plotting functions ##
########################
plotIntraNetworkSums <- function(network.name, disconSource) {
  
  input.discon <- chooseDisconSource(disconSource)
  subjects <- intersect(rownames(fcDev),
                        rownames(input.discon))
  intranetwork.pairs <- getIntraNetworkPairs(getNetworkRegions(network.name))

  fc.network <- fcDev[subjects, intranetwork.pairs]
  discon.network <- input.discon[subjects, intranetwork.pairs]
  disease_group <- disease.groups[subjects,]
  data <- data.frame(fc = rowMeans(fc.network),
                     discon = rowMeans(discon.network),
                     disease.group = disease_group)
  
  quickScatterPlot(data, network.name,
                   x.axis = "Structural Disruption to Regions Within Network",
                   y.axis = "Change in Functional Connectivity to Regions Within Network")

}


plotInterNetworkSums <- function(network.name, disconSource) {
  
  input.discon <- chooseDisconSource(disconSource)
  subjects <- intersect(rownames(fcDev),
                        rownames(input.discon))
  internetwork.pairs <- getInterNetworkPairs(getNetworkRegions(network.name))
  
  fc.outter <- fcDev[subjects, internetwork.pairs]
  discon.outter <- input.discon[subjects, internetwork.pairs]
  disease_group <- disease.groups[subjects,]
  data <- data.frame(fc = rowMeans(fc.outter),
                     discon = rowMeans(discon.outter),
                     disease.group = disease_group)
  
  quickScatterPlot(data, network.name,
                   x.axis = "Structural Disruption to Regions Outside of Network",
                   y.axis = "Change in Functional Connectivity to Regions Outside of Network")
  
}


plotNetworkSums <- function(network.name, disconSource) {
  
  input.discon <- chooseDisconSource(disconSource)
  subjects <- intersect(rownames(fcDev),
                        rownames(input.discon))
  
  fc.pairs <- isolateNetworkPairs(network.name, fcDev)
  discon.pairs <- isolateNetworkPairs(network.name, input.discon)
  fc.pairs <- fc.pairs[subjects,]
  discon.pairs <- discon.pairs[subjects,]
  disease_group <- disease.groups[subjects,]
  data <- data.frame(fc = rowMeans(fc.pairs),
                     discon = rowMeans(discon.pairs),
                     disease.group = disease_group)
  
  quickScatterPlot(data, network.name,
                   x.axis = "Structural Disruption to All Pairs with Regions Involved in Network",
                   y.axis = "Change in Functional Connectivity to All Pairs with Regions Involved in Network")
  
}


######################
## Helper functions ##
######################
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


quickScatterPlot <- function(inputData, network, x.axis, y.axis) {
  model <- lm(
    data = inputData,
    fc ~ discon
  )
  
  rsq <- summary(model)$r.square
  
  pval <- str_split(
    summary(model)[4], " ", simplify = T)[8]

  ggplot(inputData,
         aes(color = as.factor(disease.group),
             shape = as.factor(disease.group))) +
    geom_point(aes(x = discon,
                   y = fc)) + 
    geom_smooth(method = "lm",
                aes(x = discon,
                    y = fc),
                inherit.aes = F) + 
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


chooseDisconSource <- function(disconSource) {
  if (disconSource == "ChaCo") {
    outputData <- discon
  } else if (disconSource == "Diffusion") {
    outputData <- dti
  } else {
    outputData <- NULL
  }
  return (outputData)
}
