## analysis file!
library(bwgtools)
library("tidyr")
library(dplyr)
library(ggplot2)
library(magrittr)
## testing ground


# combine_tab -----------------------------------------

## We can read data in from all the sites and combine them. for example:
sites <- c("Argentina", "French_Guiana", "Colombia", "Cardoso",
           "Macae", "PuertoRico","CostaRica") %>%
 # sapply(offline) %>%
  combine_tab("site.info")

weather <- c("Argentina", "French_Guiana", "Colombia",
             "Macae", "PuertoRico") %>% ## no such data for CR yet
 # sapply(offline) %>%
  combine_tab("site.weather")
## seem to be empty rows in:
# Cardoso
# Costa Rica

phys <- c("Argentina", "French_Guiana", "Colombia", "Cardoso",
          "Macae", "PuertoRico","CostaRica") %>%
  #sapply(offline) %>%
  combine_tab("bromeliad.physical")
# something is wrong with Cardoso site.info. too many columns?
## need to make the Colombia stopping rule more robust

identical(phys$site_brom.id, unique(phys$site_brom.id))

leafwater <- c("Argentina", "French_Guiana", "Colombia",
               "Macae", "PuertoRico","CostaRica") %>%
  #sapply(offline) %>%
  combine_tab("leaf.waterdepths")

invert <- c("Argentina", "French_Guiana", "Colombia",
            "Macae", "PuertoRico","CostaRica") %>%
  combine_tab("bromeliad.final.inverts")


## doesn't quite work for all sites; argentina still causing problems
invertI <- c("Argentina", "French_Guiana", "Colombia",
             "Macae", "PuertoRico","CostaRica") %>%
  sapply(offline) %>%
  combine_tab("bromeliad.initial.inverts")


# terrestrial -----------------------------------------

terr <- combine_tab(c("Cardoso", "French_Guiana", "Colombia",
                      "Macae", "PuertoRico","CostaRica"),
                    sheetname = "bromeliad.terrestrial")


### taxa

terr.tax <- c("Cardoso", "French_Guiana", "Colombia",
              "Macae", "PuertoRico","CostaRica") %>%# sapply(offline) %>%
  combine_tab(sheetname = "terrestrial.taxa")

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



combine_tab(sheetname = "bromeliad.physical") %>%
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
invert <- c("Argentina", "French_Guiana", "Cardoso", #"Colombia",
            "Macae", "PuertoRico","CostaRica") %>%
  sapply(offline) %>%
  combine_tab("bromeliad.final.inverts")

### merge with functional groups
invert_traits <- merge_func(insect_data = insect_data, bwg_names)

#4 summarize this
func_groups <- sum_func_groups(invert_traits, grps = list(~site, ~site_brom.id, ~pred_prey, ~func.group))

library(ggplot2)
func_groups %>%
  ggplot(aes(x = func.group, y = total_abundance)) +
  geom_point(position = position_jitter(width = 0.25)) + facet_wrap(~site)


sum_trophic(func_groups)

plot_trophic(combine_tab(sheetname = "bromeliad.final.inverts"), bwg_names)



# Water -----------------------------------------------
## We can read data in from all the sites and combine them. for example:
sites <- c("Argentina", "French_Guiana", "Colombia",
           "Macae", "PuertoRico","CostaRica") %>%
   sapply(offline,"../../../Dropbox/") %>%
  combine_tab("site.info")

phys <- c("Argentina", "French_Guiana", "Colombia",
          "Macae", "PuertoRico","CostaRica") %>%
  sapply(offline,"../../../Dropbox/") %>%
  combine_tab("bromeliad.physical")
# something is wrong with Cardoso site.info. too many columns?
## need to make the Colombia stopping rule more robust

leafwater <- c("Argentina", "French_Guiana", "Colombia",
               "Macae", "PuertoRico","CostaRica") %>%
  sapply(offline,"../../../Dropbox/") %>%
  combine_tab("leaf.waterdepths")

hydro <- hydro_variables(leafwater, sites, phys)

leafwater %>% 
  filter(site == "frenchguiana") %>% 
  hydro_variables(sites, phys)


hydro2 <- hydro_variables(leafwater, sites, phys,rm_centre = FALSE,aggregate_leaves = FALSE)

hydro3 <- hydro_variables(leafwater, sites, phys,rm_centre = TRUE,aggregate_leaves = TRUE)

View(hydro)
View(hydro2)
View(hydro3)

cr <- read_site_sheet("CostaRica", "leaf.waterdepths") %>%
  brom_id_maker

cr_water <- cr %>%
  longwater

leafwater

# test_supp

## check all first dates
leafwater %>%
  group_by(site) %>%
  summarize(dmin = min(date))

## was the first date of water addition earlier than the
## first date of sampling for any site?
sites %>%
  select(site.name, start.water.addition) %>%
  left_join(leafwater %>%
              group_by(site) %>%
              summarize(first_depth_date = min(date)),
            by = c("site.name" = "site"))
## no, everything looks fine



## are the minima the same
mac_water %>%
  ## filter out centre
  filter_centre_leaf() %>% ## add argument here
  group_by(site, watered_first) %>%
  filter_naonly_groups %>%
  group_by(trt.name) %>%
  # get the minimal date, the first date
  summarize(date = min(date)) %>%
  # join to the start_block
  left_join(test_supp %>%
              filter(site == "macae") %>%
              select(trt.name, start_block)) %>%
  {identical(.$date, .$start_block)}


## are the maxima the same
mac_water %>%
  ## filter out centre
  filter_centre_leaf() %>% ## add argument here
  group_by(site, watered_first) %>%
  filter_naonly_groups %>%
  group_by(trt.name) %>%
  # get the minimal date, the first date
  summarize(date = max(date)) %>%
  # join to the start_block
  left_join(test_supp %>%
              filter(site == "macae") %>%
              select(trt.name, finish_block)) %>%
              {identical(.$date + lubridate::days(3), .$finish_block)}
## yeah, after 4 days



%>%
  View



sum(is.na(testwater2$depth))

mac_water$date %>% range
filter(long_dates, site == "macae")$date %>% range


calcwater <- . %>%
  ## filter out centre
  filter_centre_leaf() %>% ## add argument here
  group_by(site, watered_first) %>%
  filter_naonly_groups %>%
  ungroup %>%
  ## filter out NA groups
  group_or_summarize(aggregate_leaves = TRUE) %>% ## add argument here
  ## The useful grouping is gone from here.
  left_join(long_dates, .) %>%
  arrange(trt.name, leaf, date) %>%
  ## filter out the impossible missing site_brom.id values
  filter(!is.na(site_brom.id)) %>%
  group_by(site, trt.name, leaf) %>% ## could just make the behaviour at this line
  # dependent on the value of aggregate_leaves.
  do(water_summary_calc(.$depth))

test_all_water <- leafwater %>%
  longwater %>%
  calcwater





readr::write_csv(test_all_water, "Rscripts/test_water_calc.csv")


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



# RLQ -------------------------------------------------

## SKIPPING COLOMBIA because they modified their lea

