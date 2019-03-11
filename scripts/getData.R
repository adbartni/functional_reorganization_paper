## Read in databases

discon <- read.table(
  'data/matched_discon.csv', 
  sep = ",", 
  encoding = "utf-8", 
  header = 1, 
  row.names = 1
)

absolute.discon <- read.table(
  'data/matched_absolute_discon.csv', 
  sep = ",", 
  encoding = "utf-8", 
  header = 1, 
  row.names = 1
  )

dti <- read.table(
  'data/matched_dti.csv',
  sep = ",",
  encoding = "utf-8",
  header = 1,
  row.names = 1
)

fcDev <- read.table(
  'data/MS_abdif.csv',
  sep = ",", 
  encoding = "utf-8", 
  header = 1, 
  row.names = 1
)

HC <- read.table(
  'data/control_part_cor.csv',
  sep = ",",
  encoding = "utf-8",
  header = 1,
  row.names = 1
)

## Get names of pairwise connections
pairs <- colnames(discon)
# isolated.pairs <- c(readLines('data/IsolatedPairs.csv'))
isolated.pairs <- c(readLines('data/SignificantlyDisruptedPairs.csv'))

## Get names of regions from atlas
regions <- c(readLines('data/atlas_labels.txt'))
