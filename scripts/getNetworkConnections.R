## This code is very WET;
## Needs to be cleaned soon;


## Load in dependencies
## Skip if already loaded to save time
dependencies <- c(
  "dplyr",
  "stringr",
  "ggplot2"
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
plotNetworkMeans <- function(network.name, disconSource, location = "total", intra.fc = F, legend.position = "none") {
  location <- tolower(location)
  input.discon <- chooseDisconSource(disconSource)
  subjects <- intersect(rownames(fcDev),
                        rownames(input.discon))
  
  if (location == "intra") {
    fc.network <- fcDev[subjects, getNetworkPairs(getNetworkRegions(network.name), location)]
    discon.network <- input.discon[subjects, getIntraNetworkPairs(getNetworkRegions(network.name))]
    disease_group <- disease.groups[subjects,]
    data <- data.frame(fc = rowMeans(fc.network),
                       discon = rowMeans(discon.network),
                       disease.group = disease_group)
    x.title <- "Structural Disruption to Regions Within Network"
    y.title <- "Change in Functional Connectivity to Regions Within Network"
    plot.title <- paste("Within Network Structural Disruption vs \nWithin Network Functional Change for",
                        network.name)
    
  } else if (location == "inter") {
    fc.outter <- fcDev[subjects, getInterNetworkPairs(getNetworkRegions(network.name))]
    discon.outter <- input.discon[subjects, getInterNetworkPairs(getNetworkRegions(network.name))]
    disease_group <- disease.groups[subjects,]
    data <- data.frame(fc = rowMeans(fc.outter),
                       discon = rowMeans(discon.outter),
                       disease.group = disease_group)
    x.title <- "Structural Disruption to Regions Outside of Network"
    y.title <- "Change in Functional Connectivity to Regions Outside of Network"
    plot.title <- paste("Outter Structural Disruption vs \nOutter Functional Change for",network.name)
    
  } else if (location == "total") {
    
    if (intra.fc == T) {
      fc.pairs <- fcDev[subjects, getIntraNetworkPairs(getNetworkRegions(network.name))]
    } else {
      fc.pairs <- isolateNetworkPairs(network.name, fcDev)
      fc.pairs <- fc.pairs[subjects,]
    }
    
    discon.pairs <- isolateNetworkPairs(network.name, input.discon)
    discon.pairs <- discon.pairs[subjects,]
    disease_group <- disease.groups[subjects,]
    data <- data.frame(fc = rowMeans(fc.pairs),
                       discon = rowMeans(discon.pairs),
                       disease.group = disease_group)
    x.title = "Structural Disruption to All Pairs with Regions Involved in Network"
    y.title = "Change in Functional Connectivity"
    if (intra.fc == T) {
      plot.title = 
        paste("Total Structural Disruption vs \nWithin Network Functional Change for",network.name)
    } else {
      plot.title = 
        paste("Total Structural Disruption vs \nTotal Functional Change for",network.name)
    }
    
  } else {
    print("Please enter a valid location parameter ('intra,' 'inter,' 'total')")
  }
  
  quickScatterPlot(data, network.name, x.title, y.title, plot.title, legend.position = legend.position)
  
}


######################
## Helper functions ##
######################
getNetworkPairs <- function(network, location) {
  location <- tolower(location)
  
  network.pairs <- c()
  for (region in network) {
    
    for (pair in pairs) {
      
      if (str_detect(pair, paste("_",region,sep=""))) {
        node <- str_split(
          pair,
          paste("_",region,sep=""),
          simplify = T
        )[1]
        
      } else if (str_detect(pair, paste(region,"_",sep=""))) {
        node <- str_split(
          pair,
          paste(region,"_",sep=""),
          simplify = T
        )[1]
        
      } else {
        next
      }
      
      if (!pair %in% network.pairs) {
        
        if (node %in% network && location == "intra") {
          network.pairs <- append(network.pairs, pair)
          
        } else if (!node %in% network && location == "inter") {
          network.pairs <- append(network.pairs, pair)
        }
      }
    }
  }
  return (network.pairs)
}


quickScatterPlot <- function(inputData, network, x.axis, y.axis, title, legend.position) {
  model <- lm(
    data = inputData,
    fc ~ discon
  )
  
  rsq <- summary(model)$r.square
  
  pval <- str_split(
    summary(model)[4], " ", simplify = T)[8] %>%
    str_extract(., "-?[0-9.]+")

  ggplot(inputData,
         aes(color = as.factor(disease.group),
             shape = as.factor(disease.group))) +
    geom_point(aes(x = discon,
                   y = fc)) + 
    geom_smooth(method = "lm",
                aes(x = discon,
                    y = fc),
                inherit.aes = F) + 
    scale_x_continuous(limits = c(0, 0.2539352)) + 
    scale_y_continuous(limits = c(0, 2.263598)) +
    labs(title = title,
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
    ) + theme(
      plot.title = element_text(size = 16, face = "bold"),
      plot.margin=grid::unit(c(0,0,0,0), "mm"),
      legend.position = legend.position
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
