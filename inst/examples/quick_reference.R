# Quick Reference for bayescoveragedeploy
# Copy-paste snippets for common tasks

#------------------------------------------------------------------------------
# INSTALLATION
#------------------------------------------------------------------------------

# From r-universe (recommended - no C++ compiler needed)
install.packages('bayescoveragedeploy',
                 repos = 'https://alkemalab.r-universe.dev')

# From source (requires C++ toolchain)
devtools::install("path/to/bayescoveragedeploy")

#------------------------------------------------------------------------------
# BASIC WORKFLOW
#------------------------------------------------------------------------------

library(bayescoveragedeploy)
library(haven)
library(readr)

# 1. Load data
dat0 <- read_dta("data_raw/ICEH_national.dta")
regions_dat <- read_csv("data_raw/regions_updated.csv")

# 2. Process data
data <- bayescoveragemodel::process_data(
  dat = dat0,
  regions_dat = regions_dat,
  indicator = "anc4"  # or "ideliv", "vdpt", etc.
)

# 3. Fit model
fit <- fit_local_model(
  survey_df = data,
  iso_select = "KEN",
  indicator = "anc4"
)

# 4. Plot results
bayescoveragemodel::plot_estimates_local_all(fit)

#------------------------------------------------------------------------------
# FAST TEST RUN (for development/testing)
#------------------------------------------------------------------------------

fit_test <- fit_local_model(
  survey_df = data,
  iso_select = "KEN",
  indicator = "anc4",
  chains = 1,
  iter_sampling = 5,
  iter_warmup = 5,
  refresh = 0
)

#------------------------------------------------------------------------------
# PRODUCTION RUN (for analysis)
#------------------------------------------------------------------------------

fit_prod <- fit_local_model(
  survey_df = data,
  iso_select = "KEN",
  indicator = "anc4",
  chains = 4,
  iter_sampling = 200,
  iter_warmup = 150,
  seed = 123,
  adapt_delta = 0.9,
  max_treedepth = 14
)

#------------------------------------------------------------------------------
# AVAILABLE INDICATORS
#------------------------------------------------------------------------------

# ANC indicators
# - "anc4" - Antenatal care (4+ visits)
# - "anc1trimester" - ANC in first trimester
# - "ancq8" - ANC quality (8+ contacts)

# Delivery indicators
# - "ideliv" - Institutional delivery
# - "sba" - Skilled birth attendance

# Vaccination indicators
# - "vdpt" - DPT vaccination
# - "vmsl" - Measles vaccination

# Other
# - "bfexcl0_5" - Exclusive breastfeeding (0-5 months)
# - "cci" - Comprehensive coverage index

#------------------------------------------------------------------------------
# BATCH PROCESSING
#------------------------------------------------------------------------------

countries <- c("KEN", "UGA", "TZA")
results <- list()

for (iso in countries) {
  cat("Fitting:", iso, "\n")

  results[[iso]] <- fit_local_model(
    survey_df = data,
    iso_select = iso,
    indicator = "anc4",
    chains = 4,
    iter_sampling = 200,
    refresh = 0
  )

  # Save individual results
  saveRDS(results[[iso]],
          file = paste0("output/", iso, "_anc4_fit.rds"))
}

#------------------------------------------------------------------------------
# ACCESSING RESULTS
#------------------------------------------------------------------------------

# Posterior estimates (temporal trends)
temporal_ests <- fit$posteriors$temporal

# Filter to recent years
recent <- temporal_ests |>
  filter(year >= 2010) |>
  select(iso, year, median, lower, upper)

# Processed data with uncertainty
data_with_uncertainty <- fit$data

# Raw samples (if available)
if (!is.null(fit$samples)) {
  # Extract specific parameters
  library(posterior)
  draws <- posterior::as_draws(fit$samples)
}

#------------------------------------------------------------------------------
# PLOTTING
#------------------------------------------------------------------------------

# Main plot function
bayescoveragemodel::plot_estimates_local_all(fit)

# Custom plotting with ggplot2
library(ggplot2)

temporal_ests |>
  filter(year >= 2000) |>
  ggplot(aes(x = year, y = median)) +
  geom_line() +
  geom_ribbon(aes(ymin = lower, ymax = upper), alpha = 0.3) +
  labs(title = paste("ANC4 Coverage -", fit$iso_select),
       y = "Coverage (%)",
       x = "Year") +
  theme_minimal()

#------------------------------------------------------------------------------
# COMPARING MULTIPLE COUNTRIES
#------------------------------------------------------------------------------

# Combine results from batch processing
all_estimates <- bind_rows(
  lapply(names(results), function(iso) {
    results[[iso]]$posteriors$temporal |>
      mutate(country = iso)
  })
)

# Plot comparison
ggplot(all_estimates, aes(x = year, y = median, color = country)) +
  geom_line() +
  geom_ribbon(aes(ymin = lower, ymax = upper, fill = country),
              alpha = 0.2) +
  theme_minimal() +
  labs(title = "ANC4 Coverage Comparison")

#------------------------------------------------------------------------------
# TROUBLESHOOTING
#------------------------------------------------------------------------------

# Check available precompiled models
names(bayescoveragedeploy:::stanmodels)

# Check if global fit is available for indicator
tryCatch(
  bayescoveragedeploy:::get_global_fit("anc4"),
  error = function(e) print(e)
)

# View package version
packageVersion("bayescoveragedeploy")
packageVersion("bayescoveragemodel")

# Get help
?fit_local_model
?bayescoveragemodel::fit_model

#------------------------------------------------------------------------------
# ADVANCED: CUSTOM SETTINGS
#------------------------------------------------------------------------------

# Pass additional arguments to bayescoveragemodel::fit_model
fit_custom <- fit_local_model(
  survey_df = data,
  iso_select = "KEN",
  indicator = "anc4",
  chains = 4,
  iter_sampling = 200,
  # Additional arguments passed to fit_model
  start_year = 2000,
  end_year = 2030,
  save_post_summ = TRUE
)

#------------------------------------------------------------------------------
# PERFORMANCE TIPS
#------------------------------------------------------------------------------

# 1. Use fewer iterations for testing
#    chains = 1, iter_sampling = 5, iter_warmup = 5

# 2. Use refresh = 0 to suppress progress output in batch runs

# 3. Parallel processing for multiple countries
library(parallel)
ncores <- detectCores() - 1

results_parallel <- mclapply(countries, function(iso) {
  fit_local_model(
    survey_df = data,
    iso_select = iso,
    indicator = "anc4",
    chains = 2,
    iter_sampling = 100
  )
}, mc.cores = ncores)

# 4. Save only what you need
#    Set save_post_summ = FALSE if you don't need summary objects

#------------------------------------------------------------------------------
# REPRODUCIBILITY
#------------------------------------------------------------------------------

# Always set seed for reproducibility
fit_reproducible <- fit_local_model(
  survey_df = data,
  iso_select = "KEN",
  indicator = "anc4",
  seed = 12345  # Use same seed to get identical results
)

# Document session info
session_info <- sessionInfo()
writeLines(capture.output(sessionInfo()), "session_info.txt")
