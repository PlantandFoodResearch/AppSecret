context("initialising files")

test_that("files get created", {
  tmp <- tempdir()
  on.exit({
    unlink(tmp)
  }, add = TRUE)

  sym_file <- file.path(tmp, "symmetric.rsa")
  key_file <- file.path(tmp, "super-secret.pem")

  asm <- app_secret_manager(symmetric_file = sym_file,
                            key_file       = key_file)

  expect_false(asm$debug, label = "set to false as default")

  expect_true(file.exists(key_file), label = "initialised a private key")

  expect_false(file.exists(sym_file), label = "symmetric file not yet created")

  asm$encrypt_data("foo")

  expect_true(file.exists(sym_file), label = "symmetric file created")
})

test_that("can use existing files", {
  asm <- app_secret_manager(symmetric_file = test_sym_file,
                            key_file       = test_key_file)

  expect_equal(helper_shasum_file(test_key_file),
               "ce0f2057b8bff139db8f2ed59ed6fff67ee8bec5",
               label = "match to checked in file")

  asm$encrypt_data("foo")

  expect_equal(helper_shasum_file(test_sym_file),
               "f47b5500ba39c79bb7bf6f691fae238cde7fe0c7",
               label = "did not regenerate")
})
