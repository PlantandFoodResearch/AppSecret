context("error handling")

test_that("no symmetric key", {
  asm <- app_secret_manager(symmetric_file = "/nonexistent/test",
                            key_file       = tempfile())

  call_encrypt <- function(x) {
    x$encrypt_data("sample")
  }
  call_encrypt_raw <- function(x) {
    x$encrypt_data(charToRaw("sample"))
  }
  expect_warning(
    expect_error(object = call_encrypt(asm), "failed to create directory"),
    regexp = "cannot[^']+'/nonexistent", all = TRUE, perl = TRUE
  )
  asm <- app_secret_manager(symmetric_file = "/nonexistent/test",
                            key_file       = tempfile())
  expect_warning(
    expect_error(object = call_encrypt_raw(asm), "failed to create directory"),
    regexp = "cannot[^']+'/nonexistent", all = TRUE, perl = TRUE
  )
  ## this is purposefully incorrect private hacking - do not copy
  expect_equal(asm$.__enclos_env__$private$decrypt_sym_key(), NA,
               label = "coverage chase")
})

test_that("symmetric key is noise", {
  asm <- app_secret_manager(symmetric_file = tempfile(),
                            key_file       = tempfile())
  enc <- asm$encrypt_data("test")
  ## create a new object to reset
  asm <- app_secret_manager(symmetric_file = tempfile(),
                            key_file       = tempfile())
  ## this is purposefully incorrect usage - do not copy
  writeBin(charToRaw("noise"), con = asm$symmetric_file, raw())

  expect_warning(
    expect_error(asm$decrypt_data(enc), "error"),
    "decrypting symmetric file failed"
  )
  ## try again - test private$rsa_password shortcutting not active
  expect_warning(
    expect_error(asm$decrypt_data(enc), "error"),
    "decrypting symmetric file failed"
  )
})


test_that("no private key", {
  expect_warning(
    expect_error(object = app_secret_manager(symmetric_file = tempfile(),
                                             key_file       = "/nonexistent/test"),
                 "failed to create directory"),
    regexp = "cannot[^']+'/nonexistent",
    all = TRUE, perl = TRUE
  )
})

test_that("bad data to write", {
  asm <- app_secret_manager(symmetric_file = test_sym_file,
                            key_file       = test_key_file)

  expect_error(object = asm$write_encrypted("not encrypted"),
               regexp = "data should be raw format")
})

test_that("no file to read", {
  asm <- app_secret_manager(symmetric_file = test_sym_file,
                            key_file       = test_key_file)

  expect_equal(asm$read_encrypted("/encrypted/file/that/is/not/there"),
               charToRaw(""))
})
