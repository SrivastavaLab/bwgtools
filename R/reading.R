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

  sheet <-  match.arg(sheetname, c("leaf.waterdepths"))
  f <- switch(sheet,
               leaf.waterdepths = leaf.waterdepths_read)
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

