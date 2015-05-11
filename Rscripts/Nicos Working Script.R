
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

longwater <- function(df) {
  measures  <- df %>%
    gather("data_name", "depth", starts_with("depth")) %>%
    separate(data_name, into = c("depth_word", "leaf", "first_or_second","first")) %>%
    select(-depth_word, -first) %>%
    filter(!is.na(depth))

  return(measures)
}

longwater(mac)


