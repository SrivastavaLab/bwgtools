library(bwgtools)
context("reading data")

test_that("data is read correctly", {
  data <- system.file("extdata","Drought_data_PuertoRico.xlsx",
                      package = "bwgtools")
  ## no sheet name
  expect_error(read_sheet(file = data, ondisk = TRUE),
               "c'mon give me a sheet name")
  ## existing sheet name, ondisk file
  expect_message(read_sheet(file = data, "leaf.waterdepths",
                            ondisk = TRUE),
                 "you downloaded that file already! reading from disk")

  ## return value: a tbl_df
  stereotype <- dplyr::data_frame(a=1)

  testdat <- read_sheet(file = data, "leaf.waterdepths", ondisk = TRUE)
  expect_equal(class(testdat), class(stereotype))

})
