#' make the water data long
#'
#' @param df the water data to make long
#'
#' @return long water data
#' @importFrom magrittr "%>%"
#' @export
longwater <- function(df) {
  measures  <- df %>%
    tidyr::gather("data_name", "depth", starts_with("depth")) %>%
    tidyr::separate(data_name, into = c("depth_word", "leaf",
                                        "watered_first","first")) %>%
    dplyr::select(-depth_word, -first) %>%
    mutate(watered_first = ifelse(watered_first == "water", "yes", "no"))

  return(measures)
}


#' Make the support file
#'
#' @return data.frame containing support file: site.name, trt.name, temporal.block, start_block and finish_block. Start_block is equivalent to start.water.addition from the site.info tab, and finish_block is equivalent to last.day.sample
#' @export
make_support_file <- function(){
  ## get the data
  allsites <- combine_site.info()
  phys <- combine_tab("bromeliad.physical")

  start_finish <- allsites %>%
    dplyr::select(site.name, start_block = start.water.addition, finish_block = last.day.sample)

  which_block <- phys %>%
    select(site, trt.name, temporal.block)

  support <- left_join(which_block, start_finish, by = c("site" = "site.name"))

  block_days_start <- c("a" = 0, "b" = 1, "c" = 2)
  block_days_finish <- c("a" = 2, "b" = 1, "c" = 0)

  support %>%
    mutate(start_block = start_block + lubridate::days(block_days_start[temporal.block]),
           finish_block = finish_block - lubridate::days(block_days_finish[temporal.block]))

}



#' Calculate water depth measurements
#'
#' @param depth depth measurements
#' @details text describing parameter inputs in more detail.
#' \itemize{
#'  \item{"max.depth"}{ the maximum depth}
#'  \item{"min.depth"}{ the minimum depth}
#'  \item{"mean.depth"}{ mean depth}
#'  \item{"var.depth"}{ variance in depth}
#'  \item{"sd.depth"}{ standard deviation in depth}
#'  \item{"cv.depth"}{ coefficient of variation in depth}
#'  \item{"net_fluct"}{ net fluctuation in depth}
#'  \item{"total_fluct"}{ total fluctuation in depth}
#'  \item{"amplitude"}{ max.depth - mean.depth}
#'  \item{"wetness"}{mean.depth / max.depth}
#' }
#'
#' @return a 1 x n row \code{tbl_df}
#' @export
water_summary_calc <- function(depth){
  ## check that it looks like mm
  ## must be sorted by date
  ## merge with support file -- must be 63 long
  dplyr::data_frame(
    n.depth = sum(!is.na(depth)),
    max.depth = max(depth, na.rm = TRUE),
    min.depth = min(depth, na.rm = TRUE),
    mean.depth = mean(depth, na.rm = TRUE),
    var.depth = var(depth, na.rm = TRUE),
    sd.depth = sd(depth, na.rm = TRUE),
    net_fluct = sum(diff(depth), na.rm = TRUE),
    total_fluct = sum(abs(diff(depth)), na.rm = TRUE),
    cv.depth = (100*(sd.depth/mean.depth)),
    amplitude = max.depth - min.depth,
    wetness = mean.depth / max.depth,
    prop.overflow.days = sum(depth > (max.depth - 10))/length(depth),
    prop.driedout.days = sum(depth < 5)/length(depth),
    time.since.minimum =
      if (any(depth < 5) & all(!is.na(depth))) {
      length(depth) - max(which(depth < 5))
      } else NA
  )
}
