
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

  insect_data %>%
    ## could use quoted form here
    gather_("species", "quantity", insect_names)%>%
    spread(abundance.or.biomass, quantity)%>%
    separate(trt.name, c("mu", "k"), "k")%>%
    mutate(mu = extract_numeric(mu), k = extract_numeric(k))
}
