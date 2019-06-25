## Read in databases
library(dplyr)
library(stringr)


discon <- read.table(
  'data/structural/matched_discon.csv', 
  sep = ",", 
  encoding = "utf-8", 
  header = 1, 
  row.names = 1
)
discon.cols <- colnames(discon)

absolute.discon <- read.table(
  'data/structural/matched_absolute_discon.csv', 
  sep = ",", 
  encoding = "utf-8", 
  header = 1, 
  row.names = 1
  )

dti <- read.table(
  'data/structural/matched_dti_15dir_w_missing_subs.csv',
  sep = ",",
  encoding = "utf-8",
  header = 1,
  row.names = 1
)

fcDev <- read.table(
  'data/functional/MS_abdif_w_missing_subs.csv',
  sep = ",", 
  encoding = "utf-8", 
  header = 1,
  row.names = 1
)
fmri.cols <- colnames(fcDev)

bidir.fcDev <- read.table(
  'data/functional/bidirectional_fc_dev.csv',
  sep = ",",
  encoding = "utf-8",
  header = 1,
  row.names = 1
)

HC <- read.table(
  'data/functional/control_part_cor.csv',
  sep = ",",
  encoding = "utf-8",
  header = 1,
  row.names = 1
)

## Get names of pairwise connections
pairs <- colnames(discon)
isolated.pairs <- c(readLines('data/SignificantlyDisruptedPairs.csv'))
smith.networks <- c()
for (network in dir('data/SmithNetworks')) {
  smith.networks <- append(
    smith.networks,
    str_split(network, '\\.', simplify = T)[1] %>% str_remove("Smith")
  )
}

## Get disease group for each subject
disease.groups <- read.csv(
  'data/DiseaseGroups.csv',
  encoding = 'utf-8',
  header = 1,
  row.names = 1
)

## Get names of regions from atlas
regions <- c(readLines('data/atlas_labels.txt'))

