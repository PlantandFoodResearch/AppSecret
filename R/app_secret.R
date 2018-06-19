
#' app_secret_manager
#'
#' @param symmetric_file path to symmetric file
#' @param key_file path to PEM format key file
#'
#' @return app_secret instance
#' @export
#'
app_secret_manager <- function(symmetric_file, key_file) {
  app_secret$new(symmetric_file = symmetric_file, key_file = key_file)
}

app_secret <-
  R6::R6Class("app_secret", # nolint
          class     = FALSE,
          cloneable = FALSE,
          private   = list(
            rsa_password = charToRaw(""),
            ## decrypt symmetric key from disk
            decrypt_sym_key = function() {
              if(length(private$rsa_password) > 1) {
                return(private$rsa_password)
              }
              if(!file.exists(self$symmetric_file)) {
                return(NA)
              }
              contents <- readBin(con = self$symmetric_file, raw(), n = 256, size = 1)
              caught <- tryCatch(
                {
                  PKI::PKI.decrypt(contents, key = self$key)
                },
                error = function(cond) {
                  warning("decrypting symmetric file failed")
                  message(cond)
                },
                finally = {}
              )
              if(class(caught) == "raw") {
                message("decrypting symmetric file success")
                private$rsa_password <- caught
              }
              return(caught)
            },
            ## enc dec
            encrypt_sym_key_decrypt = function() {
              file <- self$symmetric_file
              if(file.exists(file)) {
                return(private$decrypt_sym_key())
              }
              if(!dir.exists(dirname(file))) {
                success <- dir.create(dirname(file), recursive = TRUE)
                if (!success) stop("failed to create directory", call. = FALSE)
              }
              symmetric_password <-
                PKI::PKI.encrypt(charToRaw(base64encode(PKI::PKI.random(32))), key = self$key)
              writeBin(symmetric_password, con = file, raw())

              return(private$decrypt_sym_key())
            }
          ),
          public = list(
            symmetric_file = NA_character_,
            key_file       = NA_character_,
            key            = NULL,
            ## initialisation
            initialize = function(symmetric_file = "symmetric.rsa",
                                  key_file = NA_character_) {
              private$rsa_password <- charToRaw("")
              self$symmetric_file  <- symmetric_file
              self$key_file        <- key_file
              if(is.na(key_file) == FALSE) {
                ## load key file if exists
                if (file.exists(key_file)) {
                  self$key <- PKI::PKI.load.key(file    = key_file,
                                                format  = "PEM",
                                                private = TRUE)
                } else {
                  ## create if not
                  self$create_keys(key_file)
                }
              }
            },

            ## create new key
            create_keys = function(key_file) {
              self$key_file <- key_file
              self$key      <- PKI::PKI.genRSAkey(2048)
              # write to disk
              if(!dir.exists(dirname(self$key_file))) {
                success <- dir.create(dirname(self$key_file), recursive = TRUE)
                if (!success) stop("failed to create directory", call. = FALSE)
              }
              PKI::PKI.save.key(key = self$key, format = "PEM", private = TRUE,
                                target = self$key_file)
              PKI::PKI.save.key(key = self$key, format = "PEM", private = FALSE,
                                target = paste(self$key_file, "pub", sep = "."))
              self$key
            },

            ## decrypt data - returns raw()
            decrypt_data = function(data) {
              decrypted <- tryCatch({
                PKI::PKI.decrypt(data,
                                 key    = private$encrypt_sym_key_decrypt(),
                                 cipher = "aes256cbc")
                },
                error = function(cond) {
                  message("decryption failed")
                  message(cond)
                },
                finally = {}
              )
              decrypted
            },
            ## decrypt a file - returns characters
            decrypt_file = function(file) {
              rawToChar(self$decrypt_data(self$read_encrypted(file)))
            },
            ## encrypt data func
            encrypt_data = function(data) {
              encrypted <- NA
              if(class(data) == "character") {
                encrypted <- tryCatch({
                  PKI::PKI.encrypt(charToRaw(data),
                                   key    = private$encrypt_sym_key_decrypt(),
                                   cipher = "aes256cbc")
                },
                error = function(cond) {
                  message("encryption failed")
                  message(cond)
                })
              } else {
                encrypted <- tryCatch({
                  PKI::PKI.encrypt(data,
                                   key    = private$encrypt_sym_key_decrypt(),
                                   cipher = "aes256cbc")
                },
                error = function(cond) {
                  message("encryption failed")
                  message(cond)
                })
              }
              encrypted
            },
            ## encrypt a file - returns raw
            encrypt_file = function(file) {
              self$encrypt_data(paste(readLines(con = file, n = file.size(file)), collapse = "\n"))
            },

            read_encrypted = function(file) {
              if (! file.exists(file)) {
                return(charToRaw(""))
              }
              readBin(con = file, n = file.size(file), raw())
            },

            write_encrypted = function(data, file = tempfile()) {
              if(! is.raw(data)) {
                stop("data should be raw format")
              }
              writeBin(data, con = file, raw())
            }
          ))
