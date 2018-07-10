
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
library(AppSecret)

password_file <- file.path(here(), ".user-settings", Sys.getenv("USER"), "password")

asm <- app_secret_manager(symmetric_file = file.path(here(), ".user-settings", Sys.getenv("USER"), "symmetric.rsa"),
                          key_file       = file.path(normalizePath("~"), ".app-name", "secret.pem"))
asm$symmetric_file
#> [1] "/Users/hrards/code/AppSecret/.user-settings/hrards/symmetric.rsa"
asm$key_file
#> [1] "/Users/hrards/.app-name/secret.pem"

encrypted <- asm$encrypt_data("this is my password")
#> decrypting symmetric file success

asm$write_encrypted(data = encrypted, file = password_file)

file.exists(password_file)
#> [1] TRUE

asm$read_encrypted(password_file)
#>  [1] 28 df 24 f8 80 18 0c 52 2e 1d d6 23 0b 1b 96 dd 4a 2c 6a 64 d8 87 24
#> [24] e3 cd 1e 6a 90 42 f7 30 c9
```

Somewhere in your application

``` r
library(here)
library(AppSecret)

password_file <- file.path(here(), ".user-settings", Sys.getenv("USER"), "password")

asm <- app_secret_manager(symmetric_file = file.path(here(), ".user-settings", Sys.getenv("USER"), "symmetric.rsa"),
                          key_file       = file.path(normalizePath("~"), ".app-name", "secret.pem"))

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
#> List of 2
#>  $ symmetric_file: chr "/Users/hrards/.your-app-name/symmetric.rsa"
#>  $ key_file      : chr "/Users/hrards/.your-app-name/secret.pem"
```

The `here()` function from the `here` package can be used by adding a value to the environment variable `APP_SECRET_USE_HERE` so that files can be stored with the application code. This is safe to do as the key pair will always be stored under a user's home directory.

``` r
#> using withr to safely temporarily set the variable in markdown
withr::with_envvar(c("APP_SECRET_USE_HERE" = 1), {
  paths <- app_secret_paths(appname = "another-name")
  str(paths)
})
#> List of 2
#>  $ symmetric_file: chr "/Users/hrards/code/AppSecret/.user-settings/hrards/symmetric.rsa"
#>  $ key_file      : chr "/Users/hrards/.another-name/secret.pem"
```

If the `.user-settings` path is not a desireable name the `base_path` argument may be passed.

``` r
paths <- app_secret_paths(appname = "your-app-name", base_path = here::here())
str(paths)
#> List of 2
#>  $ symmetric_file: chr "/Users/hrards/code/AppSecret/.your-app-name/symmetric.rsa"
#>  $ key_file      : chr "/Users/hrards/.your-app-name/secret.pem"
```

#### more simple application code

In less than 10 lines

``` r
library(AppSecret)
paths <- withr::with_envvar(c("APP_SECRET_USE_HERE" = 1),
                            app_secret_paths(appname = "app-name"))
#> create instance
asm <- do.call(app_secret_manager, paths)
#> where is the password file
paths$password_file <- asm$path_in_vault("password")
#> decrypt
password <- asm$decrypt_file(paths$password_file)
#> decrypting symmetric file success
password
#> [1] "this is my password"
```
