
# getting started ---------------------------------------------------------

rm(list=ls(all=TRUE))


# loading packages --------------------------------------------------------
library(tidyr)
library(dplyr)
library(bwgtools)
library(readxl)


# loading data file -------------------------------------------------------

mac <- read_site_sheet(offline("Macae"), "leaf.waterdepths")

# check the file ----------------------------------------------------------

head(mac)
str(mac)

# start working with it ---------------------------------------------------


# fix day of the experiment -----------------------------------------------

#function to turn the table into long format
#MUST RUN

#USE NEXT FOR MACAE DATA ONLY!!!
#add the day of the experiment plus the long format to the data
wd_measures <- mac %>% #MACAE DATA ONLY
  longwater() #MACAE DATA ONLY




#I created a support excel spreadsheet containing the day of the start and end of the
#experiment for each treatment according to its temporal block...the excel file with
#the support file is on the folder and should be used until we create a function to
#do it automatically
#load data from the support excel spreadsheet
#sheet 1 - costa rica
#sheet 2 - french guiana
#sheet 3 - puerto rico
# support <- read_excel("../Documents/Documentos/Projetos/BWG/bwg/Rscripts/Support File.xlsx", sheet = 1)
#
#for any other site, run this for the wd_measures
# wd_measures <- mac %>%
#   left_join(support) %>%
#   mutate(julian_measure = strptime(date, "%Y-%m-%d")$yday+1,
#          julian_block_start = strptime(start_block, "%Y-%m-%d")$yday+1) %>%
#   mutate(day_of_expt = (julian_measure - julian_block_start+1)) %>%
#   rename(nday = day_of_expt) %>%
#   select(- finish_block, -julian_measure, -julian_block_start) %>%
#   longwater()

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

write.table(hydrological_measures, "hydrological_costarica.tsv", sep = "\t", row.names = FALSE)



# NEW CALCULATIONS ACCOUNTING FOR SPATIAL VARIANCE ------------------------

when_bromeliad_dried <- wd_measures %>%
  mutate(length_exp = max(nday)) %>%
  filter(depth <= 5) %>%
  group_by(trt.name, leaf) %>%
  mutate(times_minimum = length(nday),
         day_last_minimum = max(nday),
         days_since_last_minimum = length_exp - max(nday)) %>%
  summarise(times_minimum = min(times_minimum),
            day_last_minimum = min(day_last_minimum),
            days_since_last_minimum = min(days_since_last_minimum)) %>%
  group_by(trt.name) %>%
  summarise(mean.times_minimum = round(mean(times_minimum)),
            max.times_minimum = max(times_minimum),
            times_minimum = sum(times_minimum), #dry+minimum
            when_last_day_minimum = max(day_last_minimum), #most recent fall in water depth
            days_since_last_minimum = min(days_since_last_minimum)) #how many days have ellapsed since the last major drop


### calculate leaf values
leaf_responses <- wd_measures %>%
  group_by(trt.name, leaf) %>%
  do(water_summary_calc(.$depth))


wd_measures %>%
  filter(trt.name == "mu1k1") %>%
  select(depth) %>%
  range

brom_leaf_avg <- leaf_responses %>%
  group_by(trt.name) %>%
  select(-leaf) %>%
  summarise_each(funs(mean))


### COMPARING SUBSAMPLING ----------------------------------
## average depths across all leaves
brom_averages <- wd_measures %>%
  group_by(trt.name, nday) %>%
  summarise(mean_depth = mean(depth, na.rm=TRUE),
            n_depth = sum(!is.na(depth)))

## calculate water variables
## for different subsets and full data
fulldat <- brom_averages %>%
  group_by(trt.name) %>%
  do(failwith(NA,water_summary_calc)(.$mean_depth)) %>%
  gather("resp", "value", -trt.name)

subdat <- brom_averages %>%
  group_by(trt.name) %>%
  filter((nday %% 2) == 0) %>%
  do(water_summary_calc(.$mean_depth)) %>%
  gather("resp", "value", -trt.name)

subdat2 <- brom_averages %>%
  group_by(trt.name) %>%
  filter((nday %% 2) == 1) %>%
  do(water_summary_calc(.$mean_depth)) %>%
  gather("resp", "value", -trt.name)



ggplot(fulldat, aes(x = value)) +
  geom_density() +
  geom_density(data = subdat, colour = "blue") +
  geom_density(data = subdat2, colour = "orange") +
  facet_wrap(~resp, scales = "free")


fulldat %>%
  filter(resp == "max.depth") %>%
  .[["value"]] %>%
  max

subdat %>%
  filter(resp == "max.depth") %>%
  .[["value"]] %>%
  max

subdat2 %>%
  filter(resp == "max.depth") %>%
  .[["value"]] %>%
  max

fulldat %>%
  left_join(rename(subdat, value_sub = value)) %>%
  ggplot(aes(x = value, y = value_sub, colour = trt.name)) + geom_point() + facet_wrap(~resp, scales = "free") + geom_abline(intercept = 0, slope = 1)



## checking the order of calculations ----------------

### calculate leaf values

brom_leaf_avg <- wd_measures %>%
  filter(leaf != "centre") %>%
  group_by(trt.name, leaf) %>%
  do(water_summary_calc(.$depth)) %>%
  group_by(trt.name) %>%
  select(-leaf) %>%
  summarise_each(funs(mean))

brom_leaf_avg %>%
  ggplot(aes(x = ))

## at the level of the bromeliad

fulldat <- wd_measures %>%
  filter(leaf != "centre") %>%
  group_by(trt.name, nday) %>%
  summarise(mean_depth = mean(depth, na.rm=TRUE),
            n_depth = sum(!is.na(depth))) %>%
  group_by(trt.name) %>%
  do(water_summary_calc(.$mean_depth)) %>%
  gather("resp", "value", -trt.name)


brom_leaf_avg %>%
  gather("resp", "value_leaf_first", -trt.name) %>%
  left_join(fulldat) %>%
  ggplot(aes(x = value, y = value_leaf_first, colour = trt.name)) +  geom_point() + facet_wrap(~resp, scales = "free") + geom_abline(intercept = 0, slope = 1)




water_summary_calc(rnorm(60, mean = 50))

setwd("C:/Users/Nick/Desktop")
write.table(hydrological_measures, "hydrological_costarica.tsv", sep = "\t", row.names = FALSE)


# NEW CALCULATIONS ACCOUNTING FOR SPATIAL VARIANCE ------------------------

when_bromeliad_dried <- wd_measures %>%
  mutate(length_exp = max(nday)) %>%
  filter(depth <= 5) %>%
  group_by(trt.name, leaf) %>%
  mutate(times_minimum = length(nday),
         day_last_minimum = max(nday),
         days_since_last_minimum = length_exp - max(nday)) %>%
  summarise(times_minimum = min(times_minimum),
            day_last_minimum = min(day_last_minimum),
            days_since_last_minimum = min(days_since_last_minimum)) %>%
  group_by(trt.name) %>%
  summarise(mean.times_minimum = round(mean(times_minimum)),
            max.times_minimum = max(times_minimum),
            times_minimum = sum(times_minimum), #dry+minimum
            when_last_day_minimum = max(day_last_minimum), #most recent fall in water depth
            days_since_last_minimum = min(days_since_last_minimum)) #how many days have ellapsed since the last major drop

brom_properties <- wd_measures %>%
  group_by(trt.name, leaf) %>%
  summarise(amplitude = max(depth) - min(depth),
            wetness = mean(depth)/max(depth),
            overflow.days = sum(depth == max(depth))-1) %>%
  group_by(trt.name) %>%
  summarise(amplitude = mean(amplitude),
            wetness_mean = mean(wetness),
            overflow.days = max(overflow.days))

hydrological_measures <- wd_measures %>%
  group_by(trt.name, nday) %>%
  mutate(mean_depth = mean(depth, na.rm=TRUE)) %>%
  filter(leaf == "leafa") %>%
  group_by(trt.name) %>%
  summarise(max.depth = max(mean_depth),
            min.depth = min(mean_depth),
            mean.depth = mean(mean_depth),
            var.depth = var(mean_depth),
            sd.depth = sd(mean_depth),
            cv.depth = (100*(sd(mean_depth))/mean(mean_depth)),
            net_fluct = sum(mean_depth - lag(mean_depth), na.rm = TRUE),
            total_fluct = sum(abs(mean_depth - lag(mean_depth)), na.rm = TRUE)) %>%
  left_join(brom_properties) %>%
  left_join(when_bromeliad_dried)

setwd("C:/Users/Nick/Desktop")
write.table(hydrological_measures, "hydrological_costarica.tsv", sep = "\t", row.names = FALSE)
