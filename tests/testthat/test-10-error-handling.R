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

  encrypted <- expect_warning(
    object = call_encrypt(asm),
    regexp = "cannot[^']+'/nonexistent", all = TRUE, perl = TRUE
  )
  expect_equal(encrypted, NA, label = "expect NA with warning")

  asm <- app_secret_manager(symmetric_file = "/nonexistent/test",
                            key_file       = tempfile())
  encrypted <- expect_warning(
    object = call_encrypt_raw(asm),
    regexp = "cannot[^']+'/nonexistent", all = TRUE, perl = TRUE
  )
  expect_equal(encrypted, NA, label = "expect NA with warning")

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

  decrypted <- expect_message(asm$decrypt_data(enc), "invalid key object")
  expect_equal(decrypted, NA, label = "NA as expected")

  ## try again - test private$rsa_password shortcutting not active
  output <- capture_messages(asm$decrypt_data(enc))
  expect_match(output, "decrypting symmetric file failed", all = FALSE)
  expect_match(output, ":(block type is not 02|padding check failed)$", all = FALSE, perl = TRUE)
  ## should not start with "Error in"
  expect_match(output, "^[^E].*:(block type is not 02|padding check failed)$", all = FALSE, perl = TRUE)
  expect_match(output, "decryption failed", all = FALSE)
  expect_match(output, "invalid key object", all = FALSE)

  ## test debug flag setter true
  asm$set_debug(TRUE)
  expect_true(asm$debug, label = "got set")
  output <- capture_messages(asm$decrypt_data(enc))
  expect_match(output, "^Error in PKI::PKI\\.decrypt", all = FALSE, perl = TRUE)
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

test_that("fail to encrypt", {
  asm <- app_secret_manager(symmetric_file = tempfile(),
                            key_file       = tempfile())
  asm$.__enclos_env__$private$rsa_password <- charToRaw("argh")
  encrypted <- expect_message(asm$encrypt_data("test"))
  expect_equal(encrypted, NA, "NA returned on failure")

  status <- capture_messages(asm$encrypt_data("test"))
  expect_match(status, "^encryption failed", all = FALSE, perl = TRUE)
  expect_match(status, "^key is too short", all = FALSE, perl = TRUE)
})
