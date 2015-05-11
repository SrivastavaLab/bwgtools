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
