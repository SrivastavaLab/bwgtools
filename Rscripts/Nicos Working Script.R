
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
