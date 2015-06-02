library(bwgtools)

context("reading data")

test_that("data is read correctly", {

  # read it back with readRDS
  token <- readRDS("droptoken.rds")

  data <- system.file("extdata","Drought_data_PuertoRico.xlsx",
                      package = "bwgtools")
  ## no sheet name
  expect_error(read_sheet(file = data, ondisk = TRUE),
               "c'mon give me a sheet name")
  ## existing sheet name, ondisk file
  expect_message(read_sheet(file = data, "leaf.waterdepths",
                            ondisk = TRUE),
                 "you downloaded that file already! reading from disk")


  test_data <- read_sheet("BWG Drought Experiment/raw data/Drought_data_Macae.xlsx",
                          "leaf.waterdepths",.token = token)
  ## return value: a tbl_df
  ## with correct columns
  stereotype <- dplyr::data_frame(a = 1)

  ## LEAF.WATERDEPTHS --------
  testdat <- suppressMessages(read_sheet(file = data, "leaf.waterdepths", ondisk = TRUE))
  expect_equal(class(testdat), class(stereotype))
  testdat_classes <- unlist(lapply(testdat, class))
  names(testdat_classes) <- NULL
  expect_equal(testdat_classes, c("character", "character", "character", "POSIXct", "POSIXt",
                                  "numeric", "numeric", "numeric", "numeric", "numeric", "numeric"
  ))

  ## BROMELIAD.PHYSICAL --------
  testdat <- suppressMessages(read_sheet(file = data, "bromeliad.physical", ondisk = TRUE))
  expect_equal(class(testdat), class(stereotype))
  testdat_classes <- unlist(lapply(testdat, class))
  names(testdat_classes) <- NULL
  expect_equal(testdat_classes, c("character", "character", "numeric", "numeric", "numeric",
                                  "numeric", "character", "character", "numeric", "numeric", "numeric",
                                  "numeric", "numeric", "numeric", "numeric", "numeric", "numeric",
                                  "numeric", "numeric", "numeric", "numeric", "numeric", "numeric",
                                  "numeric", "numeric", "numeric", "numeric", "numeric", "numeric",
                                  "numeric", "numeric", "numeric", "numeric", "numeric", "numeric",
                                  "numeric", "numeric", "numeric", "numeric", "numeric", "numeric",
                                  "numeric", "numeric", "numeric", "numeric"))

  # BROMELIAD.FINAL.INVERTS -----------------------------
  testdat <- suppressMessages(read_sheet(file = data, "bromeliad.final.inverts", ondisk = TRUE))
  expect_equal(class(testdat), class(stereotype))
  expect_message(read_sheet(file = data, "bromeliad.final.inverts", ondisk = TRUE), "reading with NULL coltypes!")

  ## SITE.INFO -----------------
  testdat <- suppressMessages(read_sheet(file = data, "site.info", ondisk = TRUE))
  expect_equal(class(testdat), class(stereotype))
  testdat_classes <- unlist(lapply(testdat, class))
  names(testdat_classes) <- NULL
  expect_equal(testdat_classes,
               c("character", "numeric", "numeric", "numeric", "character",
                 "numeric", "numeric", "numeric", "numeric", "numeric", "numeric",
                 "numeric", "character", "character", "character", "character",
                 "POSIXct", "POSIXt", "POSIXct", "POSIXt", "character"))


  ## SITE.WEATHER ----------
  testdat <- suppressMessages(read_sheet(file = data, "site.weather", ondisk = TRUE))
  expect_equal(class(testdat), class(stereotype))
  testdat_classes <- unlist(lapply(testdat, class))
  names(testdat_classes) <- NULL
  expect_equal(testdat_classes,
               c("character", "POSIXct", "POSIXt", "numeric", "numeric", "numeric"
  ))
})

test_that("helper functions work correctly", {

  ## default path assembles correctly
  expect_equal(make_default_path("foo"),
               "BWG Drought Experiment/raw data/Drought_data_foo.xlsx")

  ## offline accepts only a site name
  expect_error(offline("foo"))

  ## offline creates a correct path
  expect_equal(offline("Macae"), "../../../Dropbox/BWG Drought Experiment/raw data/Drought_data_Macae.xlsx")

  ## brom_id_maker errors
  testdf <- dplyr::data_frame(site = c("a", "a"), bromeliad.id = 1:2)

  names(testdf) <- c("foo", "bromeliad.id")
  expect_error(brom_id_maker(testdf), "site or bromeliad.id missing")
  names(testdf) <- c("site", "bar")
  expect_error(brom_id_maker(testdf), "site or bromeliad.id missing")

  names(testdf) <- c("site", "bromeliad.id")

  with_ids <- brom_id_maker(testdf)

  stereotype <- dplyr::data_frame(a = 1)
  expect_equal(class(with_ids), class(stereotype))
  expect_equal(dim(with_ids), c(2,2))
  expect_equal(names(with_ids), c("site_brom.id", "site"))
  expect_equal(with_ids$site_brom.id, c("a_1", "a_2"))


  ## names
  testdf <- data.frame(a = 1, b = 2, c = 3, d = 4)
  expect_equal(which_names_doubled(testdf), testdf)

  names(testdf) <- c("a","a", "b", "b")
  expect_message(which_names_doubled(testdf), "these names were duplicates: a, b")

  newdf <- suppressMessages(which_names_doubled(testdf))
  expect_equal(names(newdf), c("a", "a.1", "b", "b.1"))



})
