library(bwgtools)

devtools::install_github("Srivastavalab/bwgtools", dependencies=TRUE)

##get the terrestrial data
terrestrial <- combine_tab(sheetname = "bromeliad.terrestrial")

terr <- combine_tab(sheetname = "terrestrial.taxa")

##Get hydro variables
## We can read data in from all the sites and combine them. for example:
sites <- c("Argentina", "French_Guiana", "Colombia",
           "Macae", "PuertoRico","CostaRica") %>%
  combine_tab("site.info")

phys <- c("Argentina", "French_Guiana", "Colombia",
          "Macae", "PuertoRico","CostaRica") %>%
  combine_tab("bromeliad.physical")
# something is wrong with Cardoso site.info. too many columns?
## need to make the Colombia stopping rule more robust

leafwater <- c("Argentina", "French_Guiana", "Colombia",
               "Macae", "PuertoRico","CostaRica") %>%
  combine_tab("leaf.waterdepths")

hydro <- hydro_variables(leafwater, sites, phys)
