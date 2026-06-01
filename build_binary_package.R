#!/usr/bin/env Rscript
# Build Binary Package Script for bayescoveragedeploy
# This script automates the process of building a binary package with precompiled Stan models

# =============================================================================
# Setup and Configuration
# =============================================================================

# Check if required packages are installed
required_packages <- c("devtools", "pkgbuild", "rstantools", "desc")
missing_packages <- required_packages[!sapply(required_packages, requireNamespace, quietly = TRUE)]

if (length(missing_packages) > 0) {
  cat("Installing required packages:", paste(missing_packages, collapse = ", "), "\n")
  install.packages(missing_packages)
}

# Load required libraries
library(devtools)
library(pkgbuild)

# Get package directory (assumes script is run from package root)
pkg_dir <- getwd()
cat("Package directory:", pkg_dir, "\n")

# Read package info
pkg_name <- desc::desc_get_field("Package", file = file.path(pkg_dir, "DESCRIPTION"))
pkg_version <- desc::desc_get_field("Version", file = file.path(pkg_dir, "DESCRIPTION"))
cat("Building:", pkg_name, "version", pkg_version, "\n\n")

# =============================================================================
# Step 1: Clean Previous Builds
# =============================================================================

cat("Step 1: Cleaning previous builds...\n")

# Clean up old build artifacts
clean_dll()

# Remove old package files from parent directory
parent_dir <- dirname(pkg_dir)
old_files <- list.files(
  parent_dir,
  pattern = paste0(pkg_name, "_.*\\.(tar\\.gz|tgz|zip)$"),
  full.names = TRUE
)

if (length(old_files) > 0) {
  cat("  Removing old package files:\n")
  for (f in old_files) {
    cat("    -", basename(f), "\n")
    file.remove(f)
  }
} else {
  cat("  No old package files found.\n")
}

cat("  Done.\n\n")

# =============================================================================
# Step 2: Compile Stan Models
# =============================================================================

cat("Step 2: Compiling Stan models...\n")
cat("  This may take several minutes...\n")

# Compile the package DLL with Stan models
tryCatch({
  compile_dll(force = TRUE)
  cat("  Compilation successful!\n")
}, error = function(e) {
  cat("  ERROR during compilation:\n")
  cat("  ", conditionMessage(e), "\n")
  stop("Compilation failed. Please fix errors and try again.")
})

# Verify compiled files exist
compiled_files <- list.files("src", pattern = "stanExports_.*\\.(cc|h|o)$")
if (length(compiled_files) == 0) {
  stop("No compiled Stan files found in src/ directory!")
}

cat("  Found", length(compiled_files), "compiled Stan files in src/\n")
cat("  Done.\n\n")

# =============================================================================
# Step 3: Run Package Checks (Optional but Recommended)
# =============================================================================

cat("Step 3: Running package checks (this may take a while)...\n")
cat("  You can skip this by setting CHECK_PACKAGE = FALSE at the top of this script.\n")

CHECK_PACKAGE <- TRUE  # Set to FALSE to skip checks

if (CHECK_PACKAGE) {
  tryCatch({
    check_results <- devtools::check(error_on = "never")

    if (length(check_results$errors) > 0) {
      cat("  ERRORS found during check:\n")
      print(check_results$errors)
      cat("\n  Fix errors before building binary package.\n")
      stop("Package check failed with errors.")
    }

    if (length(check_results$warnings) > 0) {
      cat("  WARNINGS found during check:\n")
      print(check_results$warnings)
      cat("\n")
    }

    cat("  Check completed successfully!\n")
  }, error = function(e) {
    cat("  Check failed:\n")
    cat("  ", conditionMessage(e), "\n")
    cat("  Consider fixing issues before proceeding.\n")
  })
} else {
  cat("  Skipping package checks.\n")
}

cat("  Done.\n\n")

# =============================================================================
# Step 4: Build Source Package
# =============================================================================

cat("Step 4: Building source package...\n")

tryCatch({
  source_pkg <- devtools::build(binary = FALSE, vignettes = FALSE)
  cat("  Source package created:", basename(source_pkg), "\n")
}, error = function(e) {
  cat("  ERROR building source package:\n")
  cat("  ", conditionMessage(e), "\n")
  stop("Source package build failed.")
})

cat("  Done.\n\n")

# =============================================================================
# Step 5: Build Binary Package
# =============================================================================

cat("Step 5: Building binary package for current platform...\n")
cat("  Platform:", R.version$platform, "\n")
cat("  OS:", R.version$os, "\n")

tryCatch({
  binary_pkg <- devtools::build(binary = TRUE, vignettes = FALSE)
  cat("  Binary package created:", basename(binary_pkg), "\n")
}, error = function(e) {
  cat("  ERROR building binary package:\n")
  cat("  ", conditionMessage(e), "\n")
  stop("Binary package build failed.")
})

cat("  Done.\n\n")

# =============================================================================
# Step 6: Package Information Summary
# =============================================================================

cat("========================================\n")
cat("BUILD SUMMARY\n")
cat("========================================\n")
cat("Package:", pkg_name, "\n")
cat("Version:", pkg_version, "\n")
cat("Platform:", R.version$platform, "\n\n")

cat("Created files:\n")
cat("  Source package:", basename(source_pkg), "\n")
cat("    Location:", source_pkg, "\n")
cat("    Size:", format(file.size(source_pkg) / 1024^2, digits = 2), "MB\n\n")

cat("  Binary package:", basename(binary_pkg), "\n")
cat("    Location:", binary_pkg, "\n")
cat("    Size:", format(file.size(binary_pkg) / 1024^2, digits = 2), "MB\n\n")

# =============================================================================
# Step 7: Test Installation (Optional)
# =============================================================================

cat("========================================\n")
cat("OPTIONAL: Test Installation\n")
cat("========================================\n")
cat("To test the binary package, run:\n\n")
cat("  install.packages('", binary_pkg, "',\n", sep = "")
cat("                   repos = NULL,\n")
cat("                   type = 'binary')\n\n")
cat("To test the source package, run:\n\n")
cat("  install.packages('", source_pkg, "',\n", sep = "")
cat("                   repos = NULL,\n")
cat("                   type = 'source')\n\n")

# =============================================================================
# Step 8: Distribution Guidance
# =============================================================================

cat("========================================\n")
cat("NEXT STEPS: Distribution\n")
cat("========================================\n")
cat("To distribute your binary package:\n\n")

cat("1. GitHub Release:\n")
cat("   - Create a new release on GitHub\n")
cat("   - Upload", basename(binary_pkg), "as a release asset\n")
cat("   - Upload", basename(source_pkg), "as a fallback\n\n")

cat("2. For multi-platform support:\n")
cat("   - Build on macOS for .tgz (macOS binary)\n")
cat("   - Build on Windows for .zip (Windows binary)\n")
cat("   - Build on Linux for .tar.gz (Linux binary)\n")
cat("   - Or use GitHub Actions (see BINARY_PACKAGE_GUIDE.md)\n\n")

cat("3. R-universe (Recommended for automatic multi-platform builds):\n")
cat("   - Visit https://r-universe.dev\n")
cat("   - Register your package repository\n")
cat("   - Binaries will be built automatically\n\n")

cat("See BINARY_PACKAGE_GUIDE.md for detailed distribution options.\n\n")

cat("========================================\n")
cat("BUILD COMPLETE!\n")
cat("========================================\n")
