library(bwgtools)
#options("httr_oauth_cache" = TRUE)

context("reading data")

test_that("data is read correctly", {
  ## no sheet name
  options("httr_oauth_cache" = TRUE)

  data <- suppressMessages(read_sheet("BWG Drought Experiment/raw data/Drought_data_Macae.xlsx", "leaf.waterdepths"))
  ## return value: a tbl_df
  ## with correct columns
  stereotype <- dplyr::data_frame(a = 1)

  ## LEAF.WATERDEPTHS --------
  testdat <- suppressMessages(read_sheet("BWG Drought Experiment/raw data/Drought_data_Macae.xlsx", "leaf.waterdepths"))
  expect_equal(class(testdat), class(stereotype))
  testdat_classes <- unlist(lapply(testdat, class))
  names(testdat_classes) <- NULL
  expect_equal(testdat_classes, c("character", "character", "character", "POSIXct", "POSIXt",
                                  "numeric", "numeric", "numeric", "numeric", "numeric", "numeric"
  ))

  ## BROMELIAD.PHYSICAL --------
  testdat <- suppressMessages(read_sheet(file = "BWG Drought Experiment/raw data/Drought_data_Macae.xlsx", "bromeliad.physical"))
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
                                  "numeric", "numeric", "numeric", "numeric", "numeric", "numeric", "numeric", "numeric"))

  # BROMELIAD.FINAL.INVERTS -----------------------------
  testdat <- suppressMessages(read_sheet("BWG Drought Experiment/raw data/Drought_data_Macae.xlsx", "bromeliad.final.inverts"))
  expect_equal(class(testdat), class(stereotype))
  expect_message(read_sheet("BWG Drought Experiment/raw data/Drought_data_Macae.xlsx", "bromeliad.final.inverts"), "reading with NULL coltypes!")

  ## SITE.INFO -----------------
  testdat <- suppressMessages(read_sheet("BWG Drought Experiment/raw data/Drought_data_Macae.xlsx", "site.info"))
  expect_equal(class(testdat), class(stereotype))
  testdat_classes <- unlist(lapply(testdat, class))
  names(testdat_classes) <- NULL
  expect_equal(testdat_classes,
               c("character", "numeric", "numeric", "numeric", "character",
                 "numeric", "numeric", "numeric", "numeric", "numeric", "numeric",
                 "numeric", "character", "character", "character", "character",
                 "POSIXct", "POSIXt", "POSIXct", "POSIXt", "character"))


  ## SITE.WEATHER ----------
  testdat <- suppressMessages(read_sheet("BWG Drought Experiment/raw data/Drought_data_Macae.xlsx", "site.weather"))
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
  expect_equal(offline("Macae"), "../../BWG Drought Experiment/raw data/Drought_data_Macae.xlsx")

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
  expect_warning(which_names_doubled(testdf), "these names were duplicates: a, b")

  newdf <- suppressMessages(which_names_doubled(testdf))
  expect_equal(names(newdf), c("a", "a.1", "b", "b.1"))



})
