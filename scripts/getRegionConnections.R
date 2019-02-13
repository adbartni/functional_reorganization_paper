## Select columns by region, gather/spread, graph scatter of discon vs. fcDev
## As well as adding a column for R sqaured and Mutual Information
library(tidyr)
library(entropy)

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


addRsq_MI_cols <- function(data) {
  
  data <- data %>%
    group_by(pair) %>%
    arrange(pair) %>%
    mutate(rsquare = paste("R2 = ",
                           summary(lm(fc ~ discon))$r.squared)
    ) %>%
    mutate(mi = paste("MI = ", mi.plugin(
      rbind(
        as.factor(discon), as.factor(fc)))
      )
    )
  return (data)
}


plotRegionConnections <- function(region, discon.source) {
  
  fcDev <- fcDev[rownames(discon.source),]
  
  region.discon <- getRegion(region, discon.source, inputName = "discon")
  region.fc <- getRegion(region, fcDev, inputName = "fcDev")
  
  region.data <- rbind(region.discon, region.fc)
  data <- spread(region.data, "conType", "value")
  
  data <- addRsq_MI_cols(data)

  ggplot(data,
         aes(x = discon,
             y = fc)) +
    geom_point() +
    geom_smooth(method = "lm") + 
    facet_wrap("~pair") +
    labs(x = "Structural Disruption", 
         y = "Devation in Functional Connectivity") + 
    geom_label(aes(x = 0.90 * max(discon), 
                   y = 0.90 * max(fc),
                   label = rsquare), 
               inherit.aes = F) +
    geom_label(aes(x = 0.90 * max(discon),
                   y = 0.80 * max(fc),
                   label = mi),
               inherit.aes = F)
  
}

