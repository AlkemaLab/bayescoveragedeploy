---
editor_options: 
  markdown: 
    wrap: 72
---

# bayescoveragedeploy

Precompiled Stan models for fitting local country-level Bayesian
hierarchical transition models for health coverage indicators.

## Overview

`bayescoveragedeploy` is a deployment-focused package that provides
**precompiled Stan models** for users without C++ compilers. It is a
thin wrapper around the
[bayescoveragemodel](https://github.com/AlkemaLab/bayescoveragemodel)
package, which contains all the core functionality for fitting Bayesian
hierarchical transition models to health coverage indicators (ANC4,
institutional delivery, vaccination).

## Key Features

-   **No C++ compiler required**: Stan models are precompiled during
    package installation
-   **Fast startup**: No compilation wait time when running models
-   **Simple interface**: One focused function for fitting local country
    models
-   **Full functionality**: All data processing and analysis from
    bayescoveragemodel available

Binary packages are available for Windows and macOS.

## Installation

Installation instructions are on
<https://github.com/AlkemaLab/bayescoverage_app>.

To use the deploy package, install the following Bayescoverage-related
packages from github (now also available via R universe)

`devtools::install_github("AlkemaLab/bayescoveragemodel")`
`devtools::install_github("AlkemaLab/localhierarchy")`

Install the deploy-related packages from R universe:

`install.packages('bayescoveragedeploy', repos = c('https://alkemalab.r-universe.dev'))`

Also install the following package from CRAN:

`install.packages(c("dplyr", "haven", "ggplot2", "shiny", "posterior", "readr", "here", "stringr", "tibble"))`

For using routine data, brms is used as well, install using

`install.packages("brms")`

## Usage

### Quick Start

``` r
library(bayescoveragedeploy)
library(haven)
library(readr)

# Load data
dat0 <- read_dta("data_raw/ICEH_national.dta")
regions_dat <- read_csv("data_raw/regions_updated.csv")

# Process data using parent package functions
data <- bayescoveragemodel::process_data(
  dat = dat0,
  regions_dat = regions_dat,
  indicator = "anc4"
)

# Fit local model with precompiled Stan models
fit <- fit_local_model(
  survey_df = data,
  iso_select = "KEN",
  indicator = "anc4",
  chains = 4,
  iter_sampling = 200
)

# Plot results using parent package functions
bayescoveragemodel::plot_estimates_local_all(fit)
```

### Available indicators

The package includes global fit objects for:

-   `anc4` - Antenatal care (4+ visits)

-   `ideliv` - Institutional delivery

-   `vdpt` - DPT vaccination

-   `anc1trimester` - Antenatal care (first trimester)

-   `ancq8` - Antenatal care quality (8+ contacts)

-   `bfexcl0_5` - Exclusive breastfeeding (0-5 months)

-   `cci` - Comprehensive coverage index

-    `sba` - Skilled birth attendance

-    `vmsl` - Measles vaccination

### With routine data

``` r
# Fit model with routine data
fit <- fit_local_model(
  survey_df = data,
  routine_df = routine_data,
  iso_select = "KEN",
  indicator = "anc4"
)
```

## Package Architecture

This package contains:

-   **Precompiled Stan models**: 4 model variants (fpem, fpem_routine,
    fpem_aggregates, fpem_routine_aggregates)

-   **Thin wrapper function**: `fit_local_model()` delegates to
    `bayescoveragemodel::fit_model()`

All core functionality (data processing, model fitting logic, plotting,
etc.) comes from the `bayescoveragemodel` package.

## For Developers

### Updating the package

When `bayescoveragemodel` is updated:

1.  Check if Stan models changed (in `bayescoveragemodel/inst/stan/`)
2.  If changed, copy updated Stan files to
    `bayescoveragedeploy/inst/stan/`
3.  Update include paths if needed (should use `chunks/` prefix)
4.  Rebuild and test.

## License

MIT License - see LICENSE file

## References

Stan Development Team. RStan: the R interface to Stan.
<https://mc-stan.org>

## Links

-   Main package:
    [bayescoveragemodel](https://github.com/AlkemaLab/bayescoveragemodel)
-   Documentation: <https://alkemalab.github.io/bayescoveragemodel/>
-   Issues: <https://github.com/AlkemaLab/bayescoveragedeploy/issues>
