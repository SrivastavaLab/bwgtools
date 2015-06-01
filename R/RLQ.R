
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
