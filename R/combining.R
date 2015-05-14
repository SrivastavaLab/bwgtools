
#' Combines all site.info tabs
#'
#' @return data.frame containing all the site information
#' @export
combine_site.info <- function() {

  site_info <- get_all_sites(sheetname = "site.info")

  ### clean and message
#   message("CLEANING: I'm taking only the first row of French Guiana. is that still necessary?")
#   site_info[[4]] <- site_info[[4]][1, ] ## extra values from FG
  message("CLEANING: I'm taking only the first row of Columbia. is that still necessary?")
  site_info[[3]] <- site_info[[3]][1, ] ## note that this is not good enough to fix this one.


  allsite <- dplyr::rbind_all(site_info)
  return(allsite)
}

#' Obtain the site.weather data
#'
#' @return data.frame of all site.weather tabs
#' @export
combine_site.weather <- function(){
  site_weather <- get_all_sites(sheetname = "site.weather")

  ## clean and message
  message("CLEANING: I'm dropping the 6th column from Argentina. is that still necessary?")
  site_weather[[1]] <- site_weather[[1]][,-6]

  ## done
  allsite <- dplyr::rbind_all(site_weather)
  return(allsite)
}

#' Obtain the bromeliad.physical data
#'
#' @return data.frame of all bromeliad.physical tabs
#' @export
combine_bromeliad.physical <- function(){
  site_weather <- get_all_sites(sheetname = "bromeliad.physical")

  ## clean and message
  message("CLEANING blank columns off of Columbia. is that still necessary?")
  okcols <- which(names(site_weather[[3]]) %in% c("site", "trt.name", "mu.scalar", "k.scalar", "intended.mu",
                                        "intended.k", "temporal.block", "bromeliad.id", "maxvol", "leaf.number",
                                        "mean.diam", "catchment.area", "turbidity.initial", "oxygen.percent.initial",
                                        "oxygen.conc.initial", "ph.initial", "chlorophyll.initial", "bacteria.per.ml. initial",
                                        "ciliates.per.ml.initial", "flagellates.per.ml.initial", "rotifers.per.ml.initial",
                                        "leafpack1.species1.mass.initial", "leafpack2.species1.mass.initial",
                                        "leafpack1.species2.mass.initial", "leafpack2.species2.mass.initial",
                                        "co2.final", "methane.final", "turbidity.final", "oxygen.percent.final",
                                        "oxygen.conc.final", "ph.final", "chlorophyll.final", "bacteria.per.ml.final",
                                        "ciliates.per.ml.final", "flagellates.per.ml.final", "rotifers.per.ml.final",
                                        "leafpack1.species1.mass.final", "leafpack2.species1.mass.final",
                                        "leafpack1.species2.mass.final", "leafpack2.species2.mass.final",
                                        "water.volume.final", "fpom.final", "n15.bromeliad.final", "final.bromeliad.percentn",
                                        "final.bromeliad.percentc"))
  site_weather[[3]] <- site_weather[[3]][,okcols]


  ## done
  allsite <- dplyr::rbind_all(site_weather)
  return(allsite)
}

#' Tidy wide invert data into long format
#'
#' @param insect_data the dataset to tidy. In the same shape as the bromeliad.inverts.final tab
#' @param category_vars those variables which define groups (ie the names of every variable that is NOT the name of an invertebrate species). Must be a character vector.
#'
#' @return tbl.df containing invertebrate data in long format
#' @export
invert_to_long <- function(insect_data, category_vars){

  # what names are *not* the categorical vars?
  data_names <- names(insect_data)
  insect_names <- setdiff(data_names, category_vars)

  # gather in all species names
  # spread out the two kinds of measurements
  # split the treatments into numbers
  long_out <- insect_data %>%
    tidyr::gather_("species", "quantity", insect_names)%>%
    tidyr::spread(abundance.or.biomass, quantity)%>%
    tidyr::separate(trt.name, c("mu", "k"), "k")%>%
    dplyr::mutate(mu = tidyr::extract_numeric(mu), k = tidyr::extract_numeric(k))

  where_zero <- identical(which(long_out$abundance==0), which(long_out$biomass == 0))

  if(!where_zero) stop("there are inconsistencies between the abundance and biomass columns")

  # remove the zeros
  long_final <- long_out %>%
    dplyr::filter(abundance != 0)

  return(long_final)
}


#' Merge functional groups to invert data
#'
#' @param insect_data data.frame of invert observations. must be long format (ie output of \code{invert_to_long})
#' @param trait_data bwg_names data. output of \code{get_bwg_names}
#'
#' @return merged data
#' @export
merge_func <- function(insect_data, trait_data){

  message("i am creating the pred_prey column. Stop me when it is present in the dataset!")
  bnt <- trait_data %>%
    dplyr::select(nickname, func.group) %>%
    dplyr::mutate(pred_prey = ifelse(stringr::str_detect(func.group, "predator"), "predator", "prey"))

  merged <- dplyr::left_join(insect_data, bnt, by = c("species" = "nickname"))

  return(merged)

}

#' summarize functional groups
#'
#' @param merged_data data formed by merging insect data to trait data
#'
#' @return summarized data. NOTE that this data will be grouped!
#' @export
#'
sum_func_groups <- function(merged_data){
  merged_data %>%
    dplyr::group_by(bromeliad.id, pred_prey, func.group) %>%
    dplyr::summarize(total_abundance = sum(abundance),
              total_biomass = sum(biomass),
              total_taxa = n())
}

#' summarize functional groups as columns
#'
#' @param merged_data data formed by merging insect data to trait data
#'
#' @return summarized data. NOTE that this data will be grouped!
#' @export
#'
sum_func_groups_cols <- function(merged_data){
  merged_data %>%
    dplyr::group_by(bromeliad.id, pred_prey, func.group) %>%

    dplyr::summarize(total_abundance = sum(abundance),
                     total_biomass = sum(biomass),
                     total_taxa = n())
}


#' Summarize functional groups still farther into trophic ranks
#'
#' @param func_sums must be a grouped tbl.df, the groups must be bromeliad.id and pred_prey, in that order
#'
#' @return summarized data
#' @export
sum_trophic <- function(func_sums){

  test_groups <- identical(dplyr::groups(func_sums),
                           lapply(list("bromeliad.id",
                                       "pred_prey"),
                                  as.name))

  if(!test_groups) stop("the input must be grouped by bromeliad.id and pred_prey, in that order")

  func_sums %>%
    dplyr::summarise_each(dplyr::funs(sum), total_abundance, total_biomass, total_taxa)
}

#' Plot predator vs prey biomass
#'
#' @param insect_data data.frame of invert observations. must be long format (ie output of \code{invert.long})
#' @param trait_data bwg_names data. output of \code{get_bwg_names}
#'
#' @return a ggplot
#' @export
plot_trophic <- function(invert_data, trait_data){
  #2 transform the data
  long_inverts <- invert_to_long(invert_data,
                                 category_vars = c("site",
                                                   "trt.name",
                                                   "bromeliad.id",
                                                   "abundance.or.biomass"))

  #3 combine with trait data
  inverts_traits <- merge_func(long_inverts, trait_data)

  #4 summarize this
  sum_grps <- sum_func_groups(inverts_traits)

  trophic_sums <- sum_trophic(sum_grps)


  trophic_sums %>%
    dplyr::filter(!is.na(pred_prey)) %>%
    dplyr::select(-total_abundance, - total_taxa) %>%
    tidyr::spread(pred_prey, value = total_biomass) %>%
    ggplot2::ggplot(ggplot2::aes(x = prey, y = predator)) + ggplot2::geom_point()
}
