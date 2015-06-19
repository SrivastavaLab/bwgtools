# README
Andrew MacDonald  
May 25, 2015  

[![Travis-CI Build Status](https://travis-ci.org/SrivastavaLab/bwgtools.png?branch=master)](https://travis-ci.org/SrivastavaLab/bwgtools)

# Introduction
This is an R package for the bromeliad working group rainfall experiment. Our intention is to create a set of tools that facilitate all steps of the process:

* loading data into R
* combining data from different replicates
* performing calculations

At present the package allows each group of authors to obtain the datasets they will need to **begin** their analysis.

Please [open an issue](https://github.com/SrivastavaLab/bwgtools/issues) if there is a feature you would like to see, or if you discover an error or bug!

# Installation

`bwgtools` can be installed directly from Github using devtools:

```r
install.packages("devtools") # if you don't have devtools
library(devtools)
install_github("SrivastavaLab/bwgtools", dependencies = TRUE)
```

# Accessing Dropbox

`bwgtools` uses [rdrop2](https://github.com/karthik/rdrop2) to access your Dropbox account, then uses [readxl](https://github.com/hadley/readxl) to download the data and read it directly into R. When you first run `library(bwgtools)` you will see the following message:


```r
library(bwgtools)
```

```
## Welcome to the bwg R package! in order to obtain data from the BWG dropbox folder, you need to authorize R to access your dropbox. run the following commands:
##   library(rdrop2)
##   drop_auth(cache = FALSE)
## Then enter your username and password. This should only need to be done when downloading the data.
```

## Important Note: Protect your account!

**In Dropbox:** by default, `drop_auth()` saves your Dropbox login to a file called `.httr-oauth`. Of course, we don't want this shared with everyone in our Dropbox folder, as they would then be able to access your personal Dropbox account! Therefore, we set `cache=FALSE`. This will require us to re-authenticate every time we want to download fresh data. This should be a quick and painless process, especially if you are already logged in on your computer. However, bwgtools should work from any computer connected to the internet, provided that you have your Dropbox username and password.

**Working outside of Dropbox:** running `drop_acc()` or `drop_auth()` will create a file called `.httr-oauth` in your directory, which will contain your login credentials for Dropbox. **Remember to add this file to your .gitignore if you are using git**. For more information, see `?rdrop2::drop_auth`. 

# Reading a single sheet

Once you have authenticated with Dropbox, you can read data directly into R. To obtain a single tab (for example, the "leaf.waterdepths" tab) for a single site (for example, Macae), use the function `read_sheet_site`:


```r
macae <- read_site_sheet("Macae", "leaf.waterdepths")
```

```
## [1] "fetching from dropbox"
```

```
## 
##  /tmp/RtmptoY2S1/Drought_data_Macae.xlsx on disk 311.868 KB
```

```r
knitr::kable(head(macae))
```



site    trt.name    bromeliad.id   date          depth.centre.measure.first   depth.leafa.measure.first   depth.leafb.measure.first   depth.centre.water.first   depth.leafa.water.first   depth.leafb.water.first
------  ----------  -------------  -----------  ---------------------------  --------------------------  --------------------------  -------------------------  ------------------------  ------------------------
macae   mu0.1k0.5   B24            2013-03-15                            NA                          NA                          NA                      147.0                       0.0                      60.0
macae   mu0.1k0.5   B24            2013-03-16                            NA                          NA                          NA                      133.3                      31.6                      53.3
macae   mu0.1k0.5   B24            2013-03-17                            NA                          NA                          NA                      111.0                       5.3                      65.1
macae   mu0.1k0.5   B24            2013-03-18                            NA                          NA                          NA                      107.2                      12.6                      67.2
macae   mu0.1k0.5   B24            2013-03-19                            NA                          NA                          NA                      104.8                      21.5                      53.4
macae   mu0.1k0.5   B24            2013-03-20                            NA                          NA                          NA                       94.3                      20.2                      74.3

## Working offline
The first argument to this function can either be the name of a site (`"Macae"`, in the example above), **or** a path to the location of the file on your hard drive. For example, on my (Andrew's) computer, the path to Dropbox is:

```
../../../Dropbox
```

So I could read in my local copy of the data like this:


```r
macae <- read_site_sheet("../../../Dropbox/BWG Drought Experiment/raw data/Drought_data_Macae.xlsx", "leaf.waterdepths")
```

```
## you downloaded that file already! reading from disk
```

This is an example of a _relative path_; the symbol `..` means "one directory above my current location". This is the relative path _from_ the directory where I am developing `bwgtools` _to_ the directory where the Macae data is stored, on my machine. There is more information about relative paths [here](http://swcarpentry.github.io/shell-novice/01-filedir.html). 

To save typing, I've made a convenience function that fills in the relative path for you. It requires the name of the sheet you want, and the path from your current working directory to the full Dropbox folder: 


```r
macae <- read_site_sheet(offline("Macae", default.path = "../../../Dropbox/"), "leaf.waterdepths")
```

```
## you downloaded that file already! reading from disk
```

```r
## or, equivalently:
library(magrittr)

macae <- "Macae" %>% 
  offline(default.path = "../../../Dropbox/") %>%  ## use your own path
  read_site_sheet(sheetname = "leaf.waterdepths")
```

```
## you downloaded that file already! reading from disk
```

**PLEASE NOTE**: the major _disadvantage_ of this approach is that your local version of the data may be behind the official version on the Dropbox website. To be safe, use the online version whenever you can.

# Reading multiple sheets

For all our analyses, we will need to collect data from all sites. ; we can also load and combine the same tab across all sites, with a single function: `combine_tab()`. This function has two arguments: the first is a vector of all the site names (as spelt in the file names in the `raw data/` folder). The second is the name of the sheet to read (as above). For example, to obtain the "site.info" tab for all sites, use the following command:


```r
library(dplyr)
library(knitr)
c("Argentina", "French_Guiana", "Colombia",
  "Macae", "PuertoRico","CostaRica") %>%
  combine_tab(sheetname = "site.info") %>% 
  head %>% 
  kable
```

[1] "fetching from dropbox"
[1] "fetching from dropbox"
[1] "fetching from dropbox"
[1] "fetching from dropbox"
[1] "fetching from dropbox"


site.name       combined.correction.factor   mean.catchment.area   effective.catchment.area  identity.bromeliad.species    natural.detrital.species.1.15n   natural.detrital.species.2.15n   fertilized.detrital.species.1.15n   fertilized.detrital.species.2.15n   natural.bromeliad.15n   natural.bromeliad.percentn   natural.bromeliad.percentc  identity.15n.detrital.species.1   identity.15n.detrital.species.2   identity.leafpack.species.1   identity.leafpack.species.2   start.water.addition   last.day.sample   ibutton.frequency 
-------------  ---------------------------  --------------------  -------------------------  ---------------------------  -------------------------------  -------------------------------  ----------------------------------  ----------------------------------  ----------------------  ---------------------------  ---------------------------  --------------------------------  --------------------------------  ----------------------------  ----------------------------  ---------------------  ----------------  ------------------
argentina                           0.3570              1039.533                   371.1133  aechmea.distichantha                                      NA                               NA                                  NA                                  NA                      NA                           NA                           NA  NA                                NA                                myrcianthes.cisplatensis      NA                            2013-10-10             2013-12-16        hour              
frenchguiana                        0.3800              1060.000                   402.8000  vriesea.splendens                                   0.460000                               NA                          1148.70000                                  NA                1.860000                    1.0400000                     50.62000  Melastomataceae                   NA                                duguetia.pycnastera           eperua.grandiflora            2012-11-01             2013-01-10        hour              
colombia                            0.3613              2297.898                   830.2305  Guzmania.spp                                       -1.093333                        -1.296667                             0.36653                             0.36701               -3.768889                    0.5749411                     45.09735  alnus.acuminata                   melastomatacea                    alnus.acuminata               melastomatacea                2013-04-03             2013-06-09        hour              
macae                               0.2700              1218.000                   328.8600  neoregelia.cruenta                                        NA                               NA                          6984.80000                                  NA                      NA                           NA                           NA  eugenia.uniflora                  NA                                eugenia.uniflora              NA                            2013-03-15             2013-05-21        hour              
puertorico                          0.3877              1110.140                    43.4013  guzmania                                                  NA                               NA                                  NA                                  NA               -2.447934                    1.0181657                     48.83634  melostomataceae                   NA                                dacryodes.excelsa             dendropanax.arboreus          2014-03-23             2014-05-29        hour              
costarica                           0.3970              1622.000                   643.9340  guzmania.spp                                              NA                               NA                                  NA                                  NA               -1.660000                    0.4500000                     43.78000  conostegia.xalapensis             NA                                conostegia.xalapensis         NA                            2012-10-06             2012-12-14        hour              

`combine_tab()` does a little bit more than simply combine the output of `read_site_sheet()`. It also checks the names of the datasets before combining, creates unique bromeliad id numbers, and reshapes the invertebrate data from "wide" to "long" format. Here is a quick explanation of each of these modifications in turn:

## bromeliad ids

Many sites have simply numbered their bromeliads, meaning that there are several bromeliads labelled "1", each in a different site. This is not an error on the part of researchers, however it is a potential danger when combining datasets. To make the bromeliad identification numbers unambiguous, I have combined the site name and the bromeliad name into a new variable, "`site_brom.id`":


```r
phys_data <- c("Argentina", "French_Guiana", "Colombia",
  "Macae", "PuertoRico","CostaRica") %>%
  combine_tab(sheetname = "bromeliad.physical")
```

```
## you downloaded that file already! reading from disk
## you downloaded that file already! reading from disk
## you downloaded that file already! reading from disk
## you downloaded that file already! reading from disk
## you downloaded that file already! reading from disk
## you downloaded that file already! reading from disk
```

```r
kable(phys_data[1:6, 1:3])
```



site_brom.id   site        trt.name  
-------------  ----------  ----------
argentina_1    argentina   mu0.1k0.5 
argentina_26   argentina   mu0.2k0.5 
argentina_30   argentina   mu0.4k0.5 
argentina_20   argentina   mu0.6k0.5 
argentina_29   argentina   mu0.8k0.5 
argentina_15   argentina   mu1k0.5   

## "wide" to "long" format

Most of the tabs have a standard shape -- i.e. a fixed number of columns and rows. The exception is two tabs that contain insect data: `bromeliad.initial.inverts` and `bromeliad.final.inverts`. In order to combine data from these datasets, it is necessary to convert them to "long" format: i.e., to "gather" all insect columns into only three: one for the name of the species (the former column header) one for abundance, and another for biomass:


```r
invert_data <- c("Argentina", "French_Guiana", "Colombia",
  "Macae", "PuertoRico","CostaRica") %>%
  combine_tab(sheetname = "bromeliad.final.inverts")

kable(invert_data[1:6, ])
```



site_brom.id   site          mu     k  species          abundance   biomass
-------------  ----------  ----  ----  --------------  ----------  --------
argentina_1    argentina    0.1   0.5  Coleoptera.33           14        NA
argentina_1    argentina    0.1   0.5  Diptera.276              2        NA
argentina_1    argentina    0.1   0.5  Diptera.61               7        NA
argentina_10   argentina    2.5   1.0  Diptera.250              1        NA
argentina_10   argentina    2.5   1.0  Diptera.276              2        NA
argentina_10   argentina    2.5   1.0  Diptera.61               6        NA

# functional groups -- abundance and biomass. 

Now that we can obtain data on all the invertebrates found at the end of the experiment, we can calculate the abundance and biomass of different *functional groups* by combining species that are in the same category. 
There are two levels of groups into which we can group species:

|pred_prey    |func.group|
|:------------|:---------|
|predator     |engulfer  |
|             |piercer   |
|prey         |scraper   |
|             |gatherer  |
|             |piercer   |
|             |shredder  |


## Accessing functional traits

In order to do this, we will need to access data about all the species ever observed in bromeliads, combining their trait data with their BWG nicknames (the column headers from `bromeliad.final.invert`, now in the column `species` in the output of `combine_tab()`). Formerly, this data was kept in an excel sheet called "Distributions.organisms.correct.xls". Now, several of us have embarked on a project to [improve this data and fill in blanks](https://github.com/SrivastavaLab/bwg_names/). The result of these efforts (which are still ongoing, though mostly complete) is [this .tsv file](https://github.com/SrivastavaLab/bwg_names/blob/master/data/Distributions_organisms_full.tsv). Eventually, it will be added to the master database that the BWG is constructing.  In the meantime, it can be downloaded directly from github using `get_bwg_names()` :


```r
bwg_names <- get_bwg_names()
```

```
## this function thinks there are 23 character columns followed by 54 numeric columns
```

```r
kable(head(bwg_names))
```



key   Name             nickname     Domain      Kingdom    Phyllum      Sub.Phyllum   Class         Sub.Class   Order            Sub.Order     Family            Sub.family   Genus         Species   Taxonomic.resolution   name1   name2   name3   aquatic.terrestrial   func.group      macro.micro   pred_prey    BS1   BS2   BS3   BS4   BS5   BS1.1   BS2.1   BS3.1   BS4.1   BS5.1   AS1   AS2   AS3   AS4   RE1   RE2   RE3   RE4   RE5   RE6   RE7   RE8   DM1   DM2   RF1   RF2   RF3   RF4   RM1   RM2   RM3   RM4   RM5   LO1   LO2   LO3   LO4   LO5   LO6   LO7   FD1   FD2   FD3   FD4   FD5   FD6   FD7   FD8   FG1   FG2   FG3   FG4   FG5   FG6
----  ---------------  -----------  ----------  ---------  -----------  ------------  ------------  ----------  ---------------  ------------  ----------------  -----------  ------------  --------  ---------------------  ------  ------  ------  --------------------  --------------  ------------  ----------  ----  ----  ----  ----  ----  ------  ------  ------  ------  ------  ----  ----  ----  ----  ----  ----  ----  ----  ----  ----  ----  ----  ----  ----  ----  ----  ----  ----  ----  ----  ----  ----  ----  ----  ----  ----  ----  ----  ----  ----  ----  ----  ----  ----  ----  ----  ----  ----  ----  ----  ----  ----  ----  ----
k1    Bryocamptus sp   Copepoda.1   Eukaryota   Animalia   Arthropoda   Crustacea     Maxillopoda   Copepoda    Harpacticoida    NA            Canthocamptidae   NA           Bryocamptus   NA        G                                              aquatic               filter.feeder   micro         prey           3     0     0     0     0       3       0       0       0       0     0     0     0     3     0     3     0     0     0     0     0     0     3     0     3     0     3     0     3     0     0     0     0     0     1     0     2     3     3     0     0     3     2     0     0     0     0     0     0     0     3     3     0     0
k2    Hydracarina      Acari.2      Eukaryota   Animalia   Arthropoda   Chelicerata   Arachnida     Acari       Trombidiformes   Hydracarina   NA                NA           NA            NA        SO                                             aquatic               gatherer        micro         prey           3     3     0     0     0       0       3       0       0       0     1     2     0     2     0     0     0     3     0     0     0     0     3     0     3     0     3     0     3     0     0     0     0     0     2     3     3     0     0     0     0     3     0     0     0     0     0     0     3     0     0     0     0     0
k3    Acari sp         Acari.1      Eukaryota   Animalia   Arthropoda   Chelicerata   Arachnida     Acari       NA               NA            NA                NA           NA            NA        O                                              NA                    piercer         micro         predator       3     0     0     0     0       3       0       0       0       0     1     2     0     2     0     0     0     3     0     0     0     0     3     0     3     0     3     0     3     0     0     3     0     0     2     3     3     0     0     0     0     0     0     0     0     0     3     3     0     0     0     0     3     3
k4    Mite sp. 1       Acari.3      Eukaryota   Animalia   Arthropoda   Chelicerata   Arachnida     Acari       NA               NA            NA                NA           NA            NA        O                                              NA                    piercer         micro         predator       3     0     0     0     0       3       0       0       0       0     1     2     0     2     0     0     0     3     0     0     0     0     3     0     3     0     3     0     3     0     0     3     0     0     2     3     3     0     0     0     0     0     0     0     0     0     3     3     0     0     0     0     3     3
k5    Mite sp. 2       Acari.4      Eukaryota   Animalia   Arthropoda   Chelicerata   Arachnida     Acari       NA               NA            NA                NA           NA            NA        O                                              NA                    piercer         micro         predator       3     0     0     0     0       3       0       0       0       0     1     2     0     2     0     0     0     3     0     0     0     0     3     0     3     0     3     0     3     0     0     3     0     0     2     3     3     0     0     0     0     0     0     0     0     0     3     3     0     0     0     0     3     3
k6    Mite sp. 3       Acari.5      Eukaryota   Animalia   Arthropoda   Chelicerata   Arachnida     Acari       NA               NA            NA                NA           NA            NA        O                                              NA                    piercer         micro         predator       3     0     0     0     0       3       0       0       0       0     1     2     0     2     0     0     0     3     0     0     0     0     3     0     3     0     3     0     3     0     0     3     0     0     2     3     3     0     0     0     0     0     0     0     0     0     3     3     0     0     0     0     3     3

## Merging and plotting functional trait data

The first step in combining the functional traits and the observed insect data is to match insect names in both datasets. This is easily accomplished by the base function `merge()` or by `dplyr::left_join()`. For convenience, `bwgtools::merge_func()` does the latter for you:

```r
### merge with functional groups
invert_traits <- merge_func(invert_data, bwg_names)

kable(head(invert_traits))
```



site_brom.id   site          mu     k  species          abundance   biomass  key    Name                    Domain      Kingdom    Phyllum      Sub.Phyllum   Class     Sub.Class   Order        Sub.Order    Family         Sub.family   Genus   Species   Taxonomic.resolution   name1   name2   name3   aquatic.terrestrial   func.group   macro.micro   pred_prey    BS1   BS2   BS3   BS4   BS5   BS1.1   BS2.1   BS3.1   BS4.1   BS5.1   AS1   AS2   AS3   AS4   RE1    RE2   RE3    RE4   RE5    RE6   RE7   RE8   DM1   DM2    RF1   RF2   RF3   RF4   RM1   RM2   RM3   RM4   RM5   LO1   LO2   LO3   LO4   LO5    LO6    LO7    FD1   FD2    FD3   FD4   FD5    FD6    FD7    FD8    FG1   FG2   FG3   FG4    FG5    FG6
-------------  ----------  ----  ----  --------------  ----------  --------  -----  ----------------------  ----------  ---------  -----------  ------------  --------  ----------  -----------  -----------  -------------  -----------  ------  --------  ---------------------  ------  ------  ------  --------------------  -----------  ------------  ----------  ----  ----  ----  ----  ----  ------  ------  ------  ------  ------  ----  ----  ----  ----  ----  -----  ----  -----  ----  -----  ----  ----  ----  ----  -----  ----  ----  ----  ----  ----  ----  ----  ----  ----  ----  ----  ----  ----  -----  -----  -----  ----  -----  ----  ----  -----  -----  -----  -----  ----  ----  ----  -----  -----
argentina_1    argentina    0.1   0.5  Coleoptera.33           14        NA  k59    Scirtidae sp. 5545      Eukaryota   Animalia   Arthropoda   NA            Insecta   Neoptera    Coleoptera   Polyphaga    Scirtidae      NA           NA      NA        F                                              aquatic               scraper      macro         prey           0     0     3     3     0       0       0       3       3       0     3     3     0     0     0   0.00     0   3.00     1   0.00     3   0.0     0     3   0.00     0   0.0     3     1     0     3     3     0     1     0   0.0     3     0   1.00   0.00   3.00   3.0   3.00   0.0     0   0.00   0.00   0.00   0.00   2.0     3     0   0.00   0.00
argentina_1    argentina    0.1   0.5  Diptera.276              2        NA  k539   Tipulidae sp. 5552      Eukaryota   Animalia   Arthropoda   NA            Insecta   Neoptera    Diptera      Nematocera   Tipulidae      NA           NA      NA        F                                              aquatic               shredder     macro         prey           0     3     3     3     0       0       0       0       3       0     3     3     1     0     0   0.00     0   3.00     3   0.00     0   0.0     0     3   0.00     0   0.0     3     1     3     0     3     0     0     0   0.0     0     3   0.00   0.00   1.00   1.0   3.00   0.0     1   0.00   0.00   1.00   1.00   3.0     0     0   0.00   1.00
argentina_1    argentina    0.1   0.5  Diptera.61               7        NA  k188   Chironomidae sp. 5551   Eukaryota   Animalia   Arthropoda   NA            Insecta   Neoptera    Diptera      Nematocera   Chironomidae   NA           NA      NA        F                                              aquatic               gatherer     macro         prey           0     1     3     0     0       0       0       3       0       0     3     3     3     0     0   0.25     0   2.25     2   0.25     0   0.5     3     1   0.25     0   0.5     0     3     1     0     0     0     0     0   0.5     3     1   0.25   1.75   2.25   2.5   0.75   2.5     0   0.25   0.25   0.75   1.25   0.5     1     2   0.75   0.75
argentina_10   argentina    2.5   1.0  Diptera.250              1        NA  k515   Tabanidae sp. 5576      Eukaryota   Animalia   Arthropoda   NA            Insecta   Neoptera    Diptera      Brachycera   Tabanidae      NA           NA      NA        F                                              aquatic               piercer      macro         predator       0     0     0     3     3       0       0       0       3       3     1     2     0     0     0   0.00     0   3.00     0   0.00     2   0.0     0     3   0.00     0   1.0     3     0     0     0     3     0     0     1   0.0     3     1   0.00   0.00   0.00   1.0   1.00   0.0     0   0.00   0.00   3.00   1.00   0.0     0     0   3.00   0.00
argentina_10   argentina    2.5   1.0  Diptera.276              2        NA  k539   Tipulidae sp. 5552      Eukaryota   Animalia   Arthropoda   NA            Insecta   Neoptera    Diptera      Nematocera   Tipulidae      NA           NA      NA        F                                              aquatic               shredder     macro         prey           0     3     3     3     0       0       0       0       3       0     3     3     1     0     0   0.00     0   3.00     3   0.00     0   0.0     0     3   0.00     0   0.0     3     1     3     0     3     0     0     0   0.0     0     3   0.00   0.00   1.00   1.0   3.00   0.0     1   0.00   0.00   1.00   1.00   3.0     0     0   0.00   1.00
argentina_10   argentina    2.5   1.0  Diptera.61               6        NA  k188   Chironomidae sp. 5551   Eukaryota   Animalia   Arthropoda   NA            Insecta   Neoptera    Diptera      Nematocera   Chironomidae   NA           NA      NA        F                                              aquatic               gatherer     macro         prey           0     1     3     0     0       0       0       3       0       0     3     3     3     0     0   0.25     0   2.25     2   0.25     0   0.5     3     1   0.25     0   0.5     0     3     1     0     0     0     0     0   0.5     3     1   0.25   1.75   2.25   2.5   0.75   2.5     0   0.25   0.25   0.75   1.25   0.5     1     2   0.75   0.75

Now, we need to calculate the total abundance and biomass for every group defined by `site`, `site_brom.id`, and either `pred_prey` or `func.group`. We can write a function that does this for us, and allows us to control the groups that will be summed together. Using `dplyr`'s [non-standard evaluation](http://cran.r-project.org/web/packages/dplyr/vignettes/nse.html) we can define the groups. 

_**REQUEST for feedback**: the syntax here is admittedly a bit strange. Should I just write little convenience functions that perform these tasks? `sum_functional()` and `sum_trophic()` for example?_

For example, to summarize by functional group:

```r
#4 summarize by functional group
func_groups <- sum_func_groups(invert_traits,
                               grps = list(~site,
                                           ~site_brom.id,
                                           ~func.group))
kable(head(func_groups))
```



site        site_brom.id   func.group    total_abundance   total_biomass   total_taxa
----------  -------------  -----------  ----------------  --------------  -----------
argentina   argentina_1    gatherer                    7              NA            1
argentina   argentina_1    scraper                    14              NA            1
argentina   argentina_1    shredder                    2              NA            1
argentina   argentina_10   gatherer                    6              NA            1
argentina   argentina_10   piercer                     1              NA            1
argentina   argentina_10   shredder                    2              NA            1

This is a convenient format for plotting:

```r
library(ggplot2)
## functional group abundance
func_groups %>%
  ggplot(aes(x = as.factor(func.group), y = total_abundance)) +
  geom_point(position = position_jitter(width = 0.25), alpha = 0.5) +
  stat_summary(fun.data = "mean_cl_boot", colour = "red", size = 0.6) +
  facet_wrap(~site, ncol = 1, scales = "free_y") +
  ggtitle("functional group abundance")
```

![](README_files/figure-html/unnamed-chunk-11-1.png) 

To summarize by trophic level group, simply switch `~func.group` to `~pred_prey`:


```r
predprey <- sum_func_groups(invert_traits,
                               grps = list(~site,
                                           ~site_brom.id,
                                           ~pred_prey))

predprey %>%
  ggplot(aes(x = as.factor(pred_prey), y = total_abundance)) +
  geom_point(position = position_jitter(width = 0.25), alpha = 0.5) +
  stat_summary(fun.data = "mean_cl_boot", colour = "red", size = 0.6) +
  facet_wrap(~site, ncol = 1, scales = "free_y") +
  ggtitle("functional group abundance")
```

![](README_files/figure-html/unnamed-chunk-12-1.png) 


## Hydrology -- based on rainfall schedule

_under construction_ right now the only measure I'm working on is derived from the number of consecutive dry days. We can use the metric "longest period of consecutive dry days", and/or quantify their distribution in some other way

## Hydrology -- based on water depths

We have daily water measurements for some sites, and from these we will be able to calculate several measures of "hydrological stability". First, we obtain the `leaf.waterdepths` data in the usual way:


```r
leafwater <- c("Argentina", "French_Guiana", "Colombia",
               "Macae", "PuertoRico","CostaRica") %>%
  #sapply(offline) %>%
  combine_tab("leaf.waterdepths")
```

We also need two other tabs: `site.info` and `bromeliad.physical`. The former states the beginning and end of the experiment, and the latter the block for each bromeliad. These are necessary pieces of information to calculate the date at which each bromeliad was placed in the field and removed from the field. We need this information because some groups did not measure water at the beginning (Costa Rica) or did so irregularly (Costa Rica, Argentina). Thus we need to fill in missing days.


```r
sites <- c("Argentina", "French_Guiana", "Colombia",
           "Macae", "PuertoRico","CostaRica") %>%
  # sapply(offline) %>%
  combine_tab("site.info")

phys <- c("Argentina", "French_Guiana", "Colombia",
          "Macae", "PuertoRico","CostaRica") %>%
  #sapply(offline) %>%
  combine_tab("bromeliad.physical")
```


We can obtain all the hydro variables with one compound function: `hydro_variables()`:


```r
hydro <- hydro_variables(waterdata = leafwater,
                         sitedata = sites,
                         physicaldata = phys)
```

```
## Removing all NA groups: data is grouped by site, watered_first
## Joining by: c("site", "trt.name")
## Joining by: c("site_brom.id", "site", "trt.name", "leaf", "watered_first", "date")
```

```r
kable(head(hydro))
```



site        trt.name    leaf     len.depth   n.depth   max.depth   min.depth   mean.depth   var.depth   sd.depth   net_fluct   total_fluct    cv.depth   amplitude     wetness   prop.overflow.days   prop.driedout.days  time.since.minimum 
----------  ----------  ------  ----------  --------  ----------  ----------  -----------  ----------  ---------  ----------  ------------  ----------  ----------  ----------  -------------------  -------------------  -------------------
argentina   mu0.1k0.5   leafa           66         4       64.55        0.00     32.67500    934.6975   30.57282           0             0    93.56641       64.55   0.5061967            0.0151515            0.0151515  NA                 
argentina   mu0.1k0.5   leafb           66         4       42.75        0.00     15.10000    409.0150   20.22412           0             0   133.93456       42.75   0.3532164            0.0151515            0.0303030  NA                 
argentina   mu0.1k1     leafa           66         6       55.50        0.00     13.65000    465.8800   21.58425           0             0   158.12640       55.50   0.2459459            0.0151515            0.0454545  NA                 
argentina   mu0.1k1     leafb           66         6       93.70       18.75     61.08333    735.9147   27.12775           0             0    44.41105       74.95   0.6519032            0.0303030            0.0000000  NA                 
argentina   mu0.1k2     leafa           66        10       73.50        0.00     27.51000    893.4821   29.89117           0             0   108.65566       73.50   0.3742857            0.0151515            0.0757576  NA                 
argentina   mu0.1k2     leafb           66        10       56.10        0.00     17.93000    565.3640   23.77738           0             0   132.61229       56.10   0.3196078            0.0151515            0.0909091  NA                 

This function should "just work". As you can see, it is performing one check (removing any groups which have all NA records) and performs two joins (to correct the errors discussed above).

It seems that the centre leaf is not like the others. Therefore by default the fucntion removes it. If you want it anyway, set `rm_centre = TRUE` (Note the Canadian spelling).

```r
hydro2 <- hydro_variables(waterdata = leafwater,
                         sitedata = sites,
                         physicaldata = phys, rm_centre = FALSE)
kable(head(hydro2))
```

The default behaviour is to calculate all these metrics at the level of the leaf well, the same scale at which the measurements were taken. If you want you can obtain these same calculations AFTER first averaging water depths across all leaves of a plant, within each day. That is, we can make these same calculations at the scale of the bromeliad:


```r
hydro3 <- hydro_variables(waterdata = leafwater,
                         sitedata = sites,
                         physicaldata = phys, aggregate_leaves = TRUE)
kable(head(hydro3))
```


### Licence
We release the code in this repository under the MIT software license. see text of license [here](LICENSE)
