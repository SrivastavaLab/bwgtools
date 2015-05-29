library(devtools)
install_github("Srivastavalab/bwgtools")
library(bwgtools)
terr <- combine_tab(c("Cardoso", "French_Guiana", "Colombia",
                      "Macae", "PuertoRico","CostaRica"),
                    sheetname = "bromeliad.terrestrial")

