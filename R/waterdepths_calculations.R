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



#' Group or summarize water data (long form)
#'
#' @param data a data.frame created by \code{longwater()}
#' @param aggregate_leaves should leaves be aggregated? defaults to \code{FALSE}
#'
#' @return if \code{aggregate = FALSE}, a data.frame of the same size as the original, but with groups defined for further processing. If \code{aggregate_leaves = TRUE}, output has one observation per bromeliad (rather than one observation per leaf within bromeliad)
#' @export
#' @importFrom magrittr "%>%"
group_or_summarize <- function(data, aggregate_leaves = FALSE){
  impt_names <- c("site", "watered_first", "trt.name",
                  "leaf", "site_brom.id")
  test_for_names <- impt_names %in% names(data)

  missing_names <- impt_names[!test_for_names]

  if (length(missing_names) > 0) {
    stop(
      sprintf(
        "missing names %s",
        paste0(missing_names, collapse = ", ")
      )
    )
  }

  if (aggregate_leaves) {
    data %>%
      dplyr::group_by(site, watered_first, trt.name, site_brom.id, date) %>%
      dplyr::summarise(ndepth = sum(!is.na(depth)),
                depth = mean(depth, na.rm = TRUE))
  } else {
    data %>%
      dplyr::group_by(site, watered_first, trt.name, site_brom.id, leaf)
  }
}

#' Make the support file
#'
#' @param allsites combined site.info tab
#' @param phys combined bromeliad.physical tab
#'
#' @return data.frame containing support file: site.name, trt.name, temporal.block, start_block and finish_block. Start_block is equivalent to start.water.addition from the site.info tab, and finish_block is equivalent to last.day.sample
#' @export
make_support_file <- function(allsites, phys){
  ## get the data

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


#' Filter water data (long format)
#'
#' This function filters long-format water data, by applying \code{filter_centre_leaf}
#'  and \code{filter_naonly_groups}
#'
#' @param Data long-format water data
#' @param rm_centre should the centre leaf be used? defaults to TRUE
#'
#' @return ungrouped data.frame
#' @export
filter_long_water <- function(Data, rm_centre = TRUE){
  ## filter the output of longwater,
  ### remove central leaf (if required)
  ### get rid of any group without any numbers ie all NA
  Data %>%
    ## filter out centre
    filter_centre_leaf(centre_filter = rm_centre) %>% ## add argument here
    dplyr::group_by(site, watered_first) %>%
    filter_naonly_groups %>%
    ungroup
}



#' fill in the missing timeline
#'
#' This function fills in the complete sequence of dates,
#' from the beginning to the end of a site.
#'
#' @param filtered_water_data a pre-filtered water dataset. acts as a "template" for the grouping variables to include
#' @param sitedata contents of the site.info tab
#' @param physdata contents of the physical.info tab
#'
#' @return a long dataset that contains a consecutive series of dates
#' @export
make_full_timeline <- function(filtered_water_data, sitedata, physdata){
  supp <- make_support_file(allsites = sitedata,
                            phys = physdata)

  ## here, we need to make this as similar as possible to the output of longwater
  ## we remove depth and date, the only columns which make the rows unique
  ## (that is, the only columns which need filling in)
  simple_long <- filtered_water_data %>%
    dplyr::select(-depth, -date) %>%
    dplyr::distinct %>%
    dplyr::left_join(supp)

  ## now create a long dataset
  ## by making a date column
  ## that spans from start_block and goes to finish_block
  simple_long %>%
    #filter(!is.na(finish_block)) %>%
    dplyr::group_by(site_brom.id, site, trt.name, leaf, watered_first, temporal.block) %>%
    dplyr::do(data_frame(date = seq(from = .$start_block,
                             to = .$finish_block,
                             by = "days")))
}

#' Calculate the hydrological variables
#'
#' @param waterdata the leaf.waterdepths tab
#' @param sitedata the site.info tab
#' @param physicaldata the bromeliad.physical
#' @param rm_centre remove centre? defaults to TRUE
#' @param aggregate_leaves aggregate leaves? defaults to FALSE
#'
#' @return
#' @importFrom magrittr "%>%"
hydro_variables <- function(waterdata, sitedata, physicaldata,
                            rm_centre = TRUE, aggregate_leaves = FALSE){

  filtered_long_water <- waterdata %>%
    longwater %>%
    dplyr::filter(!(site == "argentina" &
               watered_first == "no")) %>%
    filter_long_water(rm_centre = rm_centre)


  long_dates <- make_full_timeline(sites, phys)

  ## combining the original data with data
  ## that has been "filled in" with fun
  filtered_long_water %>%
    ## filter out NA groups
    group_or_summarize(aggregate_leaves = aggregate_leaves) %>%
    dplyr::left_join(long_dates, .) %>%
    dplyr::arrange(site, date, trt.name, leaf) %>%
    dplyr::group_by(site, trt.name, leaf) %>%
    dplyr::do(water_summary_calc(.$depth))

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
    len.depth = length(depth),
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
