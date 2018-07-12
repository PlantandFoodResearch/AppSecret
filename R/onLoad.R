## dir.exists() did not exist in base until 3.2.0
.onLoad <- function(libname, pkgname) {
  backports::import(pkgname = pkgname, obj = "dir.exists")
}
