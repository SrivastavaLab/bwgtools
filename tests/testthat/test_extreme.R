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
  #expect_warning(find_bounds_wet_overflow(1:8), "this leaf was too dry")
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

test_that("overflow is correct", {
  testvec <- c(0, 50, NA, 100, 50)
  expect_equal(bwgtools:::overflow(testvec), 0.25)
  
  
  testvec2 <- c(100, NA,NA,NA)
  expect_equal(bwgtools:::overflow(testvec2), 1)
  
  testvec3 <- c(0, 0, 0)
  expect_equal(bwgtools:::overflow(testvec3), 0)
  
  testvec4 <- c(10, 10, 10)
  expect_equal(bwgtools:::overflow(testvec4), 0)
})


test_that("oriedout is correct", {
  testvec <- c(0, 50, NA, 100, 50)
  expect_equal(bwgtools:::driedout(testvec), 0.25)
  
  
  testvec2 <- c(100, NA,NA,NA)
  expect_equal(bwgtools:::driedout(testvec2), 0)
  
  testvec3 <- c(0, 0, 0)
  expect_equal(bwgtools:::driedout(testvec3), 1)
  
  testvec4 <- c(10, 10, 10)
  expect_equal(bwgtools:::driedout(testvec4), 1)
})

test_that("extremity is correct", {
  
  testvec <- c(0, 50, NA, 100, 50)
  expect_equal(bwgtools:::extremity(testvec), data_frame(event = c("driedout", "overflow"),
                                                         prior = c(5L, 2L)))
  
  testvec2 <- c(100, NA,NA,NA)
  expect_equal(bwgtools:::extremity(testvec2), data_frame(event = c("overflow"),
                                                         prior = c(4L)))
  
  testvec3 <- c(0, 0, 0)
  expect_equal(suppressWarnings(bwgtools:::extremity(testvec3)),
               data_frame(event = c("driedout", "driedout", "driedout"),
                          prior = c(3L, 2L, 1L)))
  
  expect_warning(bwgtools:::extremity(testvec3),
               "boundaries are 0, 5, -10, 0. These are not increasing!
                    Probably this leaf was too dry.
                    Answer is drought, forever")
  
  testvec4 <- c(10, 10, 10)
  expect_equal(suppressWarnings(bwgtools:::extremity(testvec4)),
               data_frame(event = c("driedout", "driedout", "driedout"),
                          prior = c(3L, 2L, 1L)))
  
  expect_warning(bwgtools:::extremity(testvec4),
                 "boundaries are 0, 5, -10, 0. These are not increasing!
                    Probably this leaf was too dry.
                    Answer is drought, forever")
})

