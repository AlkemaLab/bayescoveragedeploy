# Examples for bayescoveragedeploy

This directory contains example scripts demonstrating how to use the bayescoveragedeploy package.

## Available Examples

### 1. basic_usage.R

A comprehensive introduction to fitting local country models with precompiled Stan models.

**Topics covered:**
- Loading and processing data
- Fitting a single country model
- Examining results and plotting
- Minimal/fast runs for testing
- Fitting multiple countries
- Using different indicators

**Run it:**
```r
source(system.file("examples/basic_usage.R", package = "bayescoveragedeploy"))
```

### 2. deployment_example.R

Replicates the deployment workflow, showing practical use cases.

**Topics covered:**
- Helper function for creating test data
- Fast testing vs production settings
- Performance comparison (precompiled vs on-demand compilation)
- Accessing and using model results
- Batch processing multiple countries

**Run it:**
```r
source(system.file("examples/deployment_example.R", package = "bayescoveragedeploy"))
```

## Prerequisites

Before running examples, ensure you have:

1. **Data files**: Survey data and region metadata
   ```
   data_raw/
   ├── ICEH_national.dta
   └── regions_updated.csv
   ```

2. **Required packages**:
   ```r
   install.packages(c("dplyr", "haven", "readr"))
   ```

3. **Parent package** (automatically installed as dependency):
   ```r
   # bayescoveragemodel is installed automatically with bayescoveragedeploy
   ```

## Quick Start

```r
library(bayescoveragedeploy)

# Load example
example_path <- system.file("examples/basic_usage.R", package = "bayescoveragedeploy")

# View the code
file.edit(example_path)

# Or run it directly
source(example_path)
```

## Minimal Working Example

```r
library(bayescoveragedeploy)
library(haven)

# Load data
dat0 <- read_dta("data_raw/ICEH_national.dta")
regions_dat <- readr::read_csv("data_raw/regions_updated.csv")

# Process
data <- bayescoveragemodel::process_data(
  dat = dat0,
  regions_dat = regions_dat,
  indicator = "anc4"
)

# Fit (fast test)
fit <- fit_local_model(
  survey_df = data,
  iso_select = "KEN",
  indicator = "anc4",
  chains = 1,
  iter_sampling = 5,
  iter_warmup = 5
)

# Results
print(fit$posteriors$temporal)
```

## Modifying Examples

All examples are designed to be easily modified:

1. **Change country**: Update `iso_select = "KEN"` to any ISO code
2. **Change indicator**: Use "anc4", "ideliv", "vdpt", etc.
3. **Adjust MCMC settings**: Modify `chains`, `iter_sampling`, `iter_warmup`
4. **Add plotting**: Use `bayescoveragemodel::plot_estimates_local_all(fit)`

## Notes

- Examples assume data is in `data_raw/` folder
- Fast examples use minimal iterations (5-10) for testing
- Production runs use 200+ iterations for reliable estimates
- All examples use precompiled models (no C++ compiler needed!)

## Getting Help

- Package documentation: `?fit_local_model`
- Parent package docs: `?bayescoveragemodel::fit_model`
- Issues: https://github.com/AlkemaLab/bayescoveragedeploy/issues
