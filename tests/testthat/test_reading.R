library(bwgtools)
context("reading data")

test_that("data is read correctly", {
  data <- system.file("extdata","test_file.xlsx", package = "bwgtools")
  expect_message(read_site_sheet("Macae", "leaf.waterdepths", ondisk = TRUE, file = data),
                 "you downloaded that file already! reading from disk")
  expect_error(read_site_sheet("Macae", ondisk = TRUE, file = data),
               "c'mon give me a sheet name")
  testdat <- read_site_sheet("Macae", "leaf.waterdepths", ondisk = TRUE, file = data)
  expect_equal(nrow(testdat), 2)
  stereotype <- dplyr::data_frame(a=1)
  expect_equal(class(testdat), class(stereotype))

  names(testdat)[2] <- "foo"
  expect_warning(check_names(testdat), "trt.name is misnamed")
})
