
#' app_secret_paths
#'
#' Create paths as a utility and set of rules/expectations. Useful when trying to enforce a convention.
#'
#' @param appname    The application name
#' @param base_path  The base path to use for storing the symmetric and encrypted files
#'
#' Influential environment variables \code{USE_HERE}
#'
#' @export
app_secret_paths <- function(appname = NULL, base_path = Sys.getenv("HOME")) {
  if (is.null(appname)) {
    stop("Cannot continue without an application name", call. = FALSE)
  }
  if (length(appname) != 1) {
    stop("appname should be a character vector of length 1", call. = FALSE)
  }
  app_dot_dir <- paste(".", appname, sep = "")
  
  if (Sys.getenv("USE_HERE")) {
    sym_name <- paste(Sys.getenv("USER"), "symmetric.rsa", sep = ".")
    vault <- file.path(here(), ".user-settings") 
  } else {
    sym_name <- "symmetric.rsa"
    vault    <- file.path(base_path, app_dot_dir)
  }
  
  return(
    list(
      symmetric_file = file.path(vault, sym_name),
      key_file       = file.path(Sys.getenv("HOME"), app_dot_dir, "secret.pem"),
      vault_path     = vault
    )
  )
}
