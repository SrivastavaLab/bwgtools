# delete everything from memory -------------------------------------------
rm(list=ls(all=TRUE))


# load data frame ---------------------------------------------------------


# load packages -----------------------------------------------------------

library(dplyr)
library(tidyr)
library(ggplot2)


# fix data ----------------------------------------------------------------

rainfall <- rainfall %>%
  rename(trt.name = tratamento, day = dia, rain = precipitacao)

# what does the rainfall distribution mean? -------------------------------

#function to calculate the length of a sequence of zeroes in a vector
testvec <- rnbinom(30,size = 1, prob = 0.8)

#a function to count the largest number of zeros in a seq
#by Andrew MacDonald
n_max_zero <- function(vec){
  testvec_list <- rle(vec)
  where_zero <- which(testvec_list$values == 0)
  testvec_list$lengths[where_zero]
}
testvec
n_max_zero(testvec)

#pipe the function to get the total number and duration of chunks of zero rain

seq_no_rain <- rainfall %>% 
  group_by(trt.name) %>% 
  filter(day > 12) %>%
  do(nzero = n_max_zero(.$rain)) %>%
  mutate(maximum_length_cdd = max(nzero),
         times_max_cdd_occur = sum(nzero == max(nzero))) %>%
  select(-nzero)

no_rain_days <- rainfall %>%
  group_by(trt.name) %>%
  do(nzero = n_max_zero(.$rain)) %>%
  mutate(rainless_days =  sum(nzero),
         mean_length_cdd = mean(nzero),
         sd_length_cdd = sd(nzero, na.rm=TRUE),
         number_events_cdd_initial = length(nzero),
         number_events_cdd = length(nzero) - 1) %>%
  select(-nzero) %>%
  left_join(seq_no_rain)
no_rain_days


#given the control treatment, what is the distribution of rainfall?
rain_control <- rainfall %>%
  filter(rain > 0, trt.name =="Controle") %>%
  summarise(quantile10 = quantile(rain, 0.1),
            quantile25 = quantile(rain, 0.25),
            quantile50 = quantile(rain, 0.5),
            quantile75 = quantile(rain, 0.75),
            quantile90 = quantile(rain, 0.9),
            quantile99 = quantile(rain, 0.99))

#create a data frame only with the days that rained
rains <- rainfall %>%
  filter(rain > 0) %>%
  group_by(trt.name) %>%
  summarise(small.event = sum(rain <= rain_control$quantile10),
            event.25 = sum(rain > rain_control$quantile10 & rain <= rain_control$quantile25),
            event.50 = sum(rain > rain_control$quantile25 & rain <= rain_control$quantile50),
            event.75 = sum(rain > rain_control$quantile50 & rain <= rain_control$quantile75),
            event.90 = sum(rain > rain_control$quantile75 & rain <= rain_control$quantile90),
            big.event = sum(rain >= rain_control$quantile99),
            total.rainfall = sum(rain), 
            mean_event_size = mean(rain),
            max_event_size = max(rain), 
            min_event_size = min(rain),
            q10 = mean(quantile(rain, 0.1)),
            q25 = mean(quantile(rain, 0.25)),
            q50 = mean(quantile(rain, 0.5)),
            q75 = mean(quantile(rain, 0.75)),
            q90 = mean(quantile(rain, 0.9)),
            q99 = mean(quantile(rain, 0.99))) %>%
  left_join(no_rain_days)
head(rains)

#now, with your data in hand, summarise the characteristics of your rainfall
#distribution
raindist <- rainfall %>%
  group_by(trt.name) %>%
  summarise(number_of_events = sum(rain > 0)) %>%
  left_join(rains)

write.table(raindist, "raindist.xls", sep="\t", row.names = FALSE)

