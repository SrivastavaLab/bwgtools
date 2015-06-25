#' Read an excel file from dropbox account
#'
#' this function reads all the sheets in an excel book on dropbox
#' @param file the file name to fetch
#' @param sheetname the sheet name you want. must match exactly.
#' @param ondisk Are you reading this data from your machine or online?
#' @param dest destination for download
#' @export
read_sheet <- function(file, sheetname = NULL, ondisk = FALSE,
                       dest = tempdir(), ...) {
  if (is.null(sheetname)) stop("c'mon give me a sheet name")

  ## where is the data read from? if user has said that data is ondisk
  ## use the path provided. else read from tempdir
  if(ondisk){
    localfile <- file
  } else {
    localfile <-  paste0(dest, "/", basename(file))
  }

  ## here add a test to see if the user has asked for a local file AND That the file exists

  sheet <-  match.arg(sheetname, c("leaf.waterdepths",
                                   "bromeliad.physical",
                                   "bromeliad.final.inverts",
                                   "site.info",
                                   "site.weather",
                                   "bromeliad.initial.inverts",
                                   "bromeliad.terrestrial",
                                   "terrestrial.taxa"
  ))
  f <- switch(sheet,
              leaf.waterdepths = leaf.waterdepths_read,
              bromeliad.physical = bromeliad.physical_read,
              bromeliad.final.inverts = neutral_read("bromeliad.final.inverts"),
              site.info = site.info_read,
              site.weather = site.weather_read,
              bromeliad.initial.inverts = neutral_read("bromeliad.initial.inverts"),
              bromeliad.terrestrial = bromeliad.terrestrial_read,
              terrestrial.taxa = terrestrial.taxa_read
  )

  if (file.exists(localfile)) {
    message("you downloaded that file already! reading from disk")
    f(localfile, ...)
  } else {
    print("fetching from dropbox")
    rdrop2::drop_get(file, local_file = localfile)
    f(localfile, ...)
  }
}


#' read in a sheet from all sites
#'
#' this function reads all the sheets in an excel book on dropbox
#' @param file the file name to fetch
#' @param sheetname Either the name of the site you want to read data from, or a path to where the excel files are on your local computer (for offline work)
#' @param OnDisk Are you reading from a local copy or Dropbox? defaults to FALSE
#' @export
read_site_sheet <- function(sitename, sheetname = NULL, ...){
  is_path <- file.exists(sitename)
  if (is_path) {
    file_wanted <- sitename
  } else {
    ## get default path from Dropbox/ to our data
    file_wanted <- make_default_path(sitename)
  }
  read_sheet(file_wanted, sheetname = sheetname, ondisk = is_path, ...)
}

#' Get all that data
#'
#' @param sites a vector of all the sites you want
#' @param sheetname the sheet name
#' @export
get_all_sites <- function(sites = c("Argentina","Cardoso", "Colombia",
                                    "French_Guiana", "Macae", "PuertoRico",
                                    "CostaRica"),
                          sheetname = NULL){
  lapply(sites, read_site_sheet, sheetname = sheetname)
}


#' obtain the full name data from github
#'
#' Gets the complete insect taxonomic data from github. This is good
#' because it will always be accurate. 
#' Just type in \code{get_bwg_names()} in R's Console and you will get all the taxonomic information (among other things).
#' @param file the location of the file. defaults to the internet
#' @param chars the number of character columns. defaults to 21
#' @param nums the number of numeric columns. defaults to 54
#' @return A dataframe containing all information as in the excel file in Dropbox: "Distribution organisms_correct2015"
#' @example 
#' taxo_info <- get_bwg_names()
#' names(taxo_info)
#' @export
get_bwg_names <- function(file = "https://raw.githubusercontent.com/SrivastavaLab/bwg_names/master/data/Distributions_organisms_full.tsv", chars = 23, nums = 54){
  msg <- sprintf("this function thinks there are %d character columns followed by %d numeric columns", chars, nums)
  message(msg)
  cols <- c(rep("c", chars), rep("n", nums))
  our_col_types <- Reduce(f = paste0, cols)
  the_data <- readr::read_tsv(file, col_types = our_col_types)
  if(nrow(readr::problems(the_data)) != 0) stop("something is wrong")
  return(the_data)
}


#' Make default dropbox path
#'
#' @param .sitename quoted site name
#'
#' @return the default path to file from dropbox
#' @export
make_default_path <- function(.sitename){
  folders <- "BWG Drought Experiment/raw data/"
  filename_start <- "Drought_data_"
  file_ext <- ".xlsx"

  file_wanted <- paste0(folders,filename_start,.sitename,file_ext)
  file_wanted
}


#' Get a file while offline
#'
#' If you don't have access to dropbox, you can still read files from your local dropbox folder. This function creates the path to the files.
#'
#' @param sitename Name of site you wish to read
#' @param default.path the default path to your Dropbox folder. Defaults to one that works within a paper folder, assuming you have not rearranged your folders within dropbox.
#'
#' @return a correct relative path
#' @importFrom magrittr "%>%"
#' @export
offline <- function(sitename, default.path = "../../"){

  Site <- match.arg(sitename, c("Argentina","Cardoso", "Colombia",
                                        "French_Guiana", "Macae", "PuertoRico",
                                        "CostaRica"))
  Site %>%
    make_default_path %>%
    paste0(default.path,.)
}


#' Make id column
#'
#' This joins the \code{site} and the \code{bromeliad.id}
#' columns. to make a unique identifier.
#'
#' @param df the data.frame. must contain site and
#'   bromelaid.id columns
#'
#' @return the data frame, plus a new column for the id (and minus the original)
#' @export
brom_id_maker <- function(df){
  ## first check to see if both needed columns are there
  two_names <- assertthat::has_name(df, c("site", "bromeliad.id"))

  if (!all(two_names)) stop("site or bromeliad.id missing")
  ## then unite them
  df %>%
    tidyr::unite(site_brom.id, site, bromeliad.id, remove = FALSE) %>%
    dplyr::select(-bromeliad.id)
  ## select only works if the column names are not duplicates
}
