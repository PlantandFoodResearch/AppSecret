
app_secret_paths <- function(appname = NULL, base_path = Sys.getenv("HOME")) {
  if (is.null(appname)) {
    stop("Cannot continue without an application name", call. = FALSE)
  }
  app_dot_dir <- paste(".", appname, sep = "")
  
  if (Sys.getenv("USE_HERE")) {
    sym_name <- paste(Sys.getenv("USER"), "symmetric.rsa", sep = ".")
    vault <- file.path(here(), ".user-settings") 
  } else {
    sym_name <- "symmetric_rsa"
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
