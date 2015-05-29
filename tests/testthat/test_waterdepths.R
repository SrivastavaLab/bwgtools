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


  group_or_summarize(test_gr, TRUE)

  names(test_gr)[3] <- "site_brom.id"

  group_or_summarize(test_gr, TRUE)

  group_or_summarize(test_gr, FALSE)

})
