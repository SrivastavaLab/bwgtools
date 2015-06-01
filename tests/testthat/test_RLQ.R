library(bwgtools)

context("calculating RLQ")

test_that("matrices are formed correctly", {
  expect_error(make_matrix(dplyr::data_frame(a = 1)), "rownm must be a column in df")
  expect_is(make_matrix(dplyr::data_frame(species = "foo", abd = 1)), "matrix")
  expect_true(is.numeric(make_matrix(dplyr::data_frame(species = "foo", abd = 1))))

})
