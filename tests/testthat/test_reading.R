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

  testdat <- suppressMessages(read_sheet(file = data, "leaf.waterdepths", ondisk = TRUE))
  expect_equal(class(testdat), class(stereotype))

  testdat <- suppressMessages(read_sheet(file = data, "bromeliad.physical", ondisk = TRUE))
  expect_equal(class(testdat), class(stereotype))

  testdat <- suppressMessages(read_sheet(file = data, "bromeliad.final.inverts", ondisk = TRUE))
  expect_equal(class(testdat), class(stereotype))

  testdat <- suppressMessages(read_sheet(file = data, "site.info", ondisk = TRUE))
  expect_equal(class(testdat), class(stereotype))

#   testdat <- suppressMessages(read_sheet(file = data, "site.weather", ondisk = TRUE))
#   expect_equal(class(testdat), class(stereotype))
})

test_that("helper functions work correctly", {

  expect_equal(make_default_path("foo"),
               "BWG Drought Experiment/raw data/Drought_data_foo.xlsx")

  expect_error(offline("foo"),
               "'arg' should be one of “Argentina”, “Cardoso”, “Colombia”, “French_Guiana”, “Macae”, “PuertoRico”, “CostaRica”")

  expect_equal(offline("Macae"), "../../../Dropbox/BWG Drought Experiment/raw data/Drought_data_Macae.xlsx")
})
