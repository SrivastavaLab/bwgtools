.onAttach <- function(libname, pkgname) {
  packageStartupMessage("Welcome to the bwg R package!")
}

.onLoad <- function(libname, pkgname){
  try(rdrop2::drop_acc())
}


