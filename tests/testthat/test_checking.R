
library(bwgtools)
context("checking data")

test_that("data is checked correctly",{

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


})


