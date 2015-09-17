#' Find first days (for duration)
#'
#' We want to get the first date for each bromeliad. This function only works if the dataframe contains the \code{date} and the \code{bromeliad.id} columns (ex: \code{sheetname="leaf.waterdepth"}).
#' @param df the dataframe of water depths
#' @examples
#' Arg <- read_site_sheet("Argentina","leaf.waterdepths")
#' firstday(Arg)
#' @return A dataframe with three columns: trt.name, bromeliad.id, startdate.
#' 
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
#' @param df a dataframe containing \code{sheetname="leaf.waterdepths"}
#' @return A dataframe combining the \code{date} and the \code{bromeliad.id}, plus a new column (\code{nday}) for the number of days since the begining of the experiment.
#' @examples
#' Arg <- read_site_sheet("Argentina","leaf.waterdepths")
#' from_start(Arg)
from_start <- function(depthdata){
  startdays <- firstday(depthdata)

  with_firstday <- depthdata %>%
    left_join(startdays, by = "bromeliad.id") %>%
    mutate(nday = (yday(date) - yday(startdate)) + 1) %>%
    select(bromeliad.id, date, nday)

  ## checks and warnings here
  return(with_firstday)
}


