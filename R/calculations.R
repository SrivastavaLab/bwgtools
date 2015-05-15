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


#' Calculate average decomposition for each species
#'
#' @param leaf_loss_sample_data the sample loss data
#'
#' @return means and sample sizes for each species
#' @importFrom magrittr "%>%"
#' @export
leaf_loss_mean <- function(leaf_loss_sample_data){
  leaf_loss_sample_data %>%
    dplyr::group_by(site, trt.name, bromeliad.id, species)%>%
    dplyr::summarise(mean_loss = mean(loss, na.rm = TRUE),
                     sample_size = sum(!is.na(loss))) %>%
    dplyr::filter(!is.na(mean_loss))
}


#' Species decomp and total decomp
#'
#' @param leaf_loss_species the data to combine. must be the output of \code{leaf_loss_mean()}
#'
#' @return a data.frame, one row per bromeliad
#' @importFrom magrittr "%>%"
#' @export
decomp_responses <- function(leaf_loss_species){
  ## spread the species into columns
  sp_cols <- leaf_loss_species %>% # only samples with no values are NA because na.rm = TRUE
    dplyr::select(-sample_size) %>%
    tidyr::spread(species, mean_loss)

  # sp_cols$site %>% table #should all be 30

  ## summarize across all species of leaves
  leaf_loss_overall <- leaf_loss_species %>%
    dplyr::group_by(site, trt.name, bromeliad.id) %>%
    dplyr::summarise(decomp = mean(mean_loss, na.rm = TRUE),
                     sample_size_species = n())

  ## CHECK

  dplyr::left_join(sp_cols, leaf_loss_overall, by = c("site", "trt.name", "bromeliad.id"))
}
