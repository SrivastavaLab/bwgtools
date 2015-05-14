
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
  allsite <- rbind_all(site_weather)
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
  allsite <- rbind_all(site_weather)
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
    gather_("species", "quantity", insect_names)%>%
    spread(abundance.or.biomass, quantity)%>%
    separate(trt.name, c("mu", "k"), "k")%>%
    mutate(mu = extract_numeric(mu), k = extract_numeric(k))

  where_zero <- identical(which(long_out$abundance==0), which(long_out$biomass == 0))

  if(!where_zero) stop("there are inconsistencies between the abundance and biomass columns")

  # remove the zeros
  long_final <- long_out %>%
    filter(abundance != 0)

  return(long_final)
}


#' Merge functional groups to invert data
#'
#' @param insect_data data.frame of invert observations. must be long format (ie output of /code{invert.long})
#' @param trait_data bwg_names data. output of get_bwg_names
#'
#' @return merged data
#' @export
merge_func <- function(insect_data, trait_data){

  message("i am creating the pred_prey column. Stop me when it is present in the dataset!")
  bnt <- trait_data %>%
    select(nickname, func.group) %>%
    mutate(pred_prey = ifelse(str_detect(func.group, "predator"), "predator", "prey"))

  merged <- left_join(insect_data, bnt, by = c("species" = "nickname"))

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
    group_by(bromeliad.id, pred_prey, func.group) %>%
    summarize(total_abundance = sum(abundance),
              total_biomass = sum(biomass),
              total_taxa = n())
}

