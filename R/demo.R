#' Read an excel file from dropbox account
#'
#' this function reads all the sheets in an excel book on dropbox
#' @export
read_sheet <- function(file, dest = tempdir(), sheetname, ...) {
  localfile = paste0(dest, "/", basename(file))
  f <- match.fun(sheetname)
  if (file.exists(localfile)) {
    print("you downloaded that file already! reading from disk")
    f(localfile)
  } else {
    print("fetching from dropbox")
    drop_get(file, local_file = localfile, overwrite = TRUE)
    f(localfile)
  }
}

#' Read in the leaf.waterdepths tab
#'
#' this function reads one water depth sheet
#'
#'
leaf.waterdepths <- function(file_to_read){
  readxl::read_excel(path = file_to_read,
                     sheet = "leaf.waterdepths",
                     na = "NA",
                     col_types = c("text","text","text",
                                   "date","numeric","numeric",
                                   "numeric","numeric","numeric",
                                   "numeric")
  )
}
