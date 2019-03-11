library(EnvStats)

bcTransform <- function(data) {
  
  data <- data %>%
    group_by(pair) %>%
    arrange(pair) %>%
    mutate(trans = value ** (
      boxcox(value,
             lambda = c(-1, 1),
             optimize = T)$lambda)
    )
  
  return (data)
  
}