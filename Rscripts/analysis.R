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

get_decomp


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



bwg_names <- get_bwg_names(file = "../bwg_names/data/Distributions_organisms_full.tsv")

#2 transform the data
long_mac_final <- invert_to_long(mac_final, category_vars = c("site", "trt.name", "bromeliad.id", "abundance.or.biomass"))

#3 combine with trait data
mac_traits <- merge_func(long_mac_final, bwg_names)

#4 summarize this
sum_grps <- sum_func_groups(mac_traits)

library(dplyr)
library(tidyr)

## make this into function
redone <- mac_traits %>%
  gather("quantity", "value", abundance, biomass, convert = FALSE) %>%
  ungroup %>%
  mutate(func.group = gsub(" ",".", func.group))

groups(redone)

redone$newname <- paste0(redone$func.group, ".", redone$quantity)

problem <- redone %>%
  group_by(bromeliad.id,mu,k, newname) %>%
  summarise(total_value = sum(value)) %>%
  spread(newname, value = total_value, fill = 0)

problem$bromeliad.id %>% unique


sum_grps

trophic_sums <- sum_trophic(sum_grps)


trophic_sums %>%
  dplyr::filter(!is.na(pred_prey)) %>%
  dplyr::select(-total_abundance, - total_taxa) %>%
  tidyr::spread(pred_prey, value = total_biomass) %>%
  ggplot2::ggplot(ggplot2::aes(x = prey, y = predator)) + ggplot2::geom_point()



## ALL AT ONCE
invert_final <- read_site_sheet(offline("French_Guiana"), "bromeliad.final.inverts")
bwg_names <- get_bwg_names(file = "../bwg_names/data/Distributions_organisms_full.tsv")

plot_trophic(invert_final, bwg_names)

mac_final <- read_site_sheet("Macae", "bromeliad.final.inverts")
bwg_names <- get_bwg_names()
plot_trophic(mac_final, bwg_names)


mac <- read_sheet("../../../Dropbox/BWG Drought Experiment/raw data/Drought_data_Macae.xlsx",
                       "bromeliad.final.inverts", ondisk = TRUE)

str(mac)

read_sheet("../../../Dropbox/BWG Drought Experiment/raw data/Drought_data_PuertoRico.xlsx",
                  "site.info", ondisk = TRUE)

filelist <- list.files("../../../Dropbox/BWG Drought Experiment/raw data/", pattern = "^Drought*", full.names = TRUE)
filelist <- filelist[-3]

leaf_depth_list <- lapply(filelist, read_sheet, sheetname = "leaf.waterdepths", ondisk = TRUE)

## or if internet
leaf_depth_list <- get_all_sites(sheetname = "leaf.waterdepths")

lapply(leaf_depth_list, check_names)

check_names(leaf_depth_list[[1]])

head(leaf_depth_list[[1]])

all_leaf <- dplyr::rbind_all(leaf_depth_list)
## write a function that combines the data and also checks it
## not in that order

## date to date
## control the day of the experiment for each bromeliad
## the first day of the experiment is the first non-NA

## proof of concept for macae

head(all_leaf)


## make this into a function
longwater <- . %>%
  gather("data_name", "depth", starts_with("depth")) %>%
  separate(data_name, into = c("depth_word", "leaf", "first_or_second","first")) %>%
  select(-depth_word, -first)


mac %>%
  longwater %>%
  group_by(bromeliad.id) %>%
  mutate(day_of_exp = dense_rank(date))

### CostaRica

## get just Macae --- See here @nacmarino


make_data <- . %>%
  longwater %>%
  group_by(bromeliad.id) %>%
  mutate(day_of_exp = dense_rank(date)) %>%
  ### these would also make good additions to longwater
  separate(trt.name, into = c("mu", "k"), sep = "k") %>%
  mutate(mu = extract_numeric(mu))

cr_mac <- rbind_list(make_data(cr),make_data(mac))

min(cr$date)-max(cr$date)

daily <- data_frame(date = min(cr$date) + ddays(1:54))

left_join(daily, cr)

## trouble with the dates?
## make a list of missing dates
## loop over it, cbinding to information columns
## rbind list
## combine


toplot <- cr_mac %>%
  filter(!is.na(depth)) %>%
  group_by(site, bromeliad.id) %>%
  mutate(day_of_exp = as.numeric(date - min(date)))

toplot %>%
  ggplot(aes(x = day_of_exp, y = depth,
             colour = leaf, group = leaf)) + geom_line() + geom_point() +
  facet_grid(site + mu~k)


library(magrittr)
library(tidyr)
library(dplyr)

read_site_sheet("Macae", "leaf.waterdepths") %>%
  longwater
