context("utilities")

test_that("exceptions", {
  expect_error(app_secret_paths(),
               "Cannot continue without an application name")
})

test_that("everything under HOME", {
  base_path <- Sys.getenv("HOME", unset = tempdir())
  appname   <- "shiny-web-app"
  dotted    <- paste0(".", appname) ## .shiny-web-app

  exp_paths <- list(
    symmetric_file = file.path(base_path, dotted, "symmetric.rsa"),
    key_file       = file.path(base_path, dotted, "secret.pem"))

  paths <- app_secret_paths(appname = appname)
  expect_equal(paths, exp_paths, label = "paths are subdirs of HOME")
})


test_that("using here()", {
  withr::with_envvar(c("APP_SECRET_USE_HERE" = 1), {
    here_dir <- here::here()
    exp_paths <- list(
      symmetric_file = file.path(here_dir, ".user-settings", Sys.getenv("USER"), "symmetric.rsa"),
      key_file       = file.path(Sys.getenv("HOME"), ".mine", "secret.pem"))
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
    key_file       = file.path(Sys.getenv("HOME"), dotted, "secret.pem"))

  paths <- app_secret_paths(appname = appname, base_path = base_path)
  expect_equal(paths, exp_paths, label = "paths are subdirs of base_path")
})
