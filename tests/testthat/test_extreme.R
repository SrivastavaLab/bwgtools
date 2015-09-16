library(bwgtools)
#options("httr_oauth_cache" = TRUE)

context("extreme events")

test_that("check_increasing gets the boundaries right", {
  expect_equal(check_increasing(1:4), TRUE)
  expect_equal(check_increasing(4:1), FALSE)
  expect_equal(check_increasing(c(4,1,2,3)), FALSE)
  expect_equal(check_increasing(c(1,2,4,3)), FALSE)
  expect_equal(check_increasing(c(1, 2, NA, 3)), NA)
  
  expect_equal(check_increasing(c(-1,2,4,3)), NA)
  
  })

test_that("find_bounds_wet_overflow works", {
  expect_warning(find_bounds_wet_overflow(1:8), "this leaf was too dry")
})

test_that("extreme events are correctly ided",{
  
  expect_error(extreme_vector(1:10, bounds = c(0, 2, 5, 7)),
               "last boundary should be maximum")
  
  expect_error(extreme_vector(1:10, bounds = c(1, 2, 5, 7)),
               "first boundary should be 0")
  
  answer <- extreme_vector(1:10, bounds = c(0, 2, 5, 10))
  
  expect_equal(answer, c("driedout", "driedout", "normal",
                         "normal", "normal", "overflow", 
                         "overflow", "overflow", "overflow", "overflow"))
  
})