library(bwgtools)
context("reading data")

test_that("data is read correctly", {
  data <- system.file("extdata","Drought_data_PuertoRico.xlsx",
                      package = "bwgtools")
  expect_message(read_sheet(file = data, "leaf.waterdepths",
                            ondisk = TRUE),
                 "you downloaded that file already! reading from disk")
  expect_error(read_sheet(file = data, ondisk = TRUE),
               "c'mon give me a sheet name")
  testdat <- read_sheet(file = data, "leaf.waterdepths", ondisk = TRUE)


  stereotype <- dplyr::data_frame(a=1)
  expect_equal(class(testdat), class(stereotype))

  names(testdat)[2] <- "foo"
  expect_warning(check_names(testdat), "trt.name is misnamed")
})
