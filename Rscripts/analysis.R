## analysis file!
library(bwgtools)
library("tidyr")
library(dplyr)
library(ggplot2)

## testing ground


# site.info -------------------------------------------

offline <- . %>%
  make_default_path %>%
  paste0("../../../Dropbox/",.)

read_site_sheet(offline("Argentina"), "site.info")
read_site_sheet("Cardoso", "site.info")
read_site_sheet("Colombia", "site.info") ## warnings
read_site_sheet("French_Guiana", "site.info")
read_site_sheet("Macae", "site.info")
read_site_sheet("PuertoRico", "site.info")
read_site_sheet("CostaRica", "site.info")


# site_weather <- get_all_sites(sheetname = "site.info")

sites <- combine_site.info()


get_bwg_names()
# site.weather ----------------------------------------


read_site_sheet("Argentina", "site.weather") ## extra column
read_site_sheet("Cardoso", "site.weather")
read_site_sheet("Colombia", "site.weather")
read_site_sheet("French_Guiana", "site.weather")
read_site_sheet("Macae", "site.weather")
read_site_sheet("PuertoRico", "site.weather")
read_site_sheet("CostaRica", "site.weather")

#site_weather <- get_all_sites(sheetname = "site.weather")

combing_site.weather()

# the_ncol <- lapply(site_weather, ncol)
# sapply(the_ncol, function(x) assertthat::are_equal(x, 5))

# bromeliad.physical ----------------------------------

read_site_sheet(offline("Argentina"), "bromeliad.physical")
read_site_sheet(offline("Cardoso"), "bromeliad.physical")
read_site_sheet("Colombia", "bromeliad.physical") ##
read_site_sheet("French_Guiana", "bromeliad.physical")
read_site_sheet("Macae", "bromeliad.physical")
read_site_sheet("PuertoRico", "bromeliad.physical")
read_site_sheet("CostaRica", "bromeliad.physical")


# get_all_sites(sheetname = "bromeliad.physical")

# combine_bromeliad.physical()
## Doesn't work!


# bromeliad.final.inverts ----------------------------------

read_site_sheet(offline("Argentina"), "bromeliad.final.inverts")
read_site_sheet(offline("Cardoso"), "bromeliad.final.inverts")
read_site_sheet("Colombia", "bromeliad.final.inverts") ##
read_site_sheet("French_Guiana", "bromeliad.final.inverts")
read_site_sheet(offline("Macae"), "bromeliad.final.inverts")
read_site_sheet(offline("PuertoRico"), "bromeliad.final.inverts")
read_site_sheet("CostaRica", "bromeliad.final.inverts")

site_final_insects <- get_all_sites(sheetname = "bromeliad.final.inverts")

lapply(site_final_insects, names)
lapply(site_final_insects, function(x) head(x)[1:7])

## clean Argentina
arg <- site_final_insects[[1]]
names(arg)[which(names(arg)=="????")] <- "UNK"
arg_bwg_name <- names(arg)


arg2 <- read_site_sheet("Argentina", "bromeliad.final.inverts", skip = 1)

names(arg2)[-4]
## get just Macae --- See here @nacmarino
mac <- read_site_sheet("Macae", "leaf.waterdepths")
cr <- read_site_sheet("CostaRica", "leaf.waterdepths")


## how to process a correctly formatted excel sheet

#1. obtain the data

mac_final <- read_site_sheet(offline("Macae"), "bromeliad.final.inverts")
bwg_names <- get_bwg_names()

#2 transform the data
invert_to_long <- function(insect_data){
  insect_data %>%
    ## could use quoted form here
    gather(species, quantity,
           -site, -trt.name,
           -bromeliad.id, -abundance.or.biomass)%>%
    spread(abundance.or.biomass, quantity)%>%
    separate(trt.name, c("mu", "k"), "k")%>%
    mutate(mu = extract_numeric(mu), k = extract_numeric(k))
}


invert_to_long(mac_final)

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

