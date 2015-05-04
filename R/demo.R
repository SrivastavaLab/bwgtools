#' Read an excel file from dropbox account
#'
#' this function reads all the sheets in an excel book on dropbox
#' @export
read_sheet <- function(file, dest = tempdir(), sheetname = NULL, ...) {
  if (is.null(sheetname)) stop("c'mon give me a sheet name")
  localfile <-  paste0(dest, "/", basename(file))

  sheet <-  match.arg(sheetname, c("leaf.waterdepths"))
  f <- switch(sheet,
               leaf.waterdepths = leaf.waterdepths_read)
  if (file.exists(localfile)) {
    print("you downloaded that file already! reading from disk")
    f(localfile)
  } else {
    print("fetching from dropbox")
    rdrop2::drop_get(file, local_file = localfile, overwrite = TRUE)
    f(localfile)
  }
}

#' Read in the leaf.waterdepths tab
#'
#' this function reads one water depth sheet
#'
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

### we need a function that checks the input sheetname
