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
                                        "first_or_second","first")) %>%
    dplyr::select(-depth_word, -first) %>%
    dplyr::filter(!is.na(depth))

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