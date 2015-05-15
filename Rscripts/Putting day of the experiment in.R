
library(readxl)
library(tidyr)
library(dplyr)
library(bwgtools)

cr1 <- read_excel("C:/Users/Nick/Desktop/Costa Rica.xlsx", sheet = 1)

cr <- read_site_sheet("CostaRica", "leaf.waterdepths")

put_day_expt <- cr %>%
  left_join(cr2) %>%
  mutate(julian_measure = strptime(date, "%Y-%m-%d")$yday+1,
         julian_block_start = strptime(start_block, "%Y-%m-%d")$yday+1) %>%
  mutate(day_of_expt = julian_measure - julian_block_start)
