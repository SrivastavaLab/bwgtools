
library(bwgtools)
context("checking data")

test_that("data is checked correctly",{

  data <- system.file("extdata","Drought_data_PuertoRico.xlsx",
                      package = "bwgtools")
  testdat <- suppressMessages(read_sheet(file = data, "leaf.waterdepths", ondisk = TRUE))

  names(testdat)[2] <- "foo"
  expect_warning(check_names(testdat), "trt.name is misnamed")

  dlist <- list(dplyr::data_frame(a = 1, b = 2),
                dplyr::data_frame(a = 1, b = 2))

  expect_equal(names_all_same(dlist), TRUE)

  dlist <- list(dplyr::data_frame(a = 1, b = 2),
                dplyr::data_frame(a = 1, c = 2))

  expect_equal(names_all_same(dlist), FALSE)


  testdf <- dplyr::data_frame(site = 1, bromeliad.id = 2)
  expect_equal(find_site_brom(testdf), TRUE)
  testdf <- dplyr::data_frame(site = 1, bromeliad = 2)
  expect_equal(find_site_brom(testdf), FALSE)
  testdf <- dplyr::data_frame(STIE = 1, bromeliad.id = 2)
  expect_equal(find_site_brom(testdf), FALSE)


  ## filtering NAs
  na_lvls <- data_frame(x = c("a","a","a","b","b","b"),
                        depth = c(NA, NA, NA, 3, NA, 2))

  expect_message(filter_naonly_groups(group_by(na_lvls, x)),
                 "data is grouped by x")

  test <- suppressMessages(filter_naonly_groups(group_by(na_lvls, x)))
  expect_equal(test,
               filter(group_by(na_lvls, x), x == "b"))

  ## removing Centre
  tofilter <- data_frame(leaf = c("leafa", "leafb", "center"))

  expect_error(filter_centre_leaf(tofilter), "something was not filtered")

  expect_equal(filter_centre_leaf(tofilter, centre_filter = FALSE), tofilter)


  tofilter <- data_frame(leaf = c("leafa", "leafb", "centre")) # correct spelling
  expect_equal(filter_centre_leaf(tofilter), data_frame(leaf = c("leafa", "leafb")))



})


