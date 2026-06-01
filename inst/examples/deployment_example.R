# Deployment Example for bayescoveragedeploy
#
# This example replicates the deployment workflow from analysis/deployment.R
# showing how to fit a local_national model with precompiled Stan models

library(bayescoveragedeploy)
library(dplyr)
library(tibble)
library(haven)

#------------------------------------------------------------------------------
# Helper function to create test data
#------------------------------------------------------------------------------

create_test_data <- function(data_folder = "data_raw", indicator = "anc4", seed = 123) {
  set.seed(seed)

  # Read national survey data and region metadata
  dat0 <- read_dta(file.path(data_folder, "ICEH_national.dta"))
  regions_dat <- readr::read_csv(file.path(data_folder, "regions_updated.csv"))

  # Process data
  data <- bayescoveragemodel::process_data(
    dat = dat0,
    regions_dat = regions_dat,
    indicator = indicator
  )

  return(data)
}

#------------------------------------------------------------------------------
# Create test data
#------------------------------------------------------------------------------

test_data <- create_test_data(
  data_folder = "data_raw",
  indicator = "anc4"
)

#------------------------------------------------------------------------------
# Example 1: Minimal settings for fast testing
#------------------------------------------------------------------------------

cat("\n=== Example 1: Fast test run ===\n")

fit_args_fast <- list(
  survey_df = test_data,
  iso_select = "KEN",  # Kenya
  indicator = "anc4",
  chains = 1,
  iter_sampling = 5,
  iter_warmup = 5,
  refresh = 0,
  seed = 123
)

fit_fast <- do.call(fit_local_model, fit_args_fast)

cat("Fast fit completed successfully!\n")
cat("Posteriors available:", !is.null(fit_fast$posteriors), "\n")
cat("Number of observations:", nrow(fit_fast$data), "\n")

#------------------------------------------------------------------------------
# Example 2: Production settings with more iterations
#------------------------------------------------------------------------------

cat("\n=== Example 2: Production run ===\n")

fit_args_production <- list(
  survey_df = test_data,
  iso_select = "KEN",
  indicator = "anc4",
  chains = 4,
  iter_sampling = 200,
  iter_warmup = 150,
  refresh = 50,
  seed = 123
)

fit_production <- do.call(fit_local_model, fit_args_production)

# Plot results
bayescoveragemodel::plot_estimates_local_all(fit_production)

#------------------------------------------------------------------------------
# Example 3: Different indicator
#------------------------------------------------------------------------------

cat("\n=== Example 3: Institutional delivery ===\n")

test_data_ideliv <- create_test_data(
  data_folder = "data_raw",
  indicator = "ideliv"
)

fit_ideliv <- fit_local_model(
  survey_df = test_data_ideliv,
  iso_select = "UGA",  # Uganda
  indicator = "ideliv",
  chains = 2,
  iter_sampling = 100,
  iter_warmup = 100,
  seed = 456
)

#------------------------------------------------------------------------------
# Example 4: Comparing precompiled vs on-demand compilation (if available)
#------------------------------------------------------------------------------

cat("\n=== Example 4: Performance comparison ===\n")

# Using precompiled models (bayescoveragedeploy)
cat("Fitting with precompiled models...\n")
start_time <- Sys.time()

fit_precompiled <- fit_local_model(
  survey_df = test_data,
  iso_select = "KEN",
  indicator = "anc4",
  chains = 1,
  iter_sampling = 10,
  iter_warmup = 10,
  refresh = 0
)

time_precompiled <- difftime(Sys.time(), start_time, units = "secs")
cat("Time with precompiled models:", round(time_precompiled, 2), "seconds\n")

# Note: The precompiled version skips compilation time entirely!
# If you were to compile on-demand (with cmdstanr), it would take
# an additional ~60-120 seconds on first run.

#------------------------------------------------------------------------------
# Example 5: Accessing and using results
#------------------------------------------------------------------------------

cat("\n=== Example 5: Working with results ===\n")

# Access posterior summaries
if (!is.null(fit_production$posteriors)) {
  cat("\nPosterior components available:\n")
  cat("  - temporal:", !is.null(fit_production$posteriors$temporal), "\n")

  # Show temporal estimates
  if (!is.null(fit_production$posteriors$temporal)) {
    temporal_ests <- fit_production$posteriors$temporal %>%
      filter(year >= 2010) %>%
      select(iso, year, median, lower, upper)

    cat("\nTemporal estimates (2010 onwards):\n")
    print(head(temporal_ests))
  }
}

# Access data with uncertainty
cat("\nData structure:\n")
cat("  - Rows:", nrow(fit_production$data), "\n")
cat("  - Columns:", ncol(fit_production$data), "\n")
cat("  - Key columns:", paste(head(names(fit_production$data), 10), collapse = ", "), "\n")

#------------------------------------------------------------------------------
# Example 6: Batch processing multiple countries
#------------------------------------------------------------------------------

cat("\n=== Example 6: Batch processing ===\n")

countries <- c("KEN", "UGA", "TZA")
results <- list()

for (iso in countries) {
  cat("\nProcessing:", iso, "\n")

  results[[iso]] <- fit_local_model(
    survey_df = test_data,
    iso_select = iso,
    indicator = "anc4",
    chains = 1,
    iter_sampling = 5,
    iter_warmup = 5,
    refresh = 0
  )

  cat("  - Completed:", iso, "\n")
}

cat("\nProcessed", length(results), "countries\n")

#------------------------------------------------------------------------------
# Summary
#------------------------------------------------------------------------------

cat("\n=== Summary ===\n")
cat("All examples completed successfully!\n")
cat("\nKey advantages of bayescoveragedeploy:\n")
cat("  1. No C++ compiler required\n")
cat("  2. No compilation wait time (models precompiled)\n")
cat("  3. Same functionality as bayescoveragemodel\n")
cat("  4. Simple installation from r-universe\n")
cat("  5. Consistent results (uses rstan backend)\n")
