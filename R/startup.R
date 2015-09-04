.onAttach <- function(libname, pkgname) {
  startblurb <- "Welcome to the bwg R package! in order to obtain data from the BWG dropbox folder, you need to authorize R to access your dropbox. run the following commands:\n  library(rdrop2)\n  drop_auth(cache = FALSE)\nThen enter your username and password. This should only need to be done when downloading the data.\n\nThis is bwgtools "
  packageStartupMessage(startblurb,
                        utils::packageDescription("bwgtools",
                                                  field = "Version"),
                        appendLF = TRUE)
}

# .onLoad <- function(libname, pkgname){
#   tryCatch(rdrop2::drop_acc(), finally = print("not online"))
# }


