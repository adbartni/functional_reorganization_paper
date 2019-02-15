library(dplyr)
library(stringr)

source('scripts/t_test.R')

## Format region names into usable strings
regions <- regions %>% 
  str_replace_all("-", "_") %>% 
  str_replace_all("[0-9]", "") %>% 
  str_replace_all("=", "")

## Select only the interested pairs found using NeMo HCs
discon <- discon[,isolated.pairs]
absolute.discon <- absolute.discon[,isolated.pairs]
fcDev <- fcDev[,isolated.pairs]
HC <- HC[,isolated.pairs]
dti <- dti[,isolated.pairs]

## Get absolute value of HC partial correlations
abs.HC <- abs(HC)

## Select pairs which regions are reasonably functionally connected
fc.pairs <- ind_samp_ttest(abs.HC)
discon <- discon[,fc.pairs]
absolute.discon <- absolute.discon[,fc.pairs]
fcDev <- fcDev[,fc.pairs]
dti <- dti[,fc.pairs]

## Select pairs which are reasonably structurally disrupted
sd.pairs <- ind_samp_ttest(absolute.discon)
discon <- discon[,sd.pairs]
absolute.discon <- absolute.discon[,sd.pairs]
fcDev <- fcDev[,sd.pairs]
dti <- dti[,sd.pairs]

## Remove outliers 
# remove <- c("55107", "55831", "71751")
# discon <- discon[!rownames(discon) %in% remove, ]
# absolute.discon <- absolute.discon[!rownames(discon) %in% remove, ]
# fcDev <- fcDev[!rownames(fcDev) %in% remove, ]
# dti <- dti[!rownames(dti) %in% remove, ]
