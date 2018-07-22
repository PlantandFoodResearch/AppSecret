context("utilities")

test_that("exceptions", {
  expect_error(app_secret_paths(),
               "Cannot continue without an application name")
})

test_that("everything under HOME", {
  base_path <- normalizePath("~")
  appname   <- "shiny-web-app"
  dotted    <- paste0(".", appname) ## .shiny-web-app

  exp_paths <- list(
    symmetric_file = file.path(base_path, dotted, "symmetric.rsa"),
    key_file       = file.path(base_path, dotted, "secret.pem"))

  paths <- app_secret_paths(appname = appname)
  expect_equal(paths, exp_paths, label = "paths are subdirs of HOME")

  appname <- "Shiny-Web-App"
  paths   <- app_secret_paths(appname = appname)
  expect_equal(paths, exp_paths, label = "paths are subdirs of HOME")

  appname <- c("Shiny-Web-App", "Dull-Web-App")
  expect_error(app_secret_paths(appname = appname),
               "appname should be a character vector of length 1")
})


test_that("using here()", {
  withr::with_envvar(c("APP_SECRET_USE_HERE" = 1), {
    here_dir <- here::here()
    exp_paths <- list(
      symmetric_file = file.path(here_dir, ".user-settings", Sys.getenv("USER"), "symmetric.rsa"),
      key_file       = file.path(normalizePath("~"), ".mine", "secret.pem"))
    paths <- app_secret_paths(appname = "mine")
    expect_equal(paths, exp_paths, label = "paths are subdirs of here()")
  })
})

test_that("passing a base_path", {
  base_path <- here::here()
  appname   <- "appy-mc-appface"
  dotted    <- paste0(".", appname) ## .appy-mc-appface

  exp_paths <- list(
    symmetric_file = file.path(base_path, dotted, "symmetric.rsa"),
    key_file       = file.path(normalizePath("~"), dotted, "secret.pem"))

  paths <- app_secret_paths(appname = appname, base_path = base_path)
  expect_equal(paths, exp_paths, label = "paths are subdirs of base_path")
})

test_that("getting a password", {
  skip_if_not(interactive(), message = "cannot accept input")
  tmp <- tempfile()
  dir.create(tmp)
  on.exit({
    unlink(tmp)
  }, add = TRUE)

  sym_file <- file.path(tmp, "symmetric.rsa")
  key_file <- file.path(tmp, "super-secret.pem")

  asm <- app_secret_manager(symmetric_file = sym_file,
                            key_file       = key_file)
  pass_file <- asm$path_in_vault("password")

  asked <- app_secret_ask(obj = asm, file = pass_file)
  expect_true(asked)
  expect_true(file.exists(pass_file))
  expect_gt(file.size(pass_file), 0)
})

test_that("no getting a password as file exists", {
  tmp <- tempfile()
  dir.create(tmp)
  on.exit({
    unlink(tmp)
  }, add = TRUE)

  sym_file <- file.path(tmp, "symmetric.rsa")
  key_file <- file.path(tmp, "super-secret.pem")

  asm <- app_secret_manager(symmetric_file = sym_file,
                            key_file       = key_file)
  pass_file <- asm$path_in_vault("password")
  ## forget the file
  asked <- app_secret_ask(obj = asm)
  expect_false(asked)

  file.create(pass_file)
  asked <- app_secret_ask(obj = asm, file = pass_file)
  expect_false(asked)
})
