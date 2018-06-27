context("vault path method")

test_that("constructing paths", {
  paths <- app_secret_paths(appname = "test")
  asm   <- do.call(app_secret_manager, paths)
  exp_dir <- dirname(paths$symmetric_file)

  expect_equal(asm$path_in_vault("username"),
               file.path(exp_dir, "username"))

  expect_equal(asm$path_in_vault("password"),
               file.path(exp_dir, "password"))

  expect_error(asm$path_in_vault(), "filename is required")

  expect_equal(asm$path_in_vault(c("username", "password")),
               file.path(exp_dir, c("username", "password")))
})
