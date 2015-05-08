#' Checks names of a dataset
#'
#' could possibly be adapted for all datasets
#'
#' @param dataset the dataset in question (as a data.frame)
#' @param column_names the correct names of that spreadsheet
#' @export
check_names <- function(dataset, column_names = c("site", "trt.name", "bromeliad.id", "date",
                                                  "depth.centre.measure.first",
                                                  "depth.leafa.measure.first",
                                                  "depth.leafb.measure.first",
                                                  "depth.centre.water.first",
                                                  "depth.leafa.water.first",
                                                  "depth.leafb.water.first")){
  checks <- vapply(column_names, assertthat::has_name, TRUE, x = dataset)
  problem <- column_names[!checks]
  #browser()
  if(!all(checks)) {
    msg <- sprintf("%s is misnamed", problem)
    warning(msg)
  }
}

