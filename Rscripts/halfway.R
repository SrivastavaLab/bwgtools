suppressPackageStartupMessages(library(bwgtools))
library(dplyr)
library(tidyr)

bwg_names <- get_bwg_names()

decomp <- get_decomp()

phys <- combine_tab("bromeliad.physical")

read_site_sheet("Macae", "bromeliad.final.inverts") %>%
  tidyr::gather("species", "quantity", Diptera.15:Diptera.461, convert = TRUE) %>% str


summarized_pred_prey <- read_site_sheet("Macae", "bromeliad.final.inverts") %>%
  invert_to_long(category_vars = c("site", "trt.name",
                                   "bromeliad.id",
                                   "abundance.or.biomass")) %>%
  merge_func(bwg_names) %>%
  sum_func_groups %>%
  select(-func.group) %>%
  group_by(bromeliad.id, pred_prey) %>%
  summarize(biomass = sum(total_biomass)) %>%
  mutate(pred_prey = ifelse(is.na(pred_prey), "unknown", pred_prey)) %>%
  ungroup %>%
  spread(key = pred_prey, value = biomass)




summarized_pred_prey <- read_site_sheet("Macae", "bromeliad.final.inverts") %>%
  invert_to_long(category_vars = c("site", "trt.name",
                                   "bromeliad.id",
                                   "abundance.or.biomass")) %>%
  merge_func(bwg_names) %>%
  sum_func_groups %>%
  select(-func.group) %>%
  group_by(bromeliad.id, pred_prey) %>%
  summarize(biomass = sum(total_biomass)) %>%
  mutate(pred_prey = ifelse(is.na(pred_prey), "unknown", pred_prey)) %>%
  ungroup %>%
  spread(key = pred_prey, value = biomass)


phys %>%
  left_join(group_biomass) %>%
  left_join(decomp)

## get and combine all sites

get_all_insects <- function(site_names = c("Macae","PuertoRico", "French_Guiana")){

  get_insects <- .%>%
    read_site_sheet("bromeliad.final.inverts") %>%
    invert_to_long(category_vars = c("site", "trt.name",
                                     "bromeliad.id",
                                     "abundance.or.biomass")) %>%
    mutate(bromeliad.id = as.character(bromeliad.id))

  ## get all sites, rbind them
  lapply(site_names, get_insects) %>%
    rbind_all

}

get_all_insects() %>%
  merge_func(bwg_names) %>%
  sum_func_groups(grps = list(~site, ~bromeliad.id, ~pred_prey, ~func.group)) %>%
  select(-func.group) %>%
  group_by(site, bromeliad.id, pred_prey) %>%
  summarize(biomass = sum(total_biomass)) %>%
  mutate(pred_prey = ifelse(is.na(pred_prey), "unknown", pred_prey)) %>%
  ungroup %>%
  spread(key = pred_prey, value = biomass)


merged_insect_data <-  %>%
  merge_func(bwg_names)
