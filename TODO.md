## Things to accomplish

 - ~~Successfully plot all connections for a region interactively~~
 - ~~Add DTI data~~
 - ~~Use absolute lesional discon~~
 - Look into shinydashboard (https://rstudio.github.io/shinydashboard/)
	- Create a dashboard for absolute lesional discon
	- Create a dashboard for dti
	- Make it easy to go between the two (dashboard makes it easier)
 - Possibly install muti to find mutual information, mi.plugin works for now though
```{r}
if(!require("devtools")) {
install.packages("devtools")
library("devtools")
}
devtools::install_github("mdscheuerell/muti")
```
