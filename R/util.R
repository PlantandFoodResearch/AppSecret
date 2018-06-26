
#' app_secret_paths
#'
#' Create paths as a utility and set of rules/expectations. Useful when trying to enforce a convention.
#'
#' @param appname    The application name, this will be prepended with a '.', and forced to be lowercase
#' @param base_path  The base path to use for storing the symmetric and encrypted files
#'
#' @return list()
#'
#' Influential environment variables \code{APP_SECRET_USE_HERE}
#'
#' @examples
#'
#' \dontrun{
#'   # list(symmetric_file = "/home/user/.best-shiny-app-ever/symmetric.rsa",
#'   #      key_file       = "/home/user/.best-shiny-app-ever/secret.pem")
#    paths <- app_secret_paths(appname = "best-shiny-app-ever")
#'
#'   Sys.setenv("APP_SECRET_USE_HERE"="1")
#'   here::set_here(path = "/apps/another-shiny-app")
#'   # list(symmetric_file = "/apps/another-shiny-app/.user-settings/user/symmetric.rsa",
#'   #      key_file       = "/home/user/.best-shiny-app-ever/secret.pem")
#'   paths <- app_secret_paths(appname = "another-shiny-app")
#'
#'   Sys.unsetenv("APP_SECRET_USE_HERE")
#'   here::set_here(path = "/apps/dull-app")
#'   # list(symmetric_file = "/apps/dull-app/.dull-app/user.symmetric.rsa",
#'   #      key_file       = "/home/user/.dull-app/secret.pem")
#'   paths <- app_secret_paths(appname = "dull-app", base_path = file.path(here()))
#' }
#'
#' @importFrom here here
#' @export
app_secret_paths <- function(appname = NULL, base_path = Sys.getenv("HOME")) {
  if (missing(appname)) {
    stop("Cannot continue without an application name", call. = FALSE)
  }
  if (length(appname) != 1) {
    stop("appname should be a character vector of length 1", call. = FALSE)
  }
  app_dot_dir <- paste(".", tolower(appname), sep = "")
  sym_name <- "symmetric.rsa"
  if (Sys.getenv("APP_SECRET_USE_HERE", "") != "") {
    vault <- file.path(here(), ".user-settings", Sys.getenv("USER"))
  } else {
    vault <- file.path(base_path, app_dot_dir)
  }

  return(
    list(
      symmetric_file = file.path(vault, sym_name),
      key_file       = file.path(Sys.getenv("HOME"), app_dot_dir, "secret.pem")
    )
  )
}
