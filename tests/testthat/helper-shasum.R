
helper_shasum_file <- function(filepath = NULL) {
  content <- readBin(con = filepath, what = raw(), n = file.size(filepath))
  PKI::raw2hex(PKI::PKI.digest(content, hash = "SHA1"), sep = "")
}
