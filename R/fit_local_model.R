#' Fit local country model with precompiled Stan models
#'
#' This function provides a simplified interface for fitting country-specific
#' models using precompiled Stan models. All data processing and model logic
#' is delegated to bayescoveragemodel::fit_model().
#'
#' @param survey_df Survey data (processed via bayescoveragemodel::process_data)
#' @param iso_select ISO code for the country
#' @param indicator Indicator name ("anc4", "ideliv", "vdpt", etc.)
#' @param routine_df Optional tibble with routine data
#' @param chains Number of MCMC chains (default 4)
#' @param iter_sampling Number of sampling iterations (default 200)
#' @param iter_warmup Number of warmup iterations (default 150)
#' @param seed Random seed (default 1234)
#' @param refresh Progress update frequency (default 10)
#' @param adapt_delta Target acceptance rate (default 0.9)
#' @param max_treedepth Maximum tree depth (default 14)
#' @param ... Additional arguments passed to bayescoveragemodel::fit_model()
#'
#' @return Model fit object (same structure as bayescoveragemodel::fit_model)
#' @export
#'
#' @examples
#' \dontrun{
#' # ===== Quick Example =====
#' library(haven)
#' dat0 <- read_dta("data_raw/ICEH_national.dta")
#' regions_dat <- readr::read_csv("data_raw/regions_updated.csv")
#'
#' # Process data
#' data <- bayescoveragemodel::process_data(
#'   dat = dat0,
#'   regions_dat = regions_dat,
#'   indicator = "anc4"
#' )
#'
#' # Fit model (fast test)
#' fit <- fit_local_model(
#'   survey_df = data,
#'   iso_select = "KEN",
#'   indicator = "anc4",
#'   chains = 1,
#'   iter_sampling = 5,
#'   iter_warmup = 5
#' )
#'
#' # Plot results
#' bayescoveragemodel::plot_estimates_local_all(fit)
#'
#' # ===== Production Example =====
#' fit_prod <- fit_local_model(
#'   survey_df = data,
#'   iso_select = "KEN",
#'   indicator = "anc4",
#'   chains = 4,
#'   iter_sampling = 200,
#'   iter_warmup = 150,
#'   seed = 123
#' )
#'
#' # ===== More Examples =====
#' # See inst/examples/ for comprehensive examples:
#' source(system.file("examples/basic_usage.R", package = "bayescoveragedeploy"))
#' source(system.file("examples/deployment_example.R", package = "bayescoveragedeploy"))
#' file.edit(system.file("examples/quick_reference.R", package = "bayescoveragedeploy"))
#' }
fit_local_model <- function(survey_df,
                            iso_select,
                            indicator = "anc4",
                            routine_df = NULL,
                            chains = 4,
                            iter_sampling = 200,
                            iter_warmup = 150,
                            seed = 1234,
                            refresh = 10,
                            adapt_delta = 0.9,
                            max_treedepth = 14,
                            ...) {


  # Determine which precompiled model to use
  model_name <- determine_model_variant(
    routine_df = routine_df,
    add_aggregates = FALSE  # local_national doesn't use aggregates
  )

  # Get precompiled model from this package
  precompiled_model <- get_precompiled_model(model_name)

  # Call parent package's fit_model with:
  # - All data processing and logic from parent
  # - Precompiled model from this package
  # - Force rstan backend and skip compilation
  bayescoveragemodel::fit_model(
    survey_df = survey_df,
    routine_df = routine_df,
    iso_select = iso_select,
    runstep = "local_national",
    backend = "rstan",
    compile_model = FALSE,  # Don't compile - use precompiled
    stan_model = precompiled_model,  # Pass our precompiled model
    chains = chains,
    iter_sampling = iter_sampling,
    iter_warmup = iter_warmup,
    seed = seed,
    refresh = refresh,
    adapt_delta = adapt_delta,
    max_treedepth = max_treedepth,
    ...
  )
}


#' Determine which Stan model variant to use
#'
#' @param routine_df Optional routine data
#' @param add_aggregates Whether aggregates are used
#' @return Model name string
#' @keywords internal
determine_model_variant <- function(routine_df = NULL, add_aggregates = FALSE) {
  # Determine which Stan model variant to use
  has_routine <- !is.null(routine_df)

  if (has_routine && add_aggregates) {
    "fpem_routine_aggregates"
  } else if (has_routine) {
    "fpem_routine"
  } else if (add_aggregates) {
    "fpem_aggregates"
  } else {
    "fpem"
  }
}

#' Get precompiled Stan model
#'
#' @param model_name Name of the Stan model
#' @return Precompiled Stan model object
#' @keywords internal
get_precompiled_model <- function(model_name) {
  # Get precompiled model from stanmodels list
  # (created automatically by rstantools during package installation)

  if (!model_name %in% names(stanmodels)) {
    stop("Precompiled model '", model_name, "' not found. ",
         "Available models: ", paste(names(stanmodels), collapse = ", "),
         call. = FALSE)
  }

  stanmodels[[model_name]]
}
