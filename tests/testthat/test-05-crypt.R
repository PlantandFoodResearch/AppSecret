context("crypt functions")

test_that("encryption yields result", {
  asm <- app_secret_manager(symmetric_file = test_sym_file,
                            key_file       = test_key_file)

  encrypted <- asm$encrypt_data("hello world")
  expect_true(is.raw(encrypted))
  encrypted.hex <- raw2hex(encrypted, sep = "")
  expect_equal(encrypted.hex, "ec5038ce56fdf3451b2b4e5680ee15f7")

  writeBin(encrypted, con = encrypted_data_file, raw())
})

test_that("decryption is possible", {
  expect_true(file.exists(encrypted_data_file),
              label = "sanity")
  asm <- app_secret_manager(symmetric_file = test_sym_file,
                            key_file       = test_key_file)
  encrypted <- asm$read_encrypted(encrypted_data_file)
  decrypted <- asm$decrypt_data(encrypted)
  expect_equal(rawToChar(decrypted), "hello world",
               label = "decrypted")

  expect_equal(asm$decrypt_file(encrypted_data_file), "hello world",
               label = "decrypted file contents")
})

test_that("encrypting a file", {
  asm <- app_secret_manager(symmetric_file = test_sym_file,
                            key_file       = test_key_file)
  secret    <- tempfile(pattern = "simple-data", fileext = ".txt")
  write(rep("something", 30), file = secret, sep = "\n")
  encrypted <- asm$encrypt_file(secret)
  expect_equal(raw2hex(encrypted, sep = ""),
               "77e552ab06ab9859f8b2887215bf5521dbbf711a53718202532261d9e21fdf97ce040b9d9aa10c09ff5693a9dc3a221424aba802972866d9b4e04694fd62845400967c3f03837756c7205a196ae038bdc9a99369556481cd4333356d0deb66d9bf53e8c84520307d24f43934312357b0060fd18d7c0e08c62d303ee842ae3e7b983ef5c9be24737c46a782b3236cdb88fe3812cef8a5a9d86edf643f0929a85ff8636c06e300c4ff1151e22e951f1e68eb7576de0ccf26e5a34885c333af2ad3487671f0a655c612c0d74488d354b5fa8aa9325d81f435cc1f69ba685cfa49c96d5666fcb76aeae0cc4f4388b80128d95e40521f76aad75640d39245596e214ca3fff9930ae956c0a072ff9db040b65fc602b80d035a1c11248f2c508b2a99f5682f9201f3e0df20f49edf90a4952c48",
               label = "raw2hex of encrypted =")
  asm$write_encrypted(encrypted, encrypted_data_file)
})

test_that("decrypting a file", {
  asm <- app_secret_manager(symmetric_file = test_sym_file,
                            key_file       = test_key_file)
  expect_equal(asm$decrypt_file(encrypted_data_file),
               paste(rep("something", 30), collapse = "\n"),
               label = "30 somethings")
})

test_that("encrypting raw data", {
  asm <- app_secret_manager(symmetric_file = test_sym_file,
                            key_file       = test_key_file)
  enc <- asm$encrypt_data(charToRaw("this is my long password"))
  expect_equal(1, 1)
})
