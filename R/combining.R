### these are all the functions which combine data.
### Contains the Master Function combine_tab and its helpers,
### including functions which reshape data or create new columns


#' Obtain data for all sites
#'
#' This function reads data from the same tab for all the sites (via \code{get_all_sites()}) , then combines thme with \code{dplyr::rbind_all()}
#'
#' @param sheetname The name of the sheet you'd like to have (\code{"leaf.waterdepths"}, \code{"bromeliad.physical"}, \code{"bromeliad.final.inverts"}, \code{"site.info"}, \code{"site.weather"}, \code{"bromeliad.initial.inverts"}, \code{"bromeliad.terrestrial"}, \code{"terrestrial.taxa"}).
#' @param .sites The sites you want. defaults to all of them
#'
#' @return data.frame of all bromeliad.physical tabs
#' @examples
#' combine_tab("French_Guiana","site.info")
#' @export
combine_tab <- function(.sites =  c("Argentina","Cardoso", "Colombia",
                                    "French_Guiana", "Macae", "PuertoRico",
                                    "CostaRica"),
                        sheetname){

  ## get all the site data
  site_data <- get_all_sites(sheetname = sheetname, sites = .sites)
  ########

  ## make names unique
  site_data <- lapply(site_data, which_names_doubled)

  #### ending the cleaning
  ## does the first dataset downloaded have the names "site" and "bromeliad.id"?
  is_site_brom_pres <- find_site_brom(site_data[[1]])
  ## if there are site and bromeliad columns, fuse them.
  if (is_site_brom_pres) {
    site_data <- lapply(site_data, brom_id_maker)
  }

  ## if this is invertebrates, gather them.
  if (sheetname %in% c("bromeliad.final.inverts",
                       "bromeliad.initial.inverts")) {
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

  countryname <- unique(insect_data[["site"]])
  if(!zeros_same & !biomass_absent) warning(sprintf("there are inconsistencies between the abundance and biomass columns in %s", countryname))

  # remove the zeros
  long_final <- long_out %>%
    dplyr::filter(abundance != 0)

  return(long_final)
}


#' Find and edit duplicate names in dataset
#'
#' @param df data frame which might have duplicate names
#'
#' @return data.frame with unique names. if the names were already unique, it is the same. otherwise the names are passed through \code{make.names} and a message is given
#' @export
which_names_doubled <- function(df){
  df_names <- df %>%
    names

  dup_names <- df_names %>%
    table %>%
    Filter(function(x) x > 1, .) %>%
    names

  if (length(dup_names) > 0) {
    dup_names %>%
      paste0(collapse = ", ") %>%
      sprintf("these names were duplicates: %s", .) %>%
      warning(.)
  }

  names(df) <- make.names(names(df), unique = TRUE)
  df
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

  merged <- dplyr::left_join(insect_data, trait_data, by = c("species" = "nickname"))

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
sum_func_groups <- function(merged_data, grps = list(~site, ~site_brom.id, ~pred_prey, ~func.group)){
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
                           lapply(list("site","site_brom.id",
                                       "pred_prey"),
                                  as.name))

  if(!test_groups) stop("the input must be grouped by bromeliad.id and pred_prey, in that order")

  func_sums %>%
    dplyr::summarise_each(dplyr::funs(sum), total_abundance, total_biomass, total_taxa)
}

#' Are the columns site and bromeliad.id found in this data.frame?
#'
#' @param df data frame to check for
#'
#' @return are those column names present? TRUE or FALSE
find_site_brom <- function(df){
  has_site <- assertthat::has_name(df, "site")
  has_brom <- assertthat::has_name(df, "bromeliad.id")

  has_site & has_brom
}

#' Check that names are all identical
#'
#' @param datalist list of dataframes whose names must all be identical
#'
#' @return are the names identical? TRUE or FALSE
#' @export
names_all_same <- function(datalist){
  intersectnames <- datalist %>%
    lapply(names) %>%
    Reduce(intersect, .)

  identical(intersectnames, names(datalist[[1]]))
}



