## analysis file!
library(bwgtools)
library("tidyr")
library(dplyr)
library(ggplot2)
library(magrittr)
## testing ground


# combine_tab -----------------------------------------

## We can read data in from all the sites and combine them. for example:
c("Argentina", "French_Guiana", "Colombia",
  "Macae", "PuertoRico","CostaRica") %>%
  sapply(offline) %>%
  combine_tab("site.info")

weather <- c("Argentina", "French_Guiana", "Colombia",
             "Macae", "PuertoRico","CostaRica") %>%
  sapply(offline) %>%
  combine_tab("site.weather")
## seem to be empty rows in:
# Cardoso
# Costa Rica

phys <- c("Argentina", "French_Guiana", "Colombia",
          "Macae", "PuertoRico","CostaRica") %>%
  sapply(offline) %>%
  combine_tab("bromeliad.physical")
# something is wrong with Cardoso site.info. too many columns?
## need to make the Colombia stopping rule more robust


leafwater <- c("Argentina", "French_Guiana", "Colombia",
               "Macae", "PuertoRico","CostaRica") %>%
  sapply(offline) %>%
  combine_tab("leaf.waterdepths")

invert <- c("Argentina", "French_Guiana", "Colombia",
            "Macae", "PuertoRico","CostaRica") %>%
  sapply(offline) %>%
  combine_tab("bromeliad.final.inverts")


## doesn't quite work for all sites; argentina still causing problems
invertI <- c("Argentina", "French_Guiana", "Colombia",
             "Macae", "PuertoRico","CostaRica") %>%
  sapply(offline) %>%
  combine_tab("bromeliad.initial.inverts")


# decomposition ---------------------------------------


phys <- combine_tab(sheetname = "bromeliad.physical")

## check ids
## is there only one of each label in a site?
phys %>%
  group_by(site_brom.id) %>%
  tally %>%
  .[["n"]] %>%
  sapply(function(x) x == 1) %>%
  all

long_phys <- physical_long(phys)

## because mass is long, containing two replicates for each site and species, we get 1 when people recorded the first sample but lost the second (1 but not 2) and 2 when both are missing
long_phys %>%
  dplyr::group_by(site, bromeliad.id, species) %>%
  dplyr::summarise(meanmass = mean(mass, na.rm = TRUE), sumna = sum(is.na(mass))) %>%
  dplyr::filter(!is.na(meanmass), sumna > 0)

long_phys %>%
  dplyr::group_by(site, species, rep, time) %>%
  dplyr::summarize(range = max(mass) - min(mass))


## calculate loss for each sample
leaf_loss <- leaf_loss_sample(long_phys)

means_loss <- leaf_loss_mean(leaf_loss)

decomp_responses(means_loss)
combine_tab("bromeliad.physical") %>%
  physical_long %>%
  leaf_loss_sample %>%
  leaf_loss_mean %>%
  decomp_responses


## we also have a quick shortcut for this process
decomp_data <- get_decomp()


# get bwg_names ---------------------------------------

bwg_names <- get_bwg_names(file = "../bwg_names/data/Distributions_organisms_full.tsv")



# FUNCTIONAL groups -----------------

### get invert data
invert <- c("Argentina", "French_Guiana", "Colombia",
            "Macae", "PuertoRico","CostaRica") %>%
  sapply(offline) %>%
  combine_tab("bromeliad.final.inverts")

### merge with functional groups
invert_traits <- merge_func(invert, bwg_names)

#4 summarize this
func_groups <- sum_func_groups(invert_traits, grps = list(~site, ~site_brom.id, ~pred_prey, ~func.group))

func_groups %>%
  ggplot(aes(x = func.group, y = total_abundance)) + geom_point(position = position_jitter(width = 0.25)) + facet_wrap(~site)


sum_trophic(func_groups)

plot_trophic(combine_tab(sheetname = "bromeliad.final.inverts"), bwg_names)
