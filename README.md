
<!-- README.md is generated from README.Rmd. Please edit that file -->
[![Travis build status](https://travis-ci.com/PlantandFoodResearch/AppSecret.svg?token=Kpqpmk91fYg5k9hdqK3y&branch=master)](https://travis-ci.com/PlantandFoodResearch/AppSecret) [![Coverage Status](https://coveralls.io/repos/github/PlantandFoodResearch/AppSecret/badge.svg?branch=master&t=Z7xp1S)](https://coveralls.io/github/PlantandFoodResearch/AppSecret?branch=master)

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
#>  [1] d6 ff fb f9 1c ef a6 5b 33 87 39 f5 86 b2 6b d9 43 79 0a 73 94 57 55
#> [24] 52 27 9f e0 a4 cc 3e 41 b4
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

#### `app_secret_paths`

All of this path munging is not really application code's responsibility. There is a utility function `app_secret_paths` for doing this.

``` r
paths <- app_secret_paths(appname = "your-app-name")
str(paths)
#> List of 3
#>  $ symmetric_file: chr "/Users/hrards/.your-app-name/symmetric.rsa"
#>  $ key_file      : chr "/Users/hrards/.your-app-name/secret.pem"
#>  $ vault_path    : chr "/Users/hrards/.your-app-name"
```
