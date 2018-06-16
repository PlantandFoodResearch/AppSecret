
helper_shasum_file <- function(filepath = NULL) {
  content <- readBin(con = filepath, n = file.size(filepath), raw())
  raw2hex(PKI.digest(content, hash = "SHA1"), sep = "")
}
