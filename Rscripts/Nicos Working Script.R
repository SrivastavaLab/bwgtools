
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
wd_measures <- mac %>%
  group_by(trt.name) %>%
  mutate(nday = seq_along(date)) %>%
  longwater()


# start calculations ------------------------------------------------------

#calculate the number of days the tanks dried out
dry_tanks <- wd_measures %>%
  group_by(trt.name, nday) %>%   #for each treatment, in each day
  summarise(tanks_dry = sum(depth == 0), #how many tanks were dry?
            no_tank_dry = sum(sum(depth == 0))==0,  #are there any tanks that were not dry?
            one_tank_dry = sum(sum(depth == 0))==1, #are there at least one tank that is dry?
            two_tanks_dry = sum(sum(depth == 0))==2) %>% #are there at least two tanks that are dry?
  group_by(trt.name) %>%  #for each treatment, tell me how many days...
  summarise(total_times_dry = sum(tanks_dry),
            no_tank_dry = sum(no_tank_dry > 0), #no tank was dry?
            one_tank_dry = sum(one_tank_dry > 0), #at least one tank was dry?
            two_tanks_dry = sum(two_tanks_dry >0)) #at least two tanks were dry? #at least three tanks were dry?
dry_tanks


#calculate the time available for colonization
when_leaf_dried <- wd_measures %>% #take water depth
  group_by(trt.name, leaf) %>% #for each leaf of each bromeliad
  mutate(minimum_depth = min(depth), #what was the minimum water depth for each tank
         length_exp = max(nday)) %>%  #what was the entire length of the experiment
  filter(depth == minimum_depth) %>% #show me only the data from the days where water depth was at its minimum
  mutate(times_minimum = length(nday), #how many times each tank got to its minimum?
         day_last_minimum = max(nday), #when was the last time the bromeliad got to its minimum?
         days_since_last_minimum = length_exp - max(nday)) %>% #how many days since it got to its min water depth?
  summarise(times_minimum = min(times_minimum),
            day_last_minimum = min(day_last_minimum), #number of times any tank got to its minimum (doesn't need to be zero, but minimum)
            days_since_last_minimum = min(days_since_last_minimum)) #how long as it been since any tank got to its minimum?
#in the 'summarise' that I just did, I used the 'min' command just to collapse the repeated values into one single value

#from here I'll do the calculation for the bromeliad - THIS IS WHAT WE WANT
when_brom_dried <- when_leaf_dried %>%
  group_by(trt.name) %>%
  summarise(mean.times_minimum = round(mean(times_minimum)),
            max.times_minimum = max(times_minimum),
            times_minimum = sum(times_minimum), #dry+minimum
            when_last_day_minimum = max(day_last_minimum), #most recent fall in water depth
            days_since_last_minimum = min(days_since_last_minimum)) #how many days have ellapsed since the last major drop

#calculate the variance in hydrological measures within a bromeliad
tank_properties <- wd_measures %>%
  group_by(trt.name, leaf) %>%
  summarise(max.depth = max(depth),
            min.depth = min(depth),
            amplitude = max(depth) - min(depth),
            wetness = mean(depth)/max(depth),
            overflow.days = sum(depth == max(depth))-1)

bromeliad_properties <- tank_properties %>%
  group_by(trt.name) %>%
  summarise(amplitude = max(max.depth)-min(min.depth), #total difference in amplitude among tanks of the same bromeliad
            wetness_mean = mean(wetness),
            overflow.days = max(overflow.days)) #mean water depth in relation to the maximum


#standard metrics describing a distribution using the water depth, regardless of the tank
hydrological_measures <- wd_measures %>%
  group_by(trt.name) %>%
  summarise(max.depth = max(depth),
            min.depth = min(depth),
            mean.depth = mean(depth),
            var.depth = var(depth),
            sd.depth = sd(depth),
            cv.depth = (100*(sd(depth))/mean(depth)),
            net_fluct = sum(depth - lag(depth), na.rm = TRUE),
            total_fluct = sum(abs(depth - lag(depth)), na.rm = TRUE)) %>%
  left_join(bromeliad_properties) %>%
  left_join(dry_tanks) %>%
  left_join(when_brom_dried)
