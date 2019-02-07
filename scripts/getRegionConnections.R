## Select columns by region, gather/spread, graph scatter of discon vs. fcDev
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

plotRegionConnections <- function(region) {
  
  region.discon <- getRegion(region, discon, inputName = "discon")
  region.fc <- getRegion(region, fcDev, inputName = "fcDev")
  
  region.data <- rbind(region.discon, region.fc)
  data <- spread(region.data, "conType", "value")
  
  data <- data %>%
    group_by(pair) %>%
    arrange(pair) %>%
    mutate({
      model <- lm(fc ~ discon);
      rsquare = summary(model)$r.squared
    }) %>%
    mutate({
      joint <- rbind(
        as.factor(discon), as.factor(fc));
      mi = paste("MI", mi.plugin(joint))
    })
  print(data$rsquare)

  ggplot(data,
         aes(x = discon,
             y = fc)) +
    geom_point() +
    geom_smooth(method = "lm") + 
    facet_wrap("~pair") +
    labs(x = "Structural Disruption", 
         y = "Devation in Functional Connectivity")
  
}

