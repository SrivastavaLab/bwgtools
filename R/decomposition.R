## calculations of the percent decomposition in all bromeliads.


#' Make physical data long
#'
#' Rearranges the contents of the bromeliad.physical tab into a long format
#'
#' @param physical_data physical data, as produced by \code{combine_tab()}
#'
#' @return data.frame
#' @importFrom magrittr "%>%"
physical_long <- function(physical_data){
  physical_data %>%
    dplyr::select(site, trt.name, site_brom.id, dplyr::contains("leafpack")) %>%
    tidyr::gather("leafpackvar", "mass", dplyr::contains("leafpack")) %>%
    tidyr::separate(leafpackvar, c("rep","species","word_mass","time"))
}

#' calculate loss for each sample
#'
#' @param long_phys_data physical data in long format
#'
#' @return adds column "loss"
#' @importFrom magrittr "%>%"
leaf_loss_sample <- function(long_phys_data){
  long_phys_data %>%
    tidyr::spread(time, mass) %>%
    dplyr::mutate(loss = (initial - final)/initial)
}


#' Calculate average decomposition for each species
#'
#' @param leaf_loss_sample_data the sample loss data
#'
#' @return means and sample sizes for each species
#' @importFrom magrittr "%>%"
leaf_loss_mean <- function(leaf_loss_sample_data){
  leaf_loss_sample_data %>%
    dplyr::group_by(site, trt.name, site_brom.id, species)%>%
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
decomp_responses <- function(leaf_loss_species){
  ## spread the species into columns
  sp_cols <- leaf_loss_species %>% # only samples with no values are NA because na.rm = TRUE
    dplyr::select(-sample_size) %>%
    tidyr::spread(species, mean_loss)

  # sp_cols$site %>% table #should all be 30

  ## summarize across all species of leaves
  leaf_loss_overall <- leaf_loss_species %>%
    dplyr::group_by(site, trt.name, site_brom.id) %>%
    dplyr::summarise(decomp = mean(mean_loss, na.rm = TRUE),
                     sample_size_species = n())

  ## CHECK

  dplyr::left_join(sp_cols, leaf_loss_overall, by = c("site", "trt.name", "site_brom.id"))
}

#' Calculate decomposition rates for all sites
#'
#' Given the data as presented in the "bromeliad.physical"
#' tab, calculates the percent loss of detritus in each bromeliad.
#'
#' @param bromeliad_physical contents of the "bromeliad.physical" tab.#'
#' @return data frame with 7 columns: site, trt.name,
#'   bromeliad.id, species1 decomposition, species2
#'   decomposition, mean decomposition, and the number of
#'   species contained in that mean
#' @export
#' @importFrom magrittr "%>%"
get_decomp <- function(bromeliad_physical){
  bromeliad_physical %>%
    physical_long %>%
    leaf_loss_sample %>%
    leaf_loss_mean %>%
    decomp_responses
}
