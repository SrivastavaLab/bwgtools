
library(bwgtools)
context("checking data")

test_that("checking for names works", {

  dlist <- list(dplyr::data_frame(a = 1, b = 2),
                dplyr::data_frame(a = 1, b = 2))

  expect_equal(names_all_same(dlist), TRUE)

  dlist <- list(dplyr::data_frame(a = 1, b = 2),
                dplyr::data_frame(a = 1, c = 2))

  expect_equal(names_all_same(dlist), FALSE)
})

test_that("make bromeliad names unique", {
  testdf <- dplyr::data_frame(site = 1, bromeliad.id = 2)
  expect_equal(find_site_brom(testdf), TRUE)
  testdf <- dplyr::data_frame(site = 1, bromeliad = 2)
  expect_equal(find_site_brom(testdf), FALSE)
  testdf <- dplyr::data_frame(STIE = 1, bromeliad.id = 2)
  expect_equal(find_site_brom(testdf), FALSE)
})


test_that("na groups are filtered", {  ## filtering NAs
  na_lvls <- dplyr::data_frame(x = c("a","a","a","b","b","b"),
                               depth = c(NA, NA, NA, 3, NA, 2))

  expect_message(filter_naonly_groups(dplyr::group_by(na_lvls, x)),
                 "data is grouped by x")

  test <- suppressMessages(filter_naonly_groups(dplyr::group_by(na_lvls, x)))
  expect_equal(test,
               dplyr::filter(dplyr::group_by(na_lvls, x), x == "b"))
})


test_that("filtering centre leaf works", {

  ## removing Centre
  tofilter <- dplyr::data_frame(leaf = c("leafa", "leafb", "center"))

  expect_error(filter_centre_leaf(tofilter), "something was not filtered")

  expect_equal(filter_centre_leaf(tofilter, centre_filter = FALSE), tofilter)


  tofilter <- dplyr::data_frame(leaf = c("leafa", "leafb", "centre")) # correct spelling
  expect_equal(filter_centre_leaf(tofilter), dplyr::data_frame(leaf = c("leafa", "leafb")))



})


