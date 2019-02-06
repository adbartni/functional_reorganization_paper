## Perform independent sample t tests to determine pairs of regions 
## that are reasonably functionally connected in HCs, 
## and that are significantly structurally disrupted in MS sample

ind_samp_ttest <- function(inputData)  {

  pairs <- c()
  
  for (i in names(inputData)) {
    data <- inputData[i]
    
    test <- t.test(data, mu = 0)
    
    if (test$p.value != "NaN") {
      
      if (test$p.value < 0.05) {
        
        pairs <- rbind(pairs, i)
      }
    }
  }
  
  return (pairs)
}