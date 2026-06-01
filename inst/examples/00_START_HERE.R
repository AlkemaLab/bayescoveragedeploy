# ============================================================================
#  BAYESCOVERAGEDEPLOY EXAMPLES - START HERE
# ============================================================================
#
# Welcome! This package provides precompiled Stan models for fitting
# local country-level Bayesian models WITHOUT needing a C++ compiler.
#
# Choose an example below based on your needs:

# ============================================================================
# OPTION 1: New to the package? Start with basic_usage.R
# ============================================================================

# This comprehensive tutorial covers:
#   - Loading and processing data
#   - Fitting a single country model
#   - Plotting and examining results
#   - Fast test runs vs production runs
#   - Fitting multiple countries
#   - Using different indicators

source(system.file("examples/basic_usage.R", package = "bayescoveragedeploy"))

# ============================================================================
# OPTION 2: Need deployment examples? See deployment_example.R
# ============================================================================

# This shows practical deployment workflows:
#   - Helper functions for creating test data
#   - Fast testing vs production settings
#   - Performance comparisons
#   - Batch processing multiple countries
#   - Accessing and using model results

source(system.file("examples/deployment_example.R", package = "bayescoveragedeploy"))

# ============================================================================
# OPTION 3: Looking for quick snippets? See quick_reference.R
# ============================================================================

# Copy-paste snippets for common tasks:
#   - Installation
#   - Basic workflow
#   - All available indicators
#   - Batch processing
#   - Accessing results
#   - Plotting
#   - Troubleshooting
#   - Performance tips

file.edit(system.file("examples/quick_reference.R", package = "bayescoveragedeploy"))

# ============================================================================
# MINIMAL WORKING EXAMPLE (copy-paste ready)
# ============================================================================

# Uncomment and run this minimal example:

# library(bayescoveragedeploy)
# library(haven)
# library(readr)
#
# # Load data
# dat0 <- read_dta("data_raw/ICEH_national.dta")
# regions_dat <- read_csv("data_raw/regions_updated.csv")
#
# # Process
# data <- bayescoveragemodel::process_data(
#   dat = dat0,
#   regions_dat = regions_dat,
#   indicator = "anc4"
# )
#
# # Fit (fast test - takes ~10 seconds)
# fit <- fit_local_model(
#   survey_df = data,
#   iso_select = "KEN",
#   indicator = "anc4",
#   chains = 1,
#   iter_sampling = 5,
#   iter_warmup = 5,
#   refresh = 0
# )
#
# # View results
# print(fit$posteriors$temporal)
# bayescoveragemodel::plot_estimates_local_all(fit)

# ============================================================================
# DOCUMENTATION
# ============================================================================

# View function documentation
?fit_local_model

# View package overview
?bayescoveragedeploy

# Read examples README
file.edit(system.file("examples/README.md", package = "bayescoveragedeploy"))

# ============================================================================
# AVAILABLE INDICATORS
# ============================================================================

# ANC: anc4, anc1trimester, ancq8
# Delivery: ideliv, sba
# Vaccination: vdpt, vmsl
# Other: bfexcl0_5, cci

# ============================================================================
# KEY ADVANTAGES
# ============================================================================

# 1. No C++ compiler required (models precompiled)
# 2. No compilation wait time (instant startup)
# 3. Easy installation from r-universe
# 4. Same functionality as bayescoveragemodel
# 5. Consistent results (rstan backend)

# ============================================================================
# GETTING HELP
# ============================================================================

# - Package documentation: ?fit_local_model
# - Parent package docs: ?bayescoveragemodel::fit_model
# - GitHub issues: https://github.com/AlkemaLab/bayescoveragedeploy/issues
# - Main package: https://github.com/AlkemaLab/bayescoveragemodel

# ============================================================================
# NEXT STEPS
# ============================================================================

cat("\n===============================================\n")
cat("  Welcome to bayescoveragedeploy!\n")
cat("===============================================\n\n")
cat("Choose an example to run:\n\n")
cat("1. Basic tutorial:\n")
cat("   source(system.file('examples/basic_usage.R', package = 'bayescoveragedeploy'))\n\n")
cat("2. Deployment workflow:\n")
cat("   source(system.file('examples/deployment_example.R', package = 'bayescoveragedeploy'))\n\n")
cat("3. Quick reference:\n")
cat("   file.edit(system.file('examples/quick_reference.R', package = 'bayescoveragedeploy'))\n\n")
cat("4. View examples README:\n")
cat("   file.edit(system.file('examples/README.md', package = 'bayescoveragedeploy'))\n\n")
cat("===============================================\n")
