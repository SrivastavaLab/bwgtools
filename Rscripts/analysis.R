## analysis file!
library(bwg)
library("tidyr")
library(dplyr)
library(ggplot2)

## get just Macae --- See here @nacmarino
mac <- read_site_sheet("Macae", "leaf.waterdepths")
cr <- read_site_sheet("CostaRica", "leaf.waterdepths")

leaf_depth_list <- get_all_sites(sheetname = "leaf.waterdepths")


all_leaf <- rbind_all(leaf_depth_list)
## write a function that combines the data and also checks it
## not in that order

## date to date
## control the day of the experiment for each bromeliad
## the first day of the experiment is the first non-NA

## proof of concept for macae

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

