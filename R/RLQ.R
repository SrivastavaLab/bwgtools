
#' Create a matrix from a data.frame
#'
#' In order to make a matrix for RLQ analysis, we need to
#' convert data.frames containing data into a matrix format.
#' In these data.frames the first column holds what should
#' be the rownames of the matrix.
#'
#' @param df  a dataframe. should be all numeric except for
#'   the first column, which gives rownames.
#' @param rownm name of the first column, which is to become rownames
#' @return a numeric matrix
#' @importFrom magrittr "%>%"
make_matrix <- function(df, rownm = "species"){
  if (!assertthat::has_name(df, rownm)) stop("rownm must be a column in df")
  pos_rownm <- which(names(df) == rownm)
  df[-pos_rownm] %>%
    as.matrix %>%
    magrittr::set_rownames(df[[rownm]])
}



#' Create matrices for RLQ analysis
#'
#' Combines data on inverts, traits and bromeliads to create RLQ matrices.
#'
#' RLQ analysis is a means of relating three datasets: species traits, habitat traits, and species abundances. There are three matrices required for this analysis, as follows:
#'
#' \itemize{
#'   \item  species x traits matrix (fuzzy coding) = matrix Q
#'   \item a species x bromeliad matrix (abundance data) = matrix L
#'   \item a bromeliad x environmental variables (plant specific data, including physical, hydrological, ..) = matrix R
#' }
#'
#' @param sitename name of site
#' @param .invert invertebrate data.frame
#' @param .traits trait data.frame
#' @param .bromvars bromeliad variable data.frame
#'
#' @return named list of matrices: R, L and Q
#' @importFrom magrittr "%>%"
#' @export
make_rlq <- function(sitename, .invert, .traits, .bromvars){

  onesite <- .invert %>%
    dplyr::filter(site == sitename)


  ## a species x bromeliad matrix (abundance data) = matrix L
  L_mat <- onesite %>%
    dplyr::select(species, site_brom.id, abundance) %>%
    tidyr::spread(site_brom.id, abundance, fill = 0) %>%
    make_matrix

  animals <- dimnames(L_mat)[[1]]

  #a species x traits matrix (fuzzy coding) = matrix Q
  Q_mat <- .traits %>%
    dplyr::select(nickname, matches("^[A-Z]{2}.*", ignore.case = FALSE)) %>%
    dplyr::left_join(dplyr::data_frame(nickname = animals), .) %>%
    make_matrix(rownm = "nickname")

  #  a bromeliad x environmental variables (plant specific data, including physical, hydrological, ..) = matrix R
  plants <- dimnames(L_mat)[[2]]
  R_mat <- .bromvars %>%
    dplyr::select(-site, -trt.name) %>%
    dplyr::left_join(dplyr::data_frame(site_brom.id = plants), .) %>%
    make_matrix(rownm = "site_brom.id")

  list(R = R_mat, L = L_mat, Q = Q_mat)
}

