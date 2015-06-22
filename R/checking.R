


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



#' Filter out any groups where depth is all NA
#'
#' @param data a grouped data.frame
#'
#' @return a data.frame with all NA groups gone
#' @export
filter_naonly_groups <- function(data, respvar = "depth"){
  dplyr::groups(data) %>%
    paste(collapse = ", ") %>%
    sprintf("Removing all NA groups: data is grouped by %s", .) %>%
    message

  fv <- lazyeval::interp(~!all(is.na(x)), x = as.name(respvar))

  data %>%
    dplyr::filter_(fv)
}


#' Filter out the centre leaf
#'
#' @param data dataset to filter. must contain a column called "leaf"
#' @param centre_filter do you want to drop the central leaf? defaults to TRUE
#'
#' @return data.frame without the centre leaf
#' @export
filter_centre_leaf <- function(data, centre_filter = TRUE){
  if(centre_filter){
    data2 <- data %>%
      dplyr::filter(leaf != "centre")
  } else {
    data2 <- data
  }

  if((nrow(data2) == nrow(data)) & centre_filter) stop("something was not filtered")
  return(data2)
}

