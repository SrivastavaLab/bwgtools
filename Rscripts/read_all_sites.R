library(bwgtools)
library(dplyr)
library(loggr)

log_file("Rscripts/test.log", .message = FALSE)

# site.info -------------------------------------------

read_site_sheet(offline("Argentina"), "site.info")
read_site_sheet("Cardoso", "site.info")
read_site_sheet("Colombia", "site.info")
read_site_sheet("CostaRica", "site.info")
read_site_sheet("French_Guiana", "site.info")
read_site_sheet("Macae", "site.info")
read_site_sheet("PuertoRico", "site.info")


# site.weather ----------------------------------------

read_site_sheet("Argentina", "site.weather")
read_site_sheet("Cardoso", "site.weather")
read_site_sheet("Colombia", "site.weather")
read_site_sheet("CostaRica", "site.weather")
read_site_sheet("French_Guiana", "site.weather")
read_site_sheet("Macae", "site.weather")
read_site_sheet("PuertoRico", "site.weather")


# bromeliad.physical ----------------------------------

read_site_sheet("Argentina", "bromeliad.physical")
read_site_sheet("Cardoso", "bromeliad.physical")
read_site_sheet("Colombia", "bromeliad.physical")
read_site_sheet("CostaRica", "bromeliad.physical")
read_site_sheet("French_Guiana", "bromeliad.physical")
read_site_sheet("Macae", "bromeliad.physical")
read_site_sheet("PuertoRico", "bromeliad.physical")


# leaf.waterdepths ------------------------------------

read_site_sheet("Argentina", "leaf.waterdepths")
read_site_sheet("Cardoso", "leaf.waterdepths")
read_site_sheet("Colombia", "leaf.waterdepths")
read_site_sheet("CostaRica", "leaf.waterdepths")
read_site_sheet("French_Guiana", "leaf.waterdepths")
read_site_sheet("Macae", "leaf.waterdepths")
read_site_sheet("PuertoRico", "leaf.waterdepths")


# terrestrial.taxa ------------------------------------

read_site_sheet("Argentina", "terrestrial.taxa")
read_site_sheet("Cardoso", "terrestrial.taxa")
read_site_sheet("Colombia", "terrestrial.taxa")
read_site_sheet("CostaRica", "terrestrial.taxa")
read_site_sheet("French_Guiana", "terrestrial.taxa")
read_site_sheet("Macae", "terrestrial.taxa")
read_site_sheet("PuertoRico", "terrestrial.taxa")


# bromeliad.terrestrial -------------------------------

read_site_sheet("Argentina", "bromeliad.terrestrial")
read_site_sheet("Cardoso", "bromeliad.terrestrial")
read_site_sheet("Colombia", "bromeliad.terrestrial")
read_site_sheet("CostaRica", "bromeliad.terrestrial")
read_site_sheet("French_Guiana", "bromeliad.terrestrial")
read_site_sheet("Macae", "bromeliad.terrestrial")
read_site_sheet("PuertoRico", "bromeliad.terrestrial")


# bromeliad.ibuttons ----------------------------------
### NOT DONE YET
# read_site_sheet("Argentina", "bromeliad.ibuttons")
# read_site_sheet("Cardoso", "bromeliad.ibuttons")
# read_site_sheet("Colombia", "bromeliad.ibuttons")
# read_site_sheet("CostaRica", "bromeliad.ibuttons")
# read_site_sheet("French_Guiana", "bromeliad.ibuttons")
# read_site_sheet("Macae", "bromeliad.ibuttons")
# read_site_sheet("PuertoRico", "bromeliad.ibuttons")


# bromeliad.initial.inverts ---------------------------

read_site_sheet("Argentina", "bromeliad.initial.inverts") ## header wrong
read_site_sheet("Cardoso", "bromeliad.initial.inverts") ## not BWGids
read_site_sheet("Colombia", "bromeliad.initial.inverts")
read_site_sheet("CostaRica", "bromeliad.initial.inverts") ## not BWGids
read_site_sheet("French_Guiana", "bromeliad.initial.inverts") ## not BWGids
read_site_sheet("Macae", "bromeliad.initial.inverts") ## not BWGids
read_site_sheet("PuertoRico", "bromeliad.initial.inverts")


# bromeliad.final.inverts -----------------------------


read_site_sheet("Argentina", "bromeliad.final.inverts")
read_site_sheet("Cardoso", "bromeliad.final.inverts")
read_site_sheet("Colombia", "bromeliad.final.inverts")
read_site_sheet(offline("CostaRica"), "bromeliad.final.inverts")
read_site_sheet("French_Guiana", "bromeliad.final.inverts")
read_site_sheet("Macae", "bromeliad.final.inverts")
read_site_sheet("PuertoRico", "bromeliad.final.inverts")


