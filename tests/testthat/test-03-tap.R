context("k combinator")

test_that("tap test", {
  paths <- app_secret_paths(appname = "test")
  asm   <- app_secret_manager(paths$symmetric_file, paths$key_file)
  expect_false(asm$debug)
  data  <- "debug is "

  expect_message(
    expect_false(asm$tap(function(s, data) {
      s$set_debug(TRUE)
      message(paste0(data, s$debug))
    }, data)$set_debug(FALSE)$debug),
    "debug is TRUE", fixed = TRUE)

  password_file <- asm$path_in_vault(paste0(sample(LETTERS, 20,
                                                   replace = TRUE),
                                            collapse = ""))

  password <- asm$tap(function(s, file) {
    if(file.exists(file)) return(NA)
    ## password <- getPass::getPass("passs")
    password  <- "your password"
    encrypted <- s$encrypt_data(password)
    s$write_encrypted(encrypted, file)

  }, password_file)$decrypt_file(password_file)

  expect_equal(password, "your password", label = "tappy-mc-taptap")
})
