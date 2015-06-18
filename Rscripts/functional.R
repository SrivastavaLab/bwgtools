library(devtools) # you may need to install this!
## analysis file!
install_github("Srivastavalab/bwgtools", dependencies = TRUE)
library(bwgtools)
library(ggplot2)
library(dplyr)

### get invert data
invert <- c("Argentina", "French_Guiana", "Cardoso", "Colombia",
            "Macae", "PuertoRico","CostaRica") %>%
  combine_tab("bromeliad.final.inverts")

## This file contains all the taxonomic and functional
## information for all the invertebrates in the BWG database
bwg_names <- get_bwg_names()

### merge with functional groups
invert_traits <- merge_func(invert, bwg_names)

#4 summarize by functional group
func_groups <- sum_func_groups(invert_traits,
                               grps = list(~site,
                                           ~site_brom.id,
                                           ~pred_prey,
                                           ~func.group))

## screenshot or table of the output
## perhaps wrap this code into one that aggregates up to pred_prey

## functional group abundance
func_groups %>%
  ggplot(aes(x = as.factor(func.group), y = total_abundance)) +
  geom_point(position = position_jitter(width = 0.25), alpha = 0.5) +
  stat_summary(fun.data = "mean_cl_boot", colour = "red", size = 0.6) +
  facet_wrap(~site, ncol = 1, scales = "free_y") +
  ggtitle("functional group abundance")


## functional group biomass
func_groups %>%
  group_by(site) %>%
  filter(sum(total_biomass, na.rm = TRUE) > 10 ) %>% ## sites with less that this amount of biomass have no data at all.
  ggplot(aes(x = as.factor(func.group), y = total_biomass)) +
  geom_point(position = position_jitter(width = 0.25), alpha = 0.5) +
  facet_wrap(~site) +
  stat_summary(fun.data = "mean_cl_boot", colour = "red", size = 0.6) +
  facet_wrap(~site) +
  ggtitle("functional group biomass")


## now summarize the same numbers, but by predator and prey


func_groups <- sum_func_groups(invert_traits,
                               grps = list(~site,
                                           ~site_brom.id,
                                           ~pred_prey))


### trophic level abundance
func_groups %>%
  ggplot(aes(x = as.factor(pred_prey), y = total_abundance)) +
  geom_point(position = position_jitter(width = 0.25), alpha = 0.5) +
  facet_wrap(~site) +
  stat_summary(fun.data = "mean_cl_boot", colour = "red", size = 0.6) +
  facet_wrap(~site) +
  ggtitle("trophic level abundance")


### trophic level biomass
func_groups %>%
  group_by(site) %>%
  filter(sum(total_biomass, na.rm = TRUE) > 10 ) %>% ## sites with less that this amount of biomass have no data at all.
  ggplot(aes(x = as.factor(pred_prey), y = total_biomass)) +
  geom_point(position = position_jitter(width = 0.25), alpha =0.5) +
  facet_wrap(~site) +
  stat_summary(fun.data = "mean_cl_boot", colour = "red", size = 0.6) +
  facet_wrap(~site) +
  ggtitle("trophic level biomass")
