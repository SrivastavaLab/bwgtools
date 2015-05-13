
#' Combines all site.info tabs
#'
#' @return data.frame containing all the site information
#' @export
combine_site.info <- function() {

  site_info <- get_all_sites(sheetname = "site.info")

  ### clean and message
  message("CLEANING: I'm taking only the first row of French Guiana. is that still necessary?")
  site_info[[4]] <- site_info[[4]][1, ] ## extra values from FG
  message("CLEANING: I'm taking only the first row of Columbia. is that still necessary?")
  site_info[[3]] <- site_info[[3]][1, ] ## note that this is not good enough to fix this one.


  allsite <- rbind_all(site_info)
  return(allsite)
}

#' Obtain the site.weather data
#'
#' @return data.frame of all site.weather tabs
#' @export
combine_site.weather <- function(){
  site_weather <- get_all_sites(sheetname = "site.weather")

  ## clean and message
  message("CLEANING: I'm dropping the 6th column from Argentina. is that still necessary?")
  site_weather[[1]] <- site_weather[[1]][,-6]

  ## done
  allsite <- rbind_all(site_weather)
  return(allsite)
}
