
<!-- README.md is generated from README.Rmd. Please edit that file -->
[![Travis build status](https://travis-ci.org/PlantandFoodResearch/AppSecret.svg?branch=master)](https://travis-ci.org/PlantandFoodResearch/AppSecret) [![Coverage status](https://coveralls.io/repos/github/PlantandFoodResearch/AppSecret/badge.svg)](https://coveralls.io/r/PlantandFoodResearch/AppSecret?branch=master)

AppSecret
=========

The goal of AppSecret is to manage application secrets for users, be they developers or test/production service users.

Installation
------------

AppSecret is not on CRAN. It is a private repository so create and expose `GITHUB_PAT` appropriately.

``` r
devtools::install_github("PlantandFoodResearch/AppSecret")
```

#### GITHUB\_PAT

from `?devtools::install_github`

    # To install from a private repo, use auth_token with a token
    # from https://github.com/settings/tokens. You only need the
    # repo scope. Best practice is to save your PAT in env var called
    # GITHUB_PAT.
    install_github("hadley/private", auth_token = "abc")

Example
-------

This is a basic example which shows you how to solve a common problem:

``` r
library(here)
#> here() starts at /Users/hrards/code/AppSecret
library(AppSecret)

password_file <- file.path(here(), ".user-settings", Sys.getenv("USER"), "password")

asm <- app_secret_manager(symmetric_file = file.path(here(), ".user-settings", Sys.getenv("USER"), "symmetric.rsa"),
                          key_file       = file.path(Sys.getenv("HOME"), ".app-name", "application-secrets.pem"))

encrypted <- asm$encrypt_data("this is my password")
#> decrypting symmetric file success

asm$write_encrypted(data = encrypted, file = password_file)

file.exists(password_file)
#> [1] TRUE

asm$read_encrypted(password_file)
#>  [1] aa 84 65 d2 b7 9d fb 43 4a 9b 4e e2 76 45 2c a3 3c 3d 93 0b 55 ba 8a
#> [24] e4 40 c1 8e 54 4e 4d 84 8b
```

Somewhere in your application

``` r
library(here)
library(AppSecret)

password_file <- file.path(here(), ".user-settings", Sys.getenv("USER"), "password")

asm <- app_secret_manager(symmetric_file = file.path(here(), ".user-settings", Sys.getenv("USER"), "symmetric.rsa"),
                          key_file       = file.path(Sys.getenv("HOME"), ".app-name", "application-secrets.pem"))

password <- asm$decrypt_file(password_file)
#> decrypting symmetric file success
password
#> [1] "this is my password"
```
