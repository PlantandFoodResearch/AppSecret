#!/usr/bin/env Rscript

library(testthat)
library(AppSecret)

test_check("AppSecret", reporter = ifelse(length(commandArgs(trailingOnly = TRUE)) == 0, "progress", "summary"))
