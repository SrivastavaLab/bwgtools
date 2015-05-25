[![Travis-CI Build
Status](https://travis-ci.org/SrivastavaLab/bwgtools.png?branch=master)](https://travis-ci.org/SrivastavaLab/bwgtools)

Introduction
============

This is an R package for the bromeliad working group rainfall
experiment. Our intention is to create a set of tools that facilitate
all steps of the process:

-   loading data into R
-   validating the data
-   combining data from different levels
-   performing calculations
-   performing analyses and
-   creating figures

Please [open an issue](https://github.com/SrivastavaLab/bwgtools/issues)
if there is a feature you would like to see, or if you discover an error
or bug!

Installation
============

`bwgtools` can be installed directly from Github using devtools:

    install.packages("devtools") # if you don't have devtools
    library(devtools)
    install_github("SrivastavaLab/bwgtools", dependencies = TRUE)

Loading data into R
===================

Accessing Dropbox
-----------------

`bwgtools` uses [rdrop2](https://github.com/karthik/rdrop2) to access
your Dropbox account, then uses
[readxl](https://github.com/hadley/readxl) to download the data and read
it directly into R. When you first run `library(bwgtools)` you will see
the following message:

    Welcome to the bwg R package! in order to obtain data from the BWG dropbox folder, you need to authorize R to access your dropbox. run the following commands: 
      library(rdrop2) 
      drop_acc() 
     then enter your username and password. This should only need to be done once per directory.

This will create a file called `.httr-oauth` in your directory, which
will contain your login credentials for Dropbox. **Remember to add this
file to your .gitignore if you are using git**. For more information,
see `?rdrop2::drop_auth`.

Obtaining data
--------------

Once you have authenticated with Dropbox, you can read data directly
into R . For example, the function `read_sheet_site` will get a single
tab from a single excel file (ie, a single site):

    macae <- read_site_sheet("Macae", "leaf.waterdepths")

The first argument to this function can either be the name of a site
(`"Macae"`, in the example above), **or** a path to the location of the
file on your hard drive. In this README we are going to use the latter
approach. This has two advantages: slightly faster (nothing needs to
download) and it will work non-interactively (for example when using
knitr).

the major *disadvantage* is that your local version of the data may be
behind the official version on the Dropbox website. To be safe, use the
online version whenever you can.

    library(bwgtools)

    ## Welcome to the bwg R package! in order to obtain data from the BWG dropbox folder, you need to authorize R to access your dropbox. run the following commands: 
    ##   library(rdrop2) 
    ##    drop_acc() 
    ##  then enter your username and password. This should only need to be done once per directory.

    macae <- read_site_sheet(offline("Macae"), "leaf.waterdepths")

    ## you downloaded that file already! reading from disk

    knitr::kable(head(macae))

<table>
<thead>
<tr class="header">
<th align="left">site</th>
<th align="left">trt.name</th>
<th align="left">bromeliad.id</th>
<th align="left">date</th>
<th align="right">depth.centre.measure.first</th>
<th align="right">depth.leafa.measure.first</th>
<th align="right">depth.leafb.measure.first</th>
<th align="right">depth.centre.water.first</th>
<th align="right">depth.leafa.water.first</th>
<th align="right">depth.leafb.water.first</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td align="left">macae</td>
<td align="left">mu0.1k0.5</td>
<td align="left">B24</td>
<td align="left">2013-03-15</td>
<td align="right">NA</td>
<td align="right">NA</td>
<td align="right">NA</td>
<td align="right">147.0</td>
<td align="right">0.0</td>
<td align="right">60.0</td>
</tr>
<tr class="even">
<td align="left">macae</td>
<td align="left">mu0.1k0.5</td>
<td align="left">B24</td>
<td align="left">2013-03-16</td>
<td align="right">NA</td>
<td align="right">NA</td>
<td align="right">NA</td>
<td align="right">133.3</td>
<td align="right">31.6</td>
<td align="right">53.3</td>
</tr>
<tr class="odd">
<td align="left">macae</td>
<td align="left">mu0.1k0.5</td>
<td align="left">B24</td>
<td align="left">2013-03-17</td>
<td align="right">NA</td>
<td align="right">NA</td>
<td align="right">NA</td>
<td align="right">111.0</td>
<td align="right">5.3</td>
<td align="right">65.1</td>
</tr>
<tr class="even">
<td align="left">macae</td>
<td align="left">mu0.1k0.5</td>
<td align="left">B24</td>
<td align="left">2013-03-18</td>
<td align="right">NA</td>
<td align="right">NA</td>
<td align="right">NA</td>
<td align="right">107.2</td>
<td align="right">12.6</td>
<td align="right">67.2</td>
</tr>
<tr class="odd">
<td align="left">macae</td>
<td align="left">mu0.1k0.5</td>
<td align="left">B24</td>
<td align="left">2013-03-19</td>
<td align="right">NA</td>
<td align="right">NA</td>
<td align="right">NA</td>
<td align="right">104.8</td>
<td align="right">21.5</td>
<td align="right">53.4</td>
</tr>
<tr class="even">
<td align="left">macae</td>
<td align="left">mu0.1k0.5</td>
<td align="left">B24</td>
<td align="left">2013-03-20</td>
<td align="right">NA</td>
<td align="right">NA</td>
<td align="right">NA</td>
<td align="right">94.3</td>
<td align="right">20.2</td>
<td align="right">74.3</td>
</tr>
</tbody>
</table>

This approach works for loading a single tab; we can also load and
combine the same tab across all sites, with a single function:

    library(dplyr)
    library(knitr)
    c("Argentina", "French_Guiana", "Colombia",
      "Macae", "PuertoRico","CostaRica") %>%
      sapply(offline) %>%
      combine_tab("site.info") %>% 
      head %>% 
      kable

<table>
<thead>
<tr class="header">
<th align="left">site.name</th>
<th align="right">combined.correction.factor</th>
<th align="right">mean.catchment.area</th>
<th align="right">effective.catchment.area</th>
<th align="left">identity.bromeliad.species</th>
<th align="right">natural.detrital.species.1.15n</th>
<th align="right">natural.detrital.species.2.15n</th>
<th align="right">fertilized.detrital.species.1.15n</th>
<th align="right">fertilized.detrital.species.2.15n</th>
<th align="right">natural.bromeliad.15n</th>
<th align="right">natural.bromeliad.percentn</th>
<th align="right">natural.bromeliad.percentc</th>
<th align="left">identity.15n.detrital.species.1</th>
<th align="left">identity.15n.detrital.species.2</th>
<th align="left">identity.leafpack.species.1</th>
<th align="left">identity.leafpack.species.2</th>
<th align="left">start.water.addition</th>
<th align="left">last.day.sample</th>
<th align="left">ibutton.frequency</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td align="left">argentina</td>
<td align="right">0.3570</td>
<td align="right">1039.533</td>
<td align="right">371.1133</td>
<td align="left">aechmea.distichantha</td>
<td align="right">NA</td>
<td align="right">NA</td>
<td align="right">NA</td>
<td align="right">NA</td>
<td align="right">NA</td>
<td align="right">NA</td>
<td align="right">NA</td>
<td align="left">NA</td>
<td align="left">NA</td>
<td align="left">myrcianthes.cisplatensis</td>
<td align="left">NA</td>
<td align="left">2013-10-10</td>
<td align="left">2013-12-16</td>
<td align="left">hour</td>
</tr>
<tr class="even">
<td align="left">frenchguiana</td>
<td align="right">0.3800</td>
<td align="right">1060.000</td>
<td align="right">402.8000</td>
<td align="left">vriesea.splendens</td>
<td align="right">0.46</td>
<td align="right">NA</td>
<td align="right">1148.70000</td>
<td align="right">NA</td>
<td align="right">1.86</td>
<td align="right">1.0400000</td>
<td align="right">50.62000</td>
<td align="left">Melastomataceae</td>
<td align="left">NA</td>
<td align="left">duguetia.pycnastera</td>
<td align="left">eperua.grandiflora</td>
<td align="left">2012-11-01</td>
<td align="left">2013-01-10</td>
<td align="left">hour</td>
</tr>
<tr class="odd">
<td align="left">colombia</td>
<td align="right">0.3613</td>
<td align="right">2297.898</td>
<td align="right">830.2305</td>
<td align="left">NA</td>
<td align="right">-1.46</td>
<td align="right">-0.3</td>
<td align="right">0.36653</td>
<td align="right">0.36701</td>
<td align="right">-3.56</td>
<td align="right">0.7027134</td>
<td align="right">46.06465</td>
<td align="left">alnus.acuminata</td>
<td align="left">melastomatacea</td>
<td align="left">alnus.acuminata</td>
<td align="left">melastomatacea</td>
<td align="left">2013-04-03</td>
<td align="left">2013-06-09</td>
<td align="left">hour</td>
</tr>
<tr class="even">
<td align="left">macae</td>
<td align="right">0.2700</td>
<td align="right">1218.000</td>
<td align="right">328.8600</td>
<td align="left">neoregelia.cruenta</td>
<td align="right">NA</td>
<td align="right">NA</td>
<td align="right">6984.80000</td>
<td align="right">NA</td>
<td align="right">NA</td>
<td align="right">NA</td>
<td align="right">NA</td>
<td align="left">eugenia.uniflora</td>
<td align="left">NA</td>
<td align="left">eugenia.uniflora</td>
<td align="left">NA</td>
<td align="left">2013-03-15</td>
<td align="left">2013-05-21</td>
<td align="left">hour</td>
</tr>
<tr class="odd">
<td align="left">puertorico</td>
<td align="right">0.3877</td>
<td align="right">1110.140</td>
<td align="right">43.4013</td>
<td align="left">guzmania</td>
<td align="right">NA</td>
<td align="right">NA</td>
<td align="right">NA</td>
<td align="right">NA</td>
<td align="right">NA</td>
<td align="right">NA</td>
<td align="right">NA</td>
<td align="left">melostomataceae</td>
<td align="left">NA</td>
<td align="left">dacryodes.excelsa</td>
<td align="left">dendropanax.arboreus</td>
<td align="left">2014-03-23</td>
<td align="left">2014-05-29</td>
<td align="left">hour</td>
</tr>
<tr class="even">
<td align="left">costarica</td>
<td align="right">0.3970</td>
<td align="right">1622.000</td>
<td align="right">643.9340</td>
<td align="left">guzmania.spp</td>
<td align="right">NA</td>
<td align="right">NA</td>
<td align="right">NA</td>
<td align="right">NA</td>
<td align="right">-1.66</td>
<td align="right">0.4500000</td>
<td align="right">43.78000</td>
<td align="left">conostegia.xalapensis</td>
<td align="left">NA</td>
<td align="left">conostegia.xalapensis</td>
<td align="left">NA</td>
<td align="left">2012-10-06</td>
<td align="left">2012-12-14</td>
<td align="left">hour</td>
</tr>
</tbody>
</table>

Validating the data
===================

We can also do some basic checking

    check_names(macae)

Future plans
------------

We want to use this package to store functions which reproduce all of
the analyses of the Bromeliad Working Group.

### Licence

We release the code in this repository under the MIT software license.
see text of license [here](LICENSE)
