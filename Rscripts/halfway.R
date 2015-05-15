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

## F
insects_functional <- get_all_insects() %>%
  merge_func(bwg_names) %>%
  # here we include site in the grouping to make bromeliad.id unique
  ## if it were omitted, bromeliads with the name number woiuld be combined
  ## even if they are from different sites
  sum_func_groups(grps = list(~site, ~bromeliad.id, ~pred_prey, ~func.group))

## group by predator or prey, not functional group
insects_functional %>%
  select(-func.group) %>%
  group_by(site, bromeliad.id, pred_prey) %>%
  summarize(biomass = sum(total_biomass)) %>%
  mutate(pred_prey = ifelse(is.na(pred_prey), "unknown", pred_prey)) %>%
  ungroup %>%
  spread(key = pred_prey, value = biomass)

## group by functional group
insects_functional %>%
  gather("quantity", "value", total_abundance, total_biomass, total_taxa, convert = FALSE) %>%
  ungroup %>%
  mutate(func.group = gsub(" ","_", func.group)) %>%
  unite(func_quant, func.group, quantity) %>%
  group_by(site, bromeliad.id, func_quant) %>%
  summarise(total_value = sum(value)) %>%
  spread(func_quant, value = total_value, fill = 0)


## create and merge


groups(redone)

redone$newname <- paste0(redone$func.group, ".", redone$quantity)

problem <- redone %>%
  group_by(bromeliad.id,mu,k, newname) %>%
  summarise(total_value = sum(value)) %>%
  spread(newname, value = total_value, fill = 0)

problem$bromeliad.id %>% unique




merged_insect_data <-  %>%
  merge_func(bwg_names)


