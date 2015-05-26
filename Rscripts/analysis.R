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
  ggplot(aes(x = func.group, y = total_abundance)) +
  geom_point(position = position_jitter(width = 0.25)) + facet_wrap(~site)


sum_trophic(func_groups)

plot_trophic(combine_tab(sheetname = "bromeliad.final.inverts"), bwg_names)



# Water -----------------------------------------------

mac <- read_site_sheet(offline("Macae"), "leaf.waterdepths")

mac_water <- mac %>%
  longwater

group_or_summarize <- function(data, aggregate_leaves = FALSE){
  all_names_pres <- all(c("site", "watered_first",
        "trt.name",
        "leaf") %in% names(data))

  if (!all_names_pres) stop("some names are missing")

  if (aggregate_leaves) {
    data %>%
      group_by(site, watered_first, trt.name, bromeliad.id, date) %>%
      summarise(depth = mean(depth, na.rm = TRUE))
  } else {
    data %>%
      group_by(site, watered_first, trt.name, leaf)
  }
}

test_gr_sum <- structure(list(
  site = c("macae", "macae", "macae", "macae", "macae"),
  trt.name = c("mu3k0.5", "mu0.1k2", "mu1.5k0.5", "mu0.8k0.5", "mu0.1k1"),
  bromeliad.id = c("B5", "B29", "B34", "B8", "B22"),
  date = structure(c(1365206400, 1367452800, 1364688000, 1368230400,1368403200), class = c("POSIXct", "POSIXt"), tzone = "UTC"),
  leaf = c("leafb", "centre", "leafa", "leafb", "leafb"),
  watered_first = c("yes", "no", "no", "yes", "no"),
  depth = c(74.8, NA, NA, 46.6, NA)),
  .Names = c("site", "trt.name", "bromeliad.id", "date", "leaf", "watered_first", "depth"),
  class = c("tbl_df", "data.frame"), row.names = c(NA, -5L))

group_or_summarize(test_gr_sum, TRUE)

## does grouped filter work the way i expect?
testwater <- mac_water %>%
  ## filter out centre
  filter_centre_leaf() %>% ## add argument here
  ## filter out NA groups
  group_or_summarize(aggregate_leaves = FALSE) %>% ## add argument here
  filter_naonly_groups %>%
  arrange(date) %>%
  do(water_summary_calc(.$depth))




calcwater <- . %>%
  ## filter out centre
  filter_centre_leaf() %>% ## add argument here
  ## filter out NA groups
  group_or_summarize(aggregate_leaves = FALSE) %>% ## add argument here
  filter_naonly_groups %>%
  arrange(date) %>%
  do(water_summary_calc(.$depth))


test_all_water <- leafwater %>%
  longwater %>%
  calcwater


filter_naonly_groups(group_by(na_lvls, x))


testdf <- data_frame(a = 1:3)
  x <- quote(a > 2)
filter_(testdf, x)

mac_water %>% as.data.frame %>% .[1:3,] %>% dput

## check for column names
needed_names <- c("watered_first", "site", "trt.name", "bromeliad.id","leaf")
testnames <- assertthat::has_name(mac_water, needed_names)
if(!all(testnames)) stop(sprintf("must have names %s", paste(needed_names, collapse = ", ")))

## check for filtering


filter(watered_first == "yes") %>%
  group_by(site, trt.name, bromeliad.id, leaf) %>%
  do(water_summary_calc(.$depth))
