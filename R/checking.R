





#' Filter out any groups where depth is all NA
#'
#' @param data a grouped data.frame
#'
#' @return a data.frame with all NA groups gone
#' @export
filter_naonly_groups <- function(data, respvar = "depth"){
  dplyr::groups(data) %>%
    paste(collapse = ", ") %>%
    sprintf("Removing all NA groups: data is grouped by %s", .) %>%
    message

  fv <- lazyeval::interp(~!all(is.na(x)), x = as.name(respvar))

  data %>%
    dplyr::filter_(fv)
}


#' Filter out the centre leaf
#'
#' @param data dataset to filter. must contain a column called "leaf"
#' @param centre_filter do you want to drop the central leaf? defaults to TRUE
#'
#' @return data.frame without the centre leaf
#' @export
filter_centre_leaf <- function(data, centre_filter = TRUE){
  if(centre_filter){
    data2 <- data %>%
      dplyr::filter(leaf != "centre")
  } else {
    data2 <- data
  }

  if((nrow(data2) == nrow(data)) & centre_filter) stop("something was not filtered")
  return(data2)
}

