context("vault path method")

test_that("constructing paths", {
  paths <- app_secret_paths(appname = "test")
  asm   <- do.call(app_secret_manager, paths)
  exp_dir <- dirname(paths$symmetric_file)

  expect_silent(do.call(app_secret_manager, paths))
  expect_equal(class(asm), "environment")

  expect_equal(asm$path_in_vault("username"),
               file.path(exp_dir, "username"))

  expect_equal(asm$path_in_vault("password"),
               file.path(exp_dir, "password"))

  expect_error(asm$path_in_vault(), "filename is required")
  expect_error(asm$path_in_vault(""), "invalid filename")
  expect_error(asm$path_in_vault(c("A", "")), "invalid filename")

  # expect_error(asm$path_in_vault(c("username", "password")), "only one filename required")

  expect_equal(asm$path_in_vault(c("username", "password")),
                file.path(exp_dir, c("username", "password")))


  ## Test other list elements for ellipsis in app_secret_manager
  paths$foo = "fodda"
  expect_equal(paths, list(symmetric_file = "/home/hramwd/.test/symmetric.rsa",
                           key_file = "/home/hramwd/.test/secret.pem",
                           foo = "fodda"))

  asm2 <- do.call(app_secret_manager, paths)
  expect_equal(class(asm2), "environment")
  expect_equal(asm, asm2)
})
