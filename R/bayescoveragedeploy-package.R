#' The 'bayescoveragedeploy' package.
#'
#' @description Provides precompiled Stan models for fitting local country-level
#' Bayesian hierarchical transition models for health coverage indicators
#' (ANC4, institutional delivery, vaccination). This package uses the rstan
#' backend with precompiled models for users without C++ compilers.
#' All core functionality is provided by the bayescoveragemodel package.
#'
#' @details
#' This package contains precompiled Stan models for the following variants:
#' \itemize{
#'   \item fpem - Basic transition model
#'   \item fpem_routine - Model with routine data
#'   \item fpem_aggregates - Model with subnational aggregates
#'   \item fpem_routine_aggregates - Model with routine data and aggregates
#' }
#'
#' The main user-facing function is \code{\link{fit_local_model}}.
#'
#'
#' @docType package
#' @name bayescoveragedeploy-package
#' @aliases bayescoveragedeploy
#' @useDynLib bayescoveragedeploy, .registration = TRUE
#' @import methods
#' @import Rcpp
#' @importFrom rstan sampling
#' @importFrom rstantools rstan_config
#' @importFrom RcppParallel RcppParallelLibs
#'
#' @references
#' Stan Development Team (NA). RStan: the R interface to Stan. R package version 2.32.7. https://mc-stan.org
#'
NULL
