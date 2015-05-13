#' Read an excel file from dropbox account
#'
#' this function reads all the sheets in an excel book on dropbox
#' @param file the file name to fetch
#' @param sheetname the sheet name you want. must match exactly.
#' @param ondisk Are you reading this data from your machine or online?
#' @param dest destination for download
#' @export
read_sheet <- function(file, sheetname = NULL, ondisk = FALSE, dest = tempdir(), ...) {
  if (is.null(sheetname)) stop("c'mon give me a sheet name")

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
                                   "site.weather"
  ))
  f <- switch(sheet,
              leaf.waterdepths = leaf.waterdepths_read,
              bromeliad.physical = bromeliad.physical_read,
              bromeliad.final.inverts = bromeliad.final.inverts_read,
              site.info = site.info_read,
              site.weather = site.weather_read
  )
  if (file.exists(localfile)) {
    message("you downloaded that file already! reading from disk")
    f(localfile, ...)
  } else {
    print("fetching from dropbox")
    rdrop2::drop_get(file, local_file = localfile, overwrite = TRUE)
    f(localfile, ...)
  }
}

#' Read in the leaf.waterdepths tab
#'
#' this function reads one water depth sheet
#'
#' @param file_to_read Path to file to be read
#' @export
leaf.waterdepths_read <- function(file_to_read){
  readxl::read_excel(path = file_to_read,
                     sheet = "leaf.waterdepths",
                     na = "NA",
                     col_types = c("text","text","text",
                                   "date","numeric","numeric",
                                   "numeric","numeric","numeric",
                                   "numeric")
  )
}

#' Read in the bromeliad.physical tab
#'
#' this function reads one water depth sheet
#'
#' @param file_to_read Path to file to be read
#' @export
bromeliad.physical_read <- function(file_to_read){
  readxl::read_excel(path = file_to_read,
                     sheet = "bromeliad.physical",
                     na = "NA",
                     col_types = c("text","text","numeric","numeric","numeric",
                                   "numeric","text","text",
                                   "numeric","numeric","numeric","numeric","numeric",
                                   "numeric","numeric","numeric","numeric","numeric",
                                   "numeric","numeric","numeric","numeric","numeric",
                                   "numeric","numeric","numeric","numeric","numeric",
                                   "numeric","numeric","numeric","numeric","numeric",
                                   "numeric","numeric","numeric","numeric","numeric",
                                   "numeric","numeric","numeric","numeric","numeric",
                                   "numeric","numeric")
  )
}

bromeliad.final.inverts_read <- function(file_to_read){
  readxl::read_excel(path = file_to_read,
                     sheet = "bromeliad.final.inverts",
                     na = "NA",
                     col_types = NULL
  )
}

site.info_read <- function(file_to_read){
  rxl <-   readxl::read_excel

  first_pass <- rxl(path = file_to_read, sheet = "site.info", na = "NA",
                    col_types = NULL)

  total_cols <- ncol(first_pass)
  true_cols <- c("text","numeric","numeric","numeric",
                 "text","numeric","numeric","numeric",
                 "numeric","numeric","numeric","numeric",
                 "text","text","text","text","date","date","text")

  n_blank_cols <- total_cols - length(true_cols)

  blanks <- rep("blank", n_blank_cols)


  rxl(path = file_to_read,
      sheet = "site.info",
      na = "NA",
      col_types = c(true_cols, blanks)
  )
}


site.weather_read <- function(file_to_read){
  readxl::read_excel(path = file_to_read,
                     sheet = "site.weather",
                     na = "NA",
                     col_types = c("text", "date",
                                   "numeric", "numeric", "numeric")
  )
}



#' read in a sheet from all sites
#'
#' this function reads all the sheets in an excel book on dropbox
#' @param file the file name to fetch
#' @param sheetname the sheet name you want. must match exactly.
#' @export
read_site_sheet <- function(sitename, sheetname = NULL, ...){
  folders <- "BWG Drought Experiment/raw data/"
  filename_start <- "Drought_data_"
  file_ext <- ".xlsx"

  file_wanted <- paste0(folders,filename_start,sitename,file_ext)
  read_sheet(file_wanted, sheetname = sheetname, ...)
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
#' @param chars the number of character columns. defaults to 21
#' @param nums the number of numeric columns. defaults to 54
#' @export
get_bwg_names <- function(chars = 21, nums = 54){
  msg <- sprintf("this function thinks there are %d character columns followed by %d numeric columns", 21, 54)
  message(msg)
  cols <- c(rep("c", chars), rep("n", nums))
  our_col_types <- Reduce(f = paste0, cols)
  the_data <- readr::read_tsv("https://raw.githubusercontent.com/SrivastavaLab/bwg_names/master/data/Distributions_organisms_full.tsv",col_types = our_col_types)
  if(nrow(readr:::problems(the_data)) != 0) stop("something is wrong")
  return(the_data)
}
