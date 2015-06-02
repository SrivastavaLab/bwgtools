
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
#'
#' @return
#' @export
make_matrix <- function(df, rownm = "species"){
  if (!assertthat::has_name(df, rownm)) stop("rownm must be a column in df")
  pos_rownm <- which(names(df) == rownm)
  df[-pos_rownm] %>%
    as.matrix %>%
    magrittr::set_rownames(df[[rownm]])
}



#' Title
#'
#' @param sitename
#' @param .invert
#' @param .traits
#' @param .bromvars
#'
#' @return
#' @export
make_rlq <- function(sitename, .invert, .traits, .bromvars){

  onesite <- .invert %>%
    filter(site == sitename)


  ## a species x bromeliad matrix (abundance data) = matrix L
  L_mat <- onesite %>%
    select(species, site_brom.id, abundance) %>%
    spread(site_brom.id, abundance, fill = 0) %>%
    make_matrix

  animals <- dimnames(L_mat)[[1]]

  #a species x traits matrix (fuzzy coding) = matrix Q
  Q_mat <- .traits %>%
    select(nickname, matches("^[A-Z]{2}.*", ignore.case = FALSE)) %>%
    left_join(data_frame(nickname = animals), .) %>%
    make_matrix(rownm = "nickname")

  #  a bromeliad x environmental variables (plant specific data, including physical, hydrological, ..) = matrix R
  plants <- dimnames(L_mat)[[2]]
  R_mat <- .bromvars %>%
    select(-site, -trt.name) %>%
    left_join(data_frame(site_brom.id = plants), .) %>%
    make_matrix(rownm = "site_brom.id")

  list(R = R_mat, L = L_mat, Q = Q_mat)
}

