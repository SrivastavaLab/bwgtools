#' Checks names of a dataset
#'
#' could possibly be adapted for all datasets
#'
#' @param dataset the dataset in question (as a data.frame)
#' @param column_names the correct names of that spreadsheet
#' @export
check_names <- function(dataset, column_names = c("site", "trt.name", "bromeliad.id", "date",
                                                  "depth.centre.measure.first",
                                                  "depth.leafa.measure.first",
                                                  "depth.leafb.measure.first",
                                                  "depth.centre.water.first",
                                                  "depth.leafa.water.first",
                                                  "depth.leafb.water.first")){
  checks <- vapply(column_names, assertthat::has_name, TRUE, x = dataset)
  problem <- column_names[!checks]
  #browser()
  if(!all(checks)) {
    msg <- sprintf("%s is misnamed \n", problem)
    warning(msg)
  }
}


#' Fill in argentina data
#'
#' This function needs TESTING
#'
#' @param argentina_data the argentina dataset
#'
#' @return the same data, but with days filled over
#' @export
fill_in_argentina <- function(argentina_data){
  topword <- argentina_data[1,1][[1]]
  if(topword != "argentina") stop("this isn't Argentina!!")


  fill_it <- function(df){
    df["fill_depth"] <- zoo::na.locf(df["fill_depth"])
    df
  }

  ar_full <- ar %>%
    tidyr::gather("measurement", "depth", depth.centre.measure.first:depth.leafb.water.first, convert = FALSE) %>%
    tidyr::separate(measurement,
                    into = c("depth_word", "leaf", "meas_water", "first")) %>%
    dplyr::mutate(after_water = stringr::str_detect(meas_water, ".*water.*")) %>%
    dplyr::group_by(bromeliad.id, date, leaf) %>%
    dplyr::arrange(after_water) %>%
    dplyr::mutate(fill_depth = depth) %>%
    dplyr::do(fill_it(.)) %>%
    dplyr::filter(!is.na(date))

  result <- ar_full %>%
    dplyr::ungroup(.) %>%
    dplyr::rowwise(.) %>%
    dplyr::mutate(colname = paste(depth_word, leaf, meas_water, first, sep = ".")) %>%
    dplyr::select(site, trt.name, bromeliad.id, date, colname, fill_depth) %>%
    tidyr::spread(colname, fill_depth)
  return(result)
}


#' Check that names are all identical
#'
#' @param datalist list of dataframes whose names must all be identical
#'
#' @return are the names identical? TRUE or FALSE
#' @export
names_all_same <- function(datalist){
  intersectnames <- datalist %>%
    lapply(names) %>%
    Reduce(intersect, .)

  identical(intersectnames, names(datalist[[1]]))
}


find_site_brom <- function(df){
  has_site <- assertthat::has_name(df, "site")
  has_brom <- assertthat::has_name(df, "bromeliad.id")

  has_site & has_brom
}
