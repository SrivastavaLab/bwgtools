#' Find first days (for duration)
#'
#' We want to get the first date for each bromeliad
#' @param df the dataframe of water depths
#' @export
firstday <- function(df){
  out <- df %>%
    group_by(bromeliad.id) %>%
    filter(date == min(date)) %>%
    ungroup %>%
    arrange(date) %>%
    select(trt.name, bromeliad.id, startdate = date)

  return(out)
  ## add tests there
}

#' Difference in days
#'
#' calculate the difference in days to the start of the experiment
#' @param df the leaf.waterdepths data.frame
#' @export
from_start <- function(depthdata){
  startdays <- firstday(depthdata)

  with_firstday <- depthdata %>%
    left_join(startdays, by = "bromeliad.id") %>%
    mutate(nday = (yday(date) - yday(startdate)) + 1) %>%
    select(bromeliad.id, date, nday)

  ## checks and warnings here
  return(with_firstday)
}



#' Make physical data long
#'
#' Rearranges the contents of the bromeliad.physical tab into a long format
#'
#' @param physical_data physical data, as produced by \code{combine_tab()}
#'
#' @return data.frame
#' @export
#' @importFrom magrittr "%>%"
physical_long <- function(physical_data){
  long_phys <- physical_data %>%
    dplyr::select(site, trt.name, bromeliad.id, contains("leafpack")) %>%
    tidyr::gather("leafpackvar", "mass", contains("leafpack")) %>%
    tidyr::separate(leafpackvar, c("rep","species","word_mass","time"))
}

#' calculate loss for each sample
#'
#' @param long_phys_data physical data in long format
#'
#' @return adds column "loss"
#' @importFrom magrittr "%>%"
#' @export
leaf_loss_sample <- function(long_phys_data){
  long_phys %>%
    tidyr::spread(time, mass) %>%
    dplyr::mutate(loss = (initial - final)/initial)
}
