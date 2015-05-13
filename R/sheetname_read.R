#' Read in the site.info tab
#'
#' this function reads one site.info sheet
#'
#' @param file_to_read Path to file to be read
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

#' Read in the site.info tab
#'
#' this function reads one site.info sheet
#'
#' @param file_to_read Path to file to be read
site.weather_read <- function(file_to_read){
  readxl::read_excel(path = file_to_read,
                     sheet = "site.weather",
                     na = "NA",
                     col_types = c("text", "date",
                                   "numeric", "numeric", "numeric")
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


