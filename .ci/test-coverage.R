#!/usr/bin/env Rscript

#' Custom script to handle coverage generation
#'
#' Filters out lines that include
#' ## no-covr-until
#' and optionally include an expiry date
#' ## no-covr-until 20200101
#'
#' The date must be parseable by lubridate::as_date() with defaults
#'
#' The script only does anything if the environment variable TRAVIS_R_VERSION_STRING
#' is set to release.
#'
#' The script is designed to run on travis and upload coverage stats to coveralls
#' Running locally will result in a shiny report app opening in browser
#'
#' The recommended way to run the script is thus:
#'
#'     TRAVIS_R_VERSION_STRING=release Rscript ./.ci/test-coverage.R
#'
#'


if(Sys.getenv("TRAVIS_R_VERSION_STRING") != "release") {
  message("[Info] TRAVIS_R_VERSION_STRING != release - exiting")
  quit(save = "no", status = 0)
}

time_valid_exclusions <- function(f = NULL, pattern = "## no-covr-until") {
  lines <- readLines(f)
  ignore_idx <- which(grepl(pattern = pattern, x = lines))
  if(length(ignore_idx) > 0) {
    lines[-ignore_idx] <- NA
  } else{
    lines[1:length(lines)] <- NA
  }
  dates    <- gsub(pattern     = paste0("^.*", pattern, "\\s?([\\d/\\-]+)?.*"),
                   replacement = "\\1",
                   x           = lines,
                   perl        = TRUE)
  ## today and tomorrow for expiry and default expiry to act as infinity
  today    <- lubridate::as_date(lubridate::now())
  tomorrow <- lubridate::as_date(lubridate::now() + lubridate::ddays(1))
  dates[which(dates == "")] <- format(tomorrow)
  ## convert all to dates
  dates <- suppressWarnings( lubridate::as_date(dates) )
  ## get indices of those that haven't expired
  current <- which(dates > today)
  ## return
  return(list(intersect( ignore_idx, current )))
}

create_line_excl <- function(file_list = c()) {
  sapply(file_list, time_valid_exclusions)
}

line_exclusions <- create_line_excl(dir("R", pattern = "\\.R$", full.names = TRUE))

if(is.na(Sys.getenv("COVERALLS_TOKEN", unset = NA))) {
  message("[Info] COVERALLS_TOKEN is unset")
  cov <- covr::package_coverage(function_exclusions = "\\.onLoad"
                                , line_exclusions   = line_exclusions
                                )
  covr::report(cov, browse = TRUE, file = file.path(getwd(), ".ci", "report.html"))
  cov
} else {
  covr::coveralls(function_exclusions = "\\.onLoad"
                  , line_exclusions   = line_exclusions
                  )
}
