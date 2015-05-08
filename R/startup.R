.onAttach <- function(libname, pkgname) {
  packageStartupMessage("Welcome to the bwg R package! in order to obtain data from the BWG dropbox folder, you need to authorize R to access your dropbox. run the following commands: \n  library(rdrop2) \n   drop_acc() \n then enter your username and password. This should only need to be done once per directory.")
}

# .onLoad <- function(libname, pkgname){
#   tryCatch(rdrop2::drop_acc(), finally = print("not online"))
# }


