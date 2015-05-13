blankfinder <- function(.file_to_read, .sheetname, .truecols){

  first_pass <- readxl::read_excel(path = .file_to_read, sheet = .sheetname, na = "NA",
                    col_types = NULL)
  total_cols <- ncol(first_pass)

  n_blank_cols <- total_cols - length(.truecols)

  blanks <- rep("blank", n_blank_cols)

  c(.truecols, blanks)

}


#' Read in the site.info tab
#'
#' this function reads one site.info sheet
#'
#' @param file_to_read Path to file to be read
site.info_read <- function(file_to_read){

  true_cols <- c("text","numeric","numeric","numeric",
                 "text","numeric","numeric","numeric",
                 "numeric","numeric","numeric","numeric",
                 "text","text","text","text","date","date","text")

  cts <- blankfinder(.file_to_read = file_to_read,
                     .sheetname = "site.info",
                     .truecols = true_cols)


  readxl::read_excel(path = file_to_read,
                     sheet = "site.info",
                     na = "NA",
                     col_types = cts
  )
}

#' Read in the site.info tab
#'
#' this function reads one site.info sheet
#'
#' @param file_to_read Path to file to be read
site.weather_read <- function(file_to_read){

#   true_cols <- c("text", "date",
#                  "numeric", "numeric", "numeric")
#
#   cts <- blankfinder(.file_to_read = file_to_read,
#                      .sheetname = "site.weather",
#                      .truecols = true_cols)

  readxl::read_excel(path = file_to_read,
                     sheet = "site.weather",
                     na = "NA",
                     col_types = NULL
  )
}

#' Read in the bromeliad.physical tab
#'
#' this function reads bromeliad.physical sheet
#'
#' @param file_to_read Path to file to be read
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

# terrestrial taxa

# bromeliad.terrestrial

# bromeliad.ibuttons

# bromeliad.initial.inverts


#' Read in the final.inverts tab
#'
#' this function reads one final.inverts sheet
#'
#' @param file_to_read Path to file to be read
bromeliad.final.inverts_read <- function(file_to_read){
  readxl::read_excel(path = file_to_read,
                     sheet = "bromeliad.final.inverts",
                     na = "NA",
                     col_types = NULL
  )
}



#bwg.codes


#' read in a neutral file
#'
#' @param sheetname name of the sheet you're reading
#'
#' @return a function that reads that sheet with col_types = NULL
#' @export
neutral_read <- function(sheetname){
  function(file_to_read){
    readxl::read_excel(path = file_to_read,
                       sheet = sheetname,
                       na = "NA",
                       col_types = NULL
    )
  }
}
