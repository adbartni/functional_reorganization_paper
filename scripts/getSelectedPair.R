getSelectedPair <- function(x, y) {
  
  selectedPair <- paste(x, y, sep = "_")

  data = cbind.data.frame(discon[[selectedPair]], fcDev[[selectedPair]])
  
  return (data)
  
}