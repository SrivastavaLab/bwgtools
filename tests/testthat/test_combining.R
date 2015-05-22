library(bwgtools)

context("combining and reshaping data")

test_that("data is reshaped correctly", {

  inverts <- dplyr::data_frame(site = c("a", "a"),
                               trt.name = c("mu1.5k0.5", "mu1.5k0.5"),
                               bromeliad.id = c("one", "one"),
                               abundance.or.biomass = c("abundance", "biomass"),
                               invert.1 = c(1, 3),
                               invert.2 = c(0, 0))

  result <- invert_to_long(inverts, c("site", "trt.name", "bromeliad.id", "abundance.or.biomass"))

  inverts_bio_na <- dplyr::data_frame(site = c("a", "a"),
                               trt.name = c("mu1.5k0.5", "mu1.5k0.5"),
                               bromeliad.id = c("one", "one"),
                               abundance.or.biomass = c("abundance", "biomass"),
                               invert.1 = c(1, NA),
                               invert.2 = c(0, NA))

  result_bio_na <- invert_to_long(inverts_bio_na, c("site", "trt.name", "bromeliad.id", "abundance.or.biomass"))

  result_classes <- unlist(lapply(result, class))
  names(result_classes) <- NULL

  expect_equal(result_classes, c("character", "numeric", "numeric",
                                 "character", "character",
                                 "numeric", "numeric"))
  ## save biomass, the two should be equal
  expect_equal(result_bio_na[, - 7], result[, - 7])

  expect_error(invert_to_long(inverts[,-1],
                                c("site", "trt.name", "bromeliad.id",
                                  "abundance.or.biomass")),
                 "missing a category")


  inverts_bio_err <- dplyr::data_frame(site = c("a", "a"),
                               trt.name = c("mu1.5k0.5", "mu1.5k0.5"),
                               bromeliad.id = c("one", "one"),
                               abundance.or.biomass = c("abundance", "biomass"),
                               invert.1 = c(1, 0),
                               invert.2 = c(0, 0))

  expect_error(invert_to_long(inverts_bio_err,
                              c("site", "trt.name", "bromeliad.id",
                                "abundance.or.biomass")),
               "there are inconsistencies between the abundance and biomass columns")


})
