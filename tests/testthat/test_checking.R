
library(bwgtools)
context("checking data")

test_that("data is checked correctly",{

  testdat <- read_sheet(file = data, "leaf.waterdepths", ondisk = TRUE)

  names(testdat)[2] <- "foo"
  expect_warning(check_names(testdat), "trt.name is misnamed")

})
