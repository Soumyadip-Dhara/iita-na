# Testing Guide for iita.na

This guide provides comprehensive instructions on how to test the `iita.na` R package, including installation, running tests, and manual verification.

**For validation against DAKS and missing data verification, see [VALIDATION.md](VALIDATION.md).**

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Quick Start](#quick-start)
3. [Running Automated Tests](#running-automated-tests)
4. [Manual Testing](#manual-testing)
5. [Testing with Your Own Data](#testing-with-your-own-data)
6. [Continuous Integration](#continuous-integration)
7. [Troubleshooting](#troubleshooting)

## Prerequisites

### Required Software

1. **R** (version 3.5.0 or higher)
   
   **Linux (Ubuntu/Debian):**
   ```bash
   sudo apt-get update
   sudo apt-get install r-base r-base-dev
   ```
   
   **macOS:**
   ```bash
   brew install r
   ```
   
   **Windows:**
   Download and install from [CRAN](https://cran.r-project.org/bin/windows/base/)

2. **R Packages for Testing**
   ```r
   install.packages(c("testthat", "devtools", "roxygen2"))
   ```

### Verify Installation

```bash
# Check R version
R --version

# Should show version 3.5.0 or higher
```

## Quick Start

The fastest way to test the package:

```bash
# 1. Clone the repository
git clone https://github.com/Soumyadip-Dhara/iita-na.git
cd iita-na

# 2. Build and install the package
R CMD build .
R CMD INSTALL iita.na_0.1.0.tar.gz

# 3. Run tests
R -e "testthat::test_package('iita.na')"
```

## Running Automated Tests

The package includes a comprehensive test suite with 13 tests covering all functionality.

### Method 1: Using testthat in R

```r
# Load required packages
library(testthat)
library(iita.na)

# Run all tests
test_package("iita.na")

# Run tests with detailed output
test_package("iita.na", reporter = "progress")

# Run a specific test file
test_file("tests/testthat/test-iita.R")
```

### Method 2: Using R CMD check

The most comprehensive testing method, includes all CRAN checks:

```bash
# Build the package
R CMD build .

# Run full checks
R CMD check --as-cran iita.na_0.1.0.tar.gz

# Run checks without building manual (faster)
R CMD check --no-manual iita.na_0.1.0.tar.gz
```

Expected output:
```
* using log directory '/path/to/iita.na.Rcheck'
* checking DESCRIPTION meta-information ... OK
* checking package namespace information ... OK
* checking package dependencies ... OK
...
Status: OK
```

### Method 3: Using devtools

```r
# From within R in the package directory
library(devtools)

# Load the package for development
load_all()

# Run tests
test()

# Check the package
check()
```

### Understanding Test Output

When tests run successfully, you'll see:
```
✓ | F W S  OK | Context
✓ |        13 | iita

══ Results ═════════════════════════════════════════════
Duration: 0.5 s

[ FAIL 0 | WARN 0 | SKIP 0 | PASS 13 ]
```

- **PASS**: Number of tests that passed (should be 13)
- **FAIL**: Number of tests that failed (should be 0)
- **WARN**: Number of warnings (should be 0)
- **SKIP**: Number of skipped tests (should be 0)

## Manual Testing

Manual testing helps verify the package works correctly in real-world scenarios.

### Test 1: Basic Functionality with Complete Data

```r
library(iita.na)

# Create a simple test dataset
data <- matrix(c(
  0, 0, 0,  # Subject 1: Failed all items
  1, 0, 0,  # Subject 2: Passed only item 1
  1, 1, 0,  # Subject 3: Passed items 1 and 2
  1, 1, 1   # Subject 4: Passed all items
), ncol = 3, byrow = TRUE)

# Run IITA
result <- iita(data)

# Verify output
print(result)

# Expected output structure:
# - Should show "Inductive Item Tree Analysis"
# - Number of items: 3
# - Should identify prerequisite structure (1→2→3)
# - Minimum diff value should be 0 (perfect fit)
```

### Test 2: Missing Data Handling

```r
# Create dataset with missing values
data_missing <- matrix(c(
  0, 0, 0,
  1, NA, 0,   # Missing value
  1, 1, NA,   # Missing value
  1, 1, 1
), ncol = 3, byrow = TRUE)

# Run IITA
result <- iita(data_missing)
print(result)

# Verify:
# - Should complete without errors
# - Should produce meaningful results despite missing data
# - Check result$diff has valid values (between 0 and 1)
```

### Test 3: Using Example Datasets

```r
# Test with complete data
data(knowledge_complete)
result_complete <- iita(knowledge_complete)
print(result_complete)

# Test with missing data
data(knowledge_missing)
result_missing <- iita(knowledge_missing, selrule = "corrected")
print(result_missing)

# Verify:
# - Both should run without errors
# - Results should be interpretable
# - Missing data version should handle NAs gracefully
```

### Test 4: Selection Rules

```r
data(knowledge_complete)

# Test minimal selection rule
result_minimal <- iita(knowledge_complete, selrule = "minimal")
cat("Minimal rule selected:", length(result_minimal$selection.set.index), "quasi-orders\n")

# Test corrected selection rule
result_corrected <- iita(knowledge_complete, selrule = "corrected")
cat("Corrected rule selected:", length(result_corrected$selection.set.index), "quasi-orders\n")

# Verify:
# - Corrected should select equal or more quasi-orders than minimal
# - Both should complete without errors
```

### Test 5: Edge Cases

```r
# Single item
data_single <- matrix(c(0, 1, 0, 1), ncol = 1)
result <- iita(data_single)
print(result)

# All missing data
data_all_na <- matrix(NA, nrow = 5, ncol = 3)
result <- iita(data_all_na)
print(result)

# All zeros
data_zeros <- matrix(0, nrow = 4, ncol = 3)
result <- iita(data_zeros)
print(result)

# All ones
data_ones <- matrix(1, nrow = 4, ncol = 3)
result <- iita(data_ones)
print(result)

# Verify:
# - All should run without errors or crashes
# - Results should be sensible given the data
```

## Testing with Your Own Data

### Preparing Your Data

Your data should be a matrix or data.frame where:
- Rows represent subjects/participants
- Columns represent items/questions
- Values are: 0 (failed), 1 (passed), or NA (missing)

```r
# Example: Load your data from CSV
my_data <- read.csv("my_test_data.csv")

# Convert to matrix if needed
my_data <- as.matrix(my_data)

# Verify data format
str(my_data)
summary(my_data)

# Check for non-binary values
unique(as.vector(my_data))  # Should only show 0, 1, NA

# Run IITA
result <- iita(my_data)
print(result)
```

### Validating Results

```r
# Check result structure
names(result)

# Examine diff values
print(result$diff)
hist(result$diff, main = "Distribution of Diff Values")

# View selected quasi-orders
print(result$selection.set.index)

# Examine implications
for (i in seq_along(result$implications)) {
  cat("\nQuasi-order", i, ":\n")
  qo <- result$implications[[i]]
  # Display prerequisite relations
  for (row in 1:nrow(qo)) {
    for (col in 1:ncol(qo)) {
      if (qo[row, col] == 1) {
        cat("  Item", row, "→ Item", col, "\n")
      }
    }
  }
}
```

## Continuous Integration

### Setting Up GitHub Actions

Create `.github/workflows/test.yml`:

```yaml
name: R Package Tests

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  test:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Setup R
      uses: r-lib/actions/setup-r@v2
      with:
        r-version: '4.2.0'
    
    - name: Install dependencies
      run: |
        install.packages(c("testthat", "roxygen2"))
      shell: Rscript {0}
    
    - name: Build package
      run: R CMD build .
    
    - name: Run tests
      run: |
        library(testthat)
        library(iita.na)
        test_package("iita.na")
      shell: Rscript {0}
    
    - name: Check package
      run: R CMD check --no-manual iita.na_*.tar.gz
```

### Local Pre-commit Testing

Create a pre-commit hook (`.git/hooks/pre-commit`):

```bash
#!/bin/bash

echo "Running R package tests..."
R -e "testthat::test_package('iita.na')" || {
    echo "Tests failed! Commit aborted."
    exit 1
}

echo "All tests passed!"
```

Make it executable:
```bash
chmod +x .git/hooks/pre-commit
```

## Troubleshooting

### Common Issues

#### Issue: "Error: package 'iita.na' is not installed"

**Solution:**
```bash
# Rebuild and reinstall the package
R CMD build .
R CMD INSTALL iita.na_0.1.0.tar.gz
```

#### Issue: "Error: testthat not found"

**Solution:**
```r
install.packages("testthat")
```

#### Issue: Tests fail with "object not found"

**Solution:**
```r
# Make sure package is loaded
library(iita.na)

# Or reinstall
devtools::install()
```

#### Issue: "namespace" errors

**Solution:**
```bash
# Clean build artifacts
rm -rf iita.na.Rcheck/
rm -f iita.na_*.tar.gz

# Rebuild from scratch
R CMD build .
R CMD INSTALL iita.na_0.1.0.tar.gz
```

#### Issue: Tests pass but package check fails

**Solution:**
```bash
# Run check with verbose output
R CMD check --as-cran iita.na_0.1.0.tar.gz

# Common fixes:
# 1. Update DESCRIPTION file dependencies
# 2. Fix documentation with roxygen2::roxygenise()
# 3. Ensure all exported functions have @export tags
```

### Getting Help

If you encounter issues not covered here:

1. **Check documentation**: `?iita` or `help(package = "iita.na")`
2. **Review test files**: See `tests/testthat/test-iita.R` for examples
3. **Check package structure**: Ensure all files are in correct locations
4. **Consult R documentation**: See [Writing R Extensions](https://cran.r-project.org/doc/manuals/R-exts.html)
5. **Open an issue**: https://github.com/Soumyadip-Dhara/iita-na/issues

## Performance Testing

### Testing with Large Datasets

```r
# Generate larger test dataset
set.seed(123)
n_subjects <- 100
n_items <- 6

large_data <- matrix(
  sample(c(0, 1, NA), n_subjects * n_items, replace = TRUE, prob = c(0.3, 0.6, 0.1)),
  nrow = n_subjects,
  ncol = n_items
)

# Time the analysis
system.time({
  result <- iita(large_data)
})

# Check results
print(result)
```

### Memory Usage Testing

```r
# Monitor memory usage
memory_before <- gc()

# Run analysis
result <- iita(large_data)

memory_after <- gc()

# Compare
cat("Memory used:", 
    memory_after[1,2] - memory_before[1,2], "MB\n")
```

## Best Practices

1. **Always run tests before committing**: Ensure your changes don't break existing functionality
2. **Test with different data types**: Try complete data, missing data, edge cases
3. **Verify backward compatibility**: Ensure complete data produces expected results
4. **Document your tests**: Add comments explaining what each test verifies
5. **Use meaningful test data**: Create datasets that reflect real-world scenarios
6. **Check test coverage**: Aim to test all functions and edge cases
7. **Keep tests fast**: Individual tests should run in milliseconds
8. **Use version control**: Commit tests alongside code changes

## Summary

This package includes:
- **13 automated tests** covering all major functionality
- **testthat framework** for structured testing
- **Example datasets** for validation
- **Comprehensive documentation** for all functions
- **Manual testing procedures** for verification

To test the package:
1. Install R and dependencies
2. Build and install the package
3. Run `test_package("iita.na")`
4. Verify all 13 tests pass

For questions or issues, please open an issue on GitHub.
