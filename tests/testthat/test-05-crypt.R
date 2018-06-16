context("crypt functions")

test_that("encryption yields result", {
  asm <- app_secret_manager(symmetric_file = test_sym_file,
                            key_file       = test_key_file)

  encrypted <- asm$encrypt_data("hello world")
  expect_true(is.raw(encrypted))
  encrypted.hex <- raw2hex(encrypted, sep = "")
  expect_equal(encrypted.hex, "ec5038ce56fdf3451b2b4e5680ee15f7")

  # writeBin(encrypted, con = file, raw())
})

test_that("decryption is possible", {
  expect_equal(1, 1)
})
