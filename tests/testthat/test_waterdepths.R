library(bwgtools)

context("waterdepth calculations")

test_that("waterdepth functions behave correctly", {

  test_gr <- dplyr::data_frame(site = c("macae", "macae", "macae", "macae", "macae"),
                               trt.name = c("mu3k0.5", "mu0.1k2",
                                            "mu1.5k0.5", "mu0.8k0.5", "mu0.1k2"),
                               bromeliad.id = c("B5", "B29", "B34", "B8", "B29"),
                               date = structure(c(1365206400, 1367452800, 1364688000,
                                                  1368230400,1367452800),
                                                class = c("POSIXct", "POSIXt"),
                                                tzone = "UTC"),
                               leaf = c("leafb", "centre",
                                        "leafa", "leafb", "leafb"),
                               watered_first = c("yes", "yes", "yes", "yes", "yes"),
                               depth = c(74.8, 37, 56, 46.6, 10))


  expect_error(group_or_summarize(test_gr, TRUE), "missing names site_brom.id")

  names(test_gr)[3] <- "site_brom.id"
  aggregated_test <- group_or_summarize(test_gr, TRUE)
  expect_equal(nrow(aggregated_test), 4)
  expect_equal(groups(aggregated_test),
               lapply(list("site", "watered_first", "trt.name", "site_brom.id"),
                      as.name))

  unagg_test <- group_or_summarize(test_gr, FALSE)

  expect_equal(nrow(unagg_test), 5)
  expect_equal(groups(unagg_test),
               lapply(list("site", "watered_first", "trt.name",
                           "site_brom.id","leaf"),
                      as.name))


  #### making support file
  data <- system.file("extdata","Drought_data_Macae.xlsx",
                      package = "bwgtools")
  sitedat <- suppressMessages(read_sheet(file = data, "site.info", ondisk = TRUE))
  physdat <- suppressMessages(read_sheet(file = data, "bromeliad.physical", ondisk = TRUE))


  supp <- make_support_file(sitedat, physdat)

  expect_equal(lapply(supp, class),
               structure(list(site = "character", trt.name = "character",
                              temporal.block = "character",
                              start_block = c("POSIXct", "POSIXt"),
                              finish_block = c("POSIXct", "POSIXt")),
                         .Names = c("site", "trt.name", "temporal.block",
                                    "start_block", "finish_block")))

  expect_equal(dim(supp), c(30, 5))

})
