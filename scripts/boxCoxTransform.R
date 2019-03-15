library(EnvStats)

bcTransform <- function(data) {
  
  if (min(data$value) == 0) {
    
    data <- data %>%
      group_by(pair) %>%
      arrange(pair) %>%
      mutate(trans =  value ** (
        boxcox((value + mean(value)),
               lambda = c(-10, 10),
               optimize = T)$lambda)
      )
    
  } else {
    
    data <- data %>%
      group_by(pair) %>%
      arrange(pair) %>%
      mutate(trans = value ** (
        boxcox(value,
               lambda = c(-10, 10),
               optimize = T)$lambda)
      )
  }
  
  return (data)
  
}