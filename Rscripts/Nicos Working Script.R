
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
dried_when_leaf <- calcs %>% #take water depth
  group_by(trt.name, leaf) %>% #for each leaf of each bromeliad
  mutate(minimum_depth = min(depth), #what was the minimum water depth for each tank
         length_exp = max(nday)) %>%  #what was the entire length of the experiment
  filter(depth == minimum_depth) %>% #show me only the data from the days where water depth was at its minimum
  mutate(times_minimum = length(nday), #how many times each tank got to its minimum?
         when_last_day_minimum = max(nday), #when was the last time the bromeliad got to its minimum?
         days_since_last_minimum = length_exp - max(nday)) %>% #how many days since it got to its min water depth?
  summarise(times_mininum = min(times_minimum),
            when_last_day_minimum = min(when_last_day_minimum), #number of times any tank got to its minimum (doesn't need to be zero, but minimum)
            days_since_last_minimum = min(days_since_last_minimum)) #how long as it been since any tank got to its minimum?
#in the 'summarise' that I just did, I used the 'min' command just to collapse the repeated values into one single value

#from here I'll do the calculation for the bromeliad - THIS IS WHAT WE WANT
dried_when_brom <- dried_when_leaf %>%
  group_by(trt.name) %>%
  summarise(mean.times_min = round(mean(times_mininum)),
            when_times_minimum = max(times_mininum),
            times_min = sum(times_mininum),
            mean.last_min = round(mean(when_last_day_minimum)),
            when_last_day_minimum = max(when_last_day_minimum), #most recent fall in water depth
            mean.days_since = round(mean(days_since_last_minimum)),
            days_since_last_minimum = max(days_since_last_minimum)) #how many days have ellapsed since the last major drop

