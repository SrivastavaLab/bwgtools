
# getting started ---------------------------------------------------------

rm(list=ls(all=TRUE))


# loading packages --------------------------------------------------------
library(tidyr)
library(dplyr)
library(bwgtools)


# loading data file -------------------------------------------------------

mac <- read_site_sheet("Macae", "leaf.waterdepths")

# check the file ----------------------------------------------------------

head(mac)
str(mac)

# start working with it ---------------------------------------------------

#function to turn the table into long format
longwater <- function(df) {
  measures  <- df %>%
    gather("data_name", "depth", starts_with("depth")) %>%
    separate(data_name, into = c("depth_word", "leaf", "first_or_second","first")) %>%
    select(-depth_word, -first) %>%
    filter(!is.na(depth))

  return(measures)
}

#add the day of the experiment plus the long format to the data
calcs <- mac %>%
  group_by(trt.name) %>%
  mutate(nday = seq_along(date)) %>%
  longwater()


# start calculations ------------------------------------------------------

#calculate the number of days the tanks dried out
n.dry  <- calcs %>%
  group_by(trt.name, nday) %>%   #for each treatment, in each day
  summarise(n.tanks = sum(depth == 0), #how many tanks were dry?
            not.dry = sum(sum(depth == 0))==0,  #are there any tanks that were not dry?
            one.tank = sum(sum(depth == 0))==1, #are there at least one tank that is dry?
            two.tanks = sum(sum(depth == 0))==2) %>% #are there at least three tanks that are dry?
  group_by(trt.name) %>%  #for each treatment, tell me how many days...
  summarise(no_tank_dry = sum(not.dry > 0), #no tank was dry?
            one_tank_dry = sum(one.tank > 0), #at least one tank was dry?
            two_tanks_dry = sum(two.tanks >0)) #at least two tanks were dry? #at least three tanks were dry?
n.dry

#calculate
