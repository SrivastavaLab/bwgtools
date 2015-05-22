## these are all the functions which combine data, where
## reshaping functions are required prior to combining they
## are found here as well


#' Obtain data for all sites
#'
#' This function reads data from the same tab for all the sites (via \code{get_all_sites()}) , then combines thme with \code{dplyr::rbind_all()}
#'
#' @param sheetname The name of the sheet you'd like to have
#' @param .sites the sites you want. defaults to all of them
#'
#' @return data.frame of all bromeliad.physical tabs
#' @export
combine_tab <- function(sheetname,
                        .sites =  c("Argentina","Cardoso", "Colombia",
                                    "French_Guiana", "Macae", "PuertoRico",
                                    "CostaRica")){

  ## get all the site data
  site_data <- get_all_sites(sheetname = sheetname, sites = .sites)
  ########
  #### START CLEANING STUFF should be temporart
  ### site.info Cleaning -- Colombia
  if (sheetname == "site.info")
  {

    if (unique(site_data[[3]][[1]]) != "colombia")
    {
      stop("wait. Where *IS* Colombia!?")
    }

    message("CLEANING: I'm taking only the first row of Colombia.
          is that still necessary?")
    site_data[[3]] <- site_data[[3]][1, ]

  }

  #### ending the cleaning
  ## does the first dataset downloaded have the names "site" and "bromeliad.id"?
  is_site_brom_pres <- find_site_brom(site_data[[1]])
  ## if there are site and bromeliad columns, fuse them.
  if (is_site_brom_pres) {
    site_data <- lapply(site_data, brom_id_maker)
  }

  ## if this is invertebrates, gather them.
  if (sheetname == "bromeliad.final.inverts") {
    site_data <- lapply(site_data, invert_to_long,
                        category_vars = c("site", "trt.name",
                                          "abundance.or.biomass",
                                          "site_brom.id"))
  }

  if(!names_all_same(site_data)) stop("names are different!")

  ## finally, rbind all
  allsite <- dplyr::rbind_all(site_data)
  return(allsite)
}

#' Tidy wide invert data into long format
#'
#' @param insect_data the dataset to tidy. In the same shape as the bromeliad.inverts.final tab
#' @param category_vars those variables which define groups (ie the names of every variable that is NOT the name of an invertebrate species). Must be a character vector.
#'
#' @return tbl.df containing invertebrate data in long format
#' @importFrom magrittr "%>%"
#' @export
invert_to_long <- function(insect_data, category_vars){

  data_names <- names(insect_data)

  # are all categories present?
  if (!all(category_vars %in% data_names)) {
    stop("missing a category")
  }

  # what names are *not* the categorical vars?

  insect_names <- setdiff(data_names, category_vars)

  # gather in all species names
  # spread out the two kinds of measurements
  # split the treatments into numbers
  long_out <- insect_data %>%
    tidyr::gather_("species", "quantity", insect_names, convert = TRUE)%>%
    tidyr::spread(abundance.or.biomass, quantity)%>%
    tidyr::separate(trt.name, c("mu", "k"), "k")%>%
    dplyr::mutate(mu = tidyr::extract_numeric(mu), k = tidyr::extract_numeric(k))

  zeros_same <- identical(which(long_out$abundance==0), which(long_out$biomass == 0))

  ## is there even biomass measurements?
  biomass_absent <- all(is.na(long_out$biomass))

  if(!zeros_same & !biomass_absent) stop("there are inconsistencies between the abundance and biomass columns")

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
#' @importFrom magrittr "%>%"
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
#' @param grps using the formula, indicate the grouping factors required
#'
#' @return summarized data. NOTE that this data will be grouped!
#' @importFrom magrittr "%>%"
#' @export
#'
sum_func_groups <- function(merged_data, grps = list(~bromeliad.id, ~pred_prey, ~func.group)){
  merged_data %>%
    dplyr::group_by_(.dots = grps) %>%
    dplyr::summarize(total_abundance = sum(abundance),
              total_biomass = sum(biomass),
              total_taxa = n())
}



#' Summarize functional groups still farther into trophic ranks
#'
#' @param func_sums must be a grouped tbl.df, the groups must be bromeliad.id and pred_prey, in that order
#'
#' @return summarized data
#' @importFrom magrittr "%>%"
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
#' @importFrom magrittr "%>%"
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



#' Get all the final insect data from Dropbox
#'
#' @param site_names Character vector of sites with (correctly formatted!) column names
#'
#' @importFrom magrittr "%>%"
#' @return data.frame with a column for "site"
#' @export
get_all_insects <- function(site_names = c("Macae","PuertoRico", "French_Guiana")){

  get_insects <- .%>%
    read_site_sheet("bromeliad.final.inverts") %>%
    invert_to_long(category_vars = c("site", "trt.name",
                                     "bromeliad.id",
                                     "abundance.or.biomass")) %>%
    dplyr::mutate(bromeliad.id = as.character(bromeliad.id))

  ## get all sites, rbind them
  lapply(site_names, get_insects) %>%
    dplyr::rbind_all(.)

}
