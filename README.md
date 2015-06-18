[![Travis-CI Build
Status](https://travis-ci.org/SrivastavaLab/bwgtools.png?branch=master)](https://travis-ci.org/SrivastavaLab/bwgtools)

Introduction
============

This is an R package for the bromeliad working group rainfall
experiment. Our intention is to create a set of tools that facilitate
all steps of the process:

-   loading data into R
-   combining data from different replicates
-   performing calculations

At present the package allows each group of authors to obtain the
datasets they will need to **begin** their analysis.

Please [open an issue](https://github.com/SrivastavaLab/bwgtools/issues)
if there is a feature you would like to see, or if you discover an error
or bug!

Installation
============

`bwgtools` can be installed directly from Github using devtools:

    install.packages("devtools") # if you don't have devtools
    library(devtools)
    install_github("SrivastavaLab/bwgtools", dependencies = TRUE)

Accessing Dropbox
=================

`bwgtools` uses [rdrop2](https://github.com/karthik/rdrop2) to access
your Dropbox account, then uses
[readxl](https://github.com/hadley/readxl) to download the data and read
it directly into R. When you first run `library(bwgtools)` you will see
the following message:

    library(bwgtools)

    ## Welcome to the bwg R package! in order to obtain data from the BWG dropbox folder, you need to authorize R to access your dropbox. run the following commands:
    ##   library(rdrop2)
    ##   drop_auth(cache = FALSE)
    ## Then enter your username and password. This should only need to be done when downloading the data.

Important Note: Protect your account!
-------------------------------------

**In Dropbox:** by default, `drop_auth()` saves your Dropbox login to a
file called `.httr-oauth`. Of course, we don't want this shared with
everyone in our Dropbox folder, as they would then be able to access
your personal Dropbox account! Therefore, we set `cache=FALSE`. This
will require us to re-authenticate every time we want to download fresh
data. This should be a quick and painless process, especially if you are
already logged in on your computer. However, bwgtools should work from
any computer connected to the internet, provided that you have your
Dropbox username and password.

**Working outside of Dropbox:** running `drop_acc()` or `drop_auth()`
will create a file called `.httr-oauth` in your directory, which will
contain your login credentials for Dropbox. **Remember to add this file
to your .gitignore if you are using git**. For more information, see
`?rdrop2::drop_auth`.

Reading a single sheet
======================

Once you have authenticated with Dropbox, you can read data directly
into R. To obtain a single tab (for example, the "leaf.waterdepths" tab)
for a single site (for example, Macae), use the function
`read_sheet_site`:

    macae <- read_site_sheet("Macae", "leaf.waterdepths")

    ## [1] "fetching from dropbox"

    ## 
    ##  /tmp/Rtmp5TA7Q6/Drought_data_Macae.xlsx on disk 311.868 KB

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

Working offline
---------------

The first argument to this function can either be the name of a site
(`"Macae"`, in the example above), **or** a path to the location of the
file on your hard drive. For example, on my (Andrew's) computer, the
path to Dropbox is:

    ../../../Dropbox

So I could read in my local copy of the data like this:

    macae <- read_site_sheet("../../../Dropbox/BWG Drought Experiment/raw data/Drought_data_Macae.xlsx", "leaf.waterdepths")

    ## you downloaded that file already! reading from disk

This is an example of a *relative path*; the symbol `..` means "one
directory above my current location". This is the relative path *from*
the directory where I am developing `bwgtools` *to* the directory where
the Macae data is stored, on my machine. There is more information about
relative paths
[here](http://swcarpentry.github.io/shell-novice/01-filedir.html).

To save typing, I've made a convenience function that fills in the
relative path for you. It requires the name of the sheet you want, and
the path from your current working directory to the full Dropbox folder:

    macae <- read_site_sheet(offline("Macae", default.path = "../../../Dropbox/"), "leaf.waterdepths")

    ## you downloaded that file already! reading from disk

    ## or, equivalently:
    library(magrittr)

    macae <- "Macae" %>% 
      offline(default.path = "../../../Dropbox/") %>%  ## use your own path
      read_site_sheet(sheetname = "leaf.waterdepths")

    ## you downloaded that file already! reading from disk

**PLEASE NOTE**: the major *disadvantage* of this approach is that your
local version of the data may be behind the official version on the
Dropbox website. To be safe, use the online version whenever you can.

Reading multiple sheets
=======================

For all our analyses, we will need to collect data from all sites. ; we
can also load and combine the same tab across all sites, with a single
function: `combine_tab()`. This function has two arguments: the first is
a vector of all the site names (as spelt in the file names in the
`raw data/` folder). The second is the name of the sheet to read (as
above). For example, to obtain the "site.info" tab for all sites, use
the following command:

    library(dplyr)
    library(knitr)
    c("Argentina", "French_Guiana", "Colombia",
      "Macae", "PuertoRico","CostaRica") %>%
      combine_tab(sheetname = "site.info") %>% 
      head %>% 
      kable

[1] "fetching from dropbox" [1] "fetching from dropbox" [1] "fetching
from dropbox" [1] "fetching from dropbox" [1] "fetching from dropbox"

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
<td align="right">0.460000</td>
<td align="right">NA</td>
<td align="right">1148.70000</td>
<td align="right">NA</td>
<td align="right">1.860000</td>
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
<td align="left">Guzmania.spp</td>
<td align="right">-1.093333</td>
<td align="right">-1.296667</td>
<td align="right">0.36653</td>
<td align="right">0.36701</td>
<td align="right">-3.768889</td>
<td align="right">0.5749411</td>
<td align="right">45.09735</td>
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
<td align="right">-2.447934</td>
<td align="right">1.0181657</td>
<td align="right">48.83634</td>
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
<td align="right">-1.660000</td>
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

`combine_tab()` does a little bit more than simply combine the output of
`read_site_sheet()`. It also checks the names of the datasets before
combining, creates unique bromeliad id numbers, and reshapes the
invertebrate data from "wide" to "long" format. Here is a quick
explanation of each of these modifications in turn:

bromeliad ids
-------------

Many sites have simply numbered their bromeliads, meaning that there are
several bromeliads labelled "1", each in a different site. This is not
an error on the part of researchers, however it is a potential danger
when combining datasets. To make the bromeliad identification numbers
unambiguous, I have combined the site name and the bromeliad name into a
new variable, "`site_brom.id`":

    phys_data <- c("Argentina", "French_Guiana", "Colombia",
      "Macae", "PuertoRico","CostaRica") %>%
      combine_tab(sheetname = "bromeliad.physical")

    ## you downloaded that file already! reading from disk
    ## you downloaded that file already! reading from disk
    ## you downloaded that file already! reading from disk
    ## you downloaded that file already! reading from disk
    ## you downloaded that file already! reading from disk
    ## you downloaded that file already! reading from disk

    kable(phys_data[1:6, 1:3])

<table>
<thead>
<tr class="header">
<th align="left">site_brom.id</th>
<th align="left">site</th>
<th align="left">trt.name</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td align="left">argentina_1</td>
<td align="left">argentina</td>
<td align="left">mu0.1k0.5</td>
</tr>
<tr class="even">
<td align="left">argentina_26</td>
<td align="left">argentina</td>
<td align="left">mu0.2k0.5</td>
</tr>
<tr class="odd">
<td align="left">argentina_30</td>
<td align="left">argentina</td>
<td align="left">mu0.4k0.5</td>
</tr>
<tr class="even">
<td align="left">argentina_20</td>
<td align="left">argentina</td>
<td align="left">mu0.6k0.5</td>
</tr>
<tr class="odd">
<td align="left">argentina_29</td>
<td align="left">argentina</td>
<td align="left">mu0.8k0.5</td>
</tr>
<tr class="even">
<td align="left">argentina_15</td>
<td align="left">argentina</td>
<td align="left">mu1k0.5</td>
</tr>
</tbody>
</table>

### Licence

We release the code in this repository under the MIT software license.
see text of license [here](LICENSE)
