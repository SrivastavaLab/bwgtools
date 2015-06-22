## Fix "broken" data files, or files which require heavy editing.
## right now the only example of such a file is Argentina's rainfall pattern



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
