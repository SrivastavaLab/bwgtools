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
-------------------

`bwgtools` uses [rdrop2](https://github.com/karthik/rdrop2) to access
your Dropbox account, then uses
[readxl](https://github.com/hadley/readxl) to download the data and read
it directly into R. When you first run `library(bwgtools)` you will see
the following message:

> Welcome to the bwg R package! in order to obtain data from the BWG
> dropbox folder, you need to authorize R to access your dropbox. run
> the following commands: library(rdrop2) drop\_acc() then enter your
> username and password. This should only need to be done once per
> directory.

This will create a file called `.httr-oauth` in your directory, which
will contain your login credentials for Dropbox. **Remember to add this
file to your .gitignore if you are using git**. For more information,
see `?rdrop2::drop_auth`.

First steps
-----------

You can read data directly into R . For example:

    macae <- read_site_sheet("Macae", "leaf.waterdepths")

We can also do some basic checking

    check_names(macae)

Future plans
------------

We want to use this package to store functions which reproduce all of
the analyses of the Bromeliad Working Group.

### Licence

We release the code in this repository under the MIT software license.
see text of license [here](LICENSE)
