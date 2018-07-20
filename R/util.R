
#' Creating paths for AppSecret
#'
#' Create paths as a utility and set of rules/expectations. Useful when trying to enforce a convention.
#'
#' @name app_secret_paths
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
#' @importFrom whoami username
#' @importFrom here here
#' @export
#' @seealso \code{\link{do.call}}, \code{\link{app_secret_manager}}
app_secret_paths <- function(appname = NULL, base_path = normalizePath("~")) {
  if (missing(appname)) {
    stop("Cannot continue without an application name", call. = FALSE)
  }
  if (length(appname) != 1) {
    stop("appname should be a character vector of length 1", call. = FALSE)
  }
  app_dot_dir <- paste(".", tolower(appname), sep = "")
  sym_name <- "symmetric.rsa"
  if (Sys.getenv("APP_SECRET_USE_HERE", "") != "") {
    vault <- file.path(here(), ".user-settings", whoami::username())
  } else {
    vault <- file.path(base_path, app_dot_dir)
  }

  return(
    list(
      symmetric_file = file.path(vault, sym_name),
      key_file       = file.path(normalizePath("~"), app_dot_dir, "secret.pem")
    )
  )
}

#' app_secret_ask
#'
#' Utility function designed for use as a standalone, or in \code{tap()}
#'
#' @name app_secret_ask
#'
#' @param obj     An AppSecret object
#' @param file    path to the file to write encrypted data to
#' @param message Message to present the user with
#'
#' @return Boolean as to whether user was asked for input.
#'
#' @import getPass
#' @export
#'
#' @examples
#'
#' \dontrun{
#'   asm       <- app_secret_manager()
#'   pass_file <- asm$path_in_vault("password")
#'   password  <- asm$tap(function(obj, file, message) {
#'      if(app_secret_ask(asm = obj, file = file, message = message)) {
#'         message("password stored in ", file)
#'      }
#'   }, file = pass_file)$decrypt_file(pass_file)
#'
#'   ## same, but without a message
#'   password <-
#'     asm$tap(func = app_secret_ask,
#'             file = pass_file)$decrypt_file(pass_file)
#'
#'   ## or just as a save the password helper
#'   app_secret_ask(obj = asm, file = pass_file)
#' }
#'
app_secret_ask <- function(obj = NULL, file = NULL,
                           message = "Please provide your password") {
  if(missing(file)) return(FALSE)
  if(file.exists(file)) return(FALSE)

  password  <- getPass::getPass(message)  ## no-covr-until 20190101
  encrypted <- obj$encrypt_data(password) ## no-covr-until 20190101

  obj$write_encrypted(encrypted, file)    ## no-covr-until 20190101
  return(TRUE)                            ## no-covr-until 20190101
}
