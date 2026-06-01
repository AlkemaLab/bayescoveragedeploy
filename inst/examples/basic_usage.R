# Basic Usage Example for bayescoveragedeploy
#
# This example demonstrates how to fit a local country-level model
# using precompiled Stan models (no C++ compiler required)

devtools::load_all(here::here("../bayescoveragemodel/"))
devtools::load_all(here::here("../bayescoveragedeploy/"))
library(bayescoveragedeploy)
library(localhierarchy) # for check_nas... to update!
library(dplyr)
library(haven)
library(readr)

#------------------------------------------------------------------------------
# Step 1: Load and Process Data
#------------------------------------------------------------------------------

# Load raw survey data and region metadata
# Note: Adjust paths to your data location
data_folder <- here::here("data_raw")
dat0 <- read_dta(file.path(data_folder, "ICEH_national.dta"))
regions_dat <- read_csv(file.path(data_folder, "regions_updated.csv"))

# Choose an indicator: "anc4", "ideliv", or "vdpt"
indicator_select <- "anc4"

# Process data using bayescoveragemodel functions
# This filters, transforms, and prepares data for model fitting
data <- bayescoveragemodel::process_data(
  dat = dat0,
  regions_dat = regions_dat,
  indicator = indicator_select
)

# Optional: Explore the processed data
#bayescoveragemodel::explore_data(data, indicator = indicator_select)

#------------------------------------------------------------------------------
# Step 2: Fit Local Country Model
#------------------------------------------------------------------------------

# Select country to fit
iso_select <- "KEN"  # Kenya

# Fit model with precompiled Stan models (no compilation needed!)
#devtools::load_all(here::here("../bayescoveragemodel/"))
#devtools::load_all(here::here("../bayescoveragedeploy/"))

fit <- fit_local_model(
  survey_df = data,
  iso_select = iso_select,
  indicator = indicator_select,
  chains = 4,              # Number of MCMC chains
  iter_sampling = 200,     # Sampling iterations per chain
  iter_warmup = 150,       # Warmup iterations per chain
  seed = 123,              # For reproducibility
  refresh = 50             # Progress update frequency
)

#------------------------------------------------------------------------------
# Step 3: Examine Results
#------------------------------------------------------------------------------

# Plot estimates for the country
bayescoveragemodel::plot_estimates_local_all(fit)

# Access posterior samples
str(fit$posteriors)

# Access processed data with uncertainty
head(fit$data)

#------------------------------------------------------------------------------
# Step 4: Minimal/Fast Example for Testing
#------------------------------------------------------------------------------

# For quick testing, use minimal MCMC settings
fit_fast <- fit_local_model(
  survey_df = data,
  iso_select = iso_select,
  indicator = indicator_select,
  chains = 1,
  iter_sampling = 5,
  iter_warmup = 5,
  refresh = 0,
  seed = 123
)

print("Fast fit completed successfully!")

#------------------------------------------------------------------------------
# Additional Examples
#------------------------------------------------------------------------------

# Example: Fit multiple countries
countries_to_fit <- c("KEN", "UGA", "TZA")

# Note: In practice, you'd loop through countries
# For demonstration, fit one:
for (iso in countries_to_fit[1]) {
  cat("\nFitting country:", iso, "\n")

  country_fit <- fit_local_model(
    survey_df = data,
    iso_select = iso,
    indicator = indicator_select,
    chains = 2,
    iter_sampling = 100,
    iter_warmup = 100,
    refresh = 0
  )

  # Save results
  saveRDS(country_fit,
          file = paste0("output/", indicator_select, "_", iso, "_fit.rds"))
}

#------------------------------------------------------------------------------
# Example: Different Indicators
#------------------------------------------------------------------------------

# Process and fit for institutional delivery
data_ideliv <- bayescoveragemodel::process_data(
  dat = dat0,
  regions_dat = regions_dat,
  indicator = "ideliv"
)

fit_ideliv <- fit_local_model(
  survey_df = data_ideliv,
  iso_select = "KEN",
  indicator = "ideliv",
  chains = 2,
  iter_sampling = 100
)

# Process and fit for vaccination
data_vdpt <- bayescoveragemodel::process_data(
  dat = dat0,
  regions_dat = regions_dat,
  indicator = "vdpt"
)

fit_vdpt <- fit_local_model(
  survey_df = data_vdpt,
  iso_select = "KEN",
  indicator = "vdpt",
  chains = 2,
  iter_sampling = 100
)
