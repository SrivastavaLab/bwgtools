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


  readxl::read_excel(path = file_to_read,
                     sheet = "site.info",
                     na = "NA",
                     col_types = true_cols
  )
}

#' Read in the site.info tab
#'
#' this function reads one site.info sheet
#'
#' @param file_to_read Path to file to be read
site.weather_read <- function(file_to_read){

   true_cols <- c("text", "date",
                  "numeric", "numeric", "numeric")

  readxl::read_excel(path = file_to_read,
                     sheet = "site.weather",
                     na = "NA",
                     col_types = true_cols
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
                                   "numeric","numeric","numeric","numeric","numeric",
                                   "numeric")
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

#' Read in the terrestrial.taxa tab
#'
#' this function reads terrestrial.taxa sheet
#'
#' @param file_to_read Path to file to be read
terrestrial.taxa_read <- function(file_to_read){
  readxl::read_excel(path = file_to_read,
                     sheet = "terrestrial.taxa",
                     na = "NA",
                     col_types = NULL,
                     skip = 2
  )
}

#' Read in the bromeliad.terrestrial tab
#'
#' this function reads bromeliad.terrestrial sheet
#'
#' @param file_to_read Path to file to be read
bromeliad.terrestrial_read <- function(file_to_read){
  readxl::read_excel(path = file_to_read,
                     sheet = "bromeliad.terrestrial",
                     na = "NA",
                     col_types = c("text","text","text",
                                   "date","text","numeric")
  )
}


# bromeliad.ibuttons
#' Read in the bromeliad.ibuttons tab
#'
#' this function reads one site.info sheet
#'
#' @param file_to_read Path to file to be read
bromeliad.ibuttons_read <- function(file_to_read){
  
  true_cols <- c("text","text","text","date",
                 "numeric","numeric","numeric")
  
  
  readxl::read_excel(path = file_to_read,
                     sheet = "bromeliad.ibuttons",
                     na = "NA",
                     col_types = true_cols
  )
}


# bromeliad.initial.inverts

#' read in a neutral file
#'
#' @param sheetname name of the sheet you're reading
#'
#' @return a function that reads that sheet with col_types = NULL
#' @export
neutral_read <- function(sheetname){
  function(file_to_read, ...){
    message("reading with NULL coltypes!")
    readxl::read_excel(path = file_to_read,
                       sheet = sheetname,
                       na = "NA",
                       col_types = NULL,
                       ...
    )
  }
}


