## analysis file!
library(bwg)

## get just Macae --- See here @nacmarino
read_site_sheet("Macae", "leaf.waterdepths")

leaf_depth_list <- get_all_sites(sheetname = "leaf.waterdepths")





check_names(leaf_depth_list[[1]])

names(leaf_depth_list[[2]])[1] <- "a"
names(leaf_depth_list[[2]])[3] <- "b"

lapply(leaf_depth_list, check_names)

lapply(leaf_depth_list, function(x) all.equal(names(x), water_sheet_names))

namelist <- lapply(leaf_depth_list, names)
Reduce(intersect, namelist) ## Are there problems?

identical(namelist[[1]], namelist[[2]])

library(dplyr)

all_leaf <- rbind_all(leaf_depth_list)

## date to date
## control the day of the experiment for each bromeliad
## the first day of the experiment is the first non-NA

## proof of concept for macae


mac <- read_site_sheet("Macae", "leaf.waterdepths")
glimpse(mac)
library("tidyr")
longwater <- . %>%
  gather("data_name", "depth", starts_with("depth")) %>%
  separate(data_name, into = c("depth_word", "leaf", "first_or_second","first")) %>%
  filter(!is.na(depth)) %>%
  select(-depth_word, -first)


mac %>%
  longwater %>%
  group_by(bromeliad.id) %>%
  mutate(day_of_exp = dense_rank(date))

### CostaRica

## get just Macae --- See here @nacmarino
cr <- read_site_sheet("CostaRica", "leaf.waterdepths")

library(ggplot2)
cr %>%
  longwater %>%
  group_by(bromeliad.id) %>%
  mutate(day_of_exp = dense_rank(date)) %>%
  separate(trt.name, into = c("mu", "k"), sep = "k") %>%
  mutate(mu = extract_numeric(mu)) %>%
  ggplot(aes(x = date, y = depth, colour = leaf, group = bromeliad.id)) + geom_line() +
  facet_grid(mu~k)

