# Step-by-Step Testing Guide for iita.na Package
## From Cloning to Complete Test Results

This guide provides a complete, step-by-step walkthrough for testing the iita.na package from scratch, including how to test with various matrix sizes and missing data patterns, and verify DAKS compatibility.

---

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Step 1: Clone the Repository](#step-1-clone-the-repository)
3. [Step 2: Install R and Dependencies](#step-2-install-r-and-dependencies)
4. [Step 3: Quick Functionality Test](#step-3-quick-functionality-test)
5. [Step 4: Run the Comprehensive Test Report](#step-4-run-the-comprehensive-test-report)
6. [Step 5: Test Various Matrix Sizes](#step-5-test-various-matrix-sizes)
7. [Step 6: Test Missing Data Patterns](#step-6-test-missing-data-patterns)
8. [Step 7: Verify DAKS Compatibility](#step-7-verify-daks-compatibility)
9. [Step 8: Run Automated Test Suite](#step-8-run-automated-test-suite)
10. [Understanding Test Results](#understanding-test-results)
11. [Troubleshooting](#troubleshooting)

---

## Prerequisites

Before starting, ensure you have:
- Git (for cloning the repository)
- R (version >= 3.5.0)
- A terminal or command prompt
- Internet connection (for downloading R packages)

---

## Step 1: Clone the Repository

Open a terminal and clone the repository:

```bash
# Clone the repository
git clone https://github.com/Soumyadip-Dhara/iita-na.git

# Navigate to the project directory
cd iita-na

# Verify the files are present
ls -la
```

You should see files including:
- `R/` - Directory containing the R source code
- `tests/` - Directory containing test files
- `examples/` - Directory containing example scripts
- `DESCRIPTION` - Package description file
- `README.md` - Package documentation

---

## Step 2: Install R and Dependencies

### On Ubuntu/Debian:

```bash
# Install R
sudo apt update
sudo apt install -y r-base r-base-dev

# Verify R installation
R --version
```

### On macOS:

```bash
# Using Homebrew
brew install r

# Or download from: https://cran.r-project.org/bin/macosx/
```

### On Windows:

Download and install R from: https://cran.r-project.org/bin/windows/base/

### Install R Packages (Optional but Recommended):

```r
# Start R
R

# In R console, install testthat for automated testing
install.packages("testthat")

# Optional: Install DAKS for compatibility comparison
install.packages("DAKS")
```

---

## Step 3: Quick Functionality Test

Let's verify the basic functionality works:

```bash
# From the iita-na directory
Rscript -e "
# Load the functions
source('R/iita.R')
source('R/data.R')

# Test 1: Complete data
cat('Test 1: Complete data\n')
data <- matrix(c(0, 0, 0, 1, 0, 0, 1, 1, 0, 1, 1, 1), ncol = 3, byrow = TRUE)
result <- iita_na(data)
cat('  Status:', ifelse(is.list(result), 'PASS ✓', 'FAIL ✗'), '\n')

# Test 2: Missing data
cat('Test 2: Missing data\n')
data_na <- matrix(c(0, 0, 0, 1, NA, 0, 1, 1, NA, 1, 1, 1), ncol = 3, byrow = TRUE)
result_na <- iita_na(data_na)
cat('  Status:', ifelse(is.list(result_na), 'PASS ✓', 'FAIL ✗'), '\n')

cat('\nBasic tests completed!\n')
"
```

Expected output:
```
Test 1: Complete data
  Status: PASS ✓
Test 2: Missing data
  Status: PASS ✓

Basic tests completed!
```

---

## Step 4: Run the Comprehensive Test Report

This is the main testing script that documents findings for various scenarios:

```bash
# Run the comprehensive test report
Rscript examples/generate_test_report.R
```

This script will:
1. Test various matrix sizes (2x4 to 100x15)
2. Test missing data at different levels (0%, 10%, 25%, 50%)
3. Verify DAKS compatibility
4. Generate a detailed summary

Expected runtime: 10-30 seconds

**What to look for in the output:**
- All tests should show "✓ PASS"
- Matrix size tests should complete successfully
- Missing data tests should handle all levels
- DAKS compatibility tests should show 5/5 passed
- Final summary should indicate "ALL PASS"

---

## Step 5: Test Various Matrix Sizes

To understand how the algorithm performs with different data sizes:

```r
# Start R
R

# Load the functions
source("R/iita.R")
source("R/data.R")

# Test different matrix sizes
test_sizes <- function() {
  sizes <- list(
    list(name = "Small", rows = 5, cols = 3),
    list(name = "Medium", rows = 20, cols = 5),
    list(name = "Large", rows = 50, cols = 10)
  )
  
  for (test in sizes) {
    cat(sprintf("\nTesting %s (%dx%d):\n", test$name, test$rows, test$cols))
    
    # Generate random data
    set.seed(123)
    data <- matrix(rbinom(test$rows * test$cols, 1, 0.5), ncol = test$cols)
    
    # Run analysis
    start_time <- Sys.time()
    result <- iita_na(data)
    duration <- as.numeric(difftime(Sys.time(), start_time, units = "secs"))
    
    # Report results
    cat(sprintf("  Min diff: %.4f\n", min(result$diff)))
    cat(sprintf("  Max diff: %.4f\n", max(result$diff)))
    cat(sprintf("  Quasi-orders tested: %d\n", result$nq))
    cat(sprintf("  Selected: %d\n", length(result$selection.set.index)))
    cat(sprintf("  Time: %.3f seconds\n", duration))
  }
}

# Run the tests
test_sizes()
```

**Expected behavior:**
- All sizes should complete successfully
- Larger datasets may have lower diff values (more data = better fit)
- Computation time should increase with data size
- All diff values should be between 0 and 1

---

## Step 6: Test Missing Data Patterns

To understand how the algorithm handles missing data:

```r
# In R console
source("R/iita.R")
source("R/data.R")

# Test missing data at various levels
test_missing_data <- function() {
  # Generate base data
  set.seed(42)
  base_data <- matrix(rbinom(100, 1, 0.6), ncol = 5)
  
  missing_levels <- c(0, 0.10, 0.25, 0.50)
  
  cat("\nTesting Missing Data Patterns:\n")
  cat("================================\n")
  
  for (pct in missing_levels) {
    test_data <- base_data
    
    # Add missing values
    if (pct > 0) {
      missing_mask <- matrix(runif(100) < pct, ncol = 5)
      test_data[missing_mask] <- NA
    }
    
    actual_missing <- sum(is.na(test_data)) / length(test_data)
    
    # Run analysis
    result <- iita_na(test_data)
    
    # Report results
    cat(sprintf("\n%.0f%% Target Missing (Actual: %.1f%%):\n", 
                pct * 100, actual_missing * 100))
    cat(sprintf("  Min diff: %.4f\n", min(result$diff)))
    cat(sprintf("  Selected quasi-orders: %d\n", 
                length(result$selection.set.index)))
    cat(sprintf("  Status: %s\n", 
                ifelse(length(result$selection.set.index) > 0, "✓ PASS", "✗ FAIL")))
  }
}

# Run the tests
test_missing_data()
```

**Expected behavior:**
- All levels should complete successfully
- Results should be stable up to ~25% missing
- With 50% missing, more quasi-orders may be selected (less definitive)
- Algorithm should handle even extreme missing data gracefully

---

## Step 7: Verify DAKS Compatibility

To verify that results match DAKS for complete data:

### Option 1: Run the validation script

```bash
Rscript examples/validate_daks_compatibility.R
```

This script runs comprehensive validation tests without requiring DAKS installation.

### Option 2: Direct comparison (if DAKS is installed)

```r
# In R console
source("R/iita.R")
source("R/data.R")

# If DAKS is installed
if (requireNamespace("DAKS", quietly = TRUE)) {
  library(DAKS)
  
  # Test data
  test_data <- matrix(c(
    0, 0, 0,
    1, 0, 0,
    1, 1, 0,
    1, 1, 1
  ), ncol = 3, byrow = TRUE)
  
  # Run both implementations
  result_daks <- DAKS::iita(test_data)
  result_iitana <- iita_na(test_data)
  
  # Compare results
  cat("Comparison Results:\n")
  cat("===================\n")
  cat("Diff values match:", 
      all.equal(result_daks$diff, result_iitana$diff), "\n")
  cat("Selections match:", 
      all.equal(result_daks$selection.set.index, 
                result_iitana$selection.set.index), "\n")
  cat("Error rates match:", 
      all.equal(result_daks$error.rate, result_iitana$error.rate), "\n")
} else {
  cat("DAKS not installed. Install with: install.packages('DAKS')\n")
}
```

**Expected behavior:**
- For complete data, all comparisons should return TRUE
- Diff values should be identical
- Selection indices should be identical
- Error rates should be identical

---

## Step 8: Run Automated Test Suite

If you have testthat installed, run the full automated test suite:

```r
# In R console
library(testthat)

# Run all tests
test_dir("tests/testthat")

# Or run specific test files
test_file("tests/testthat/test-iita.R")
test_file("tests/testthat/test-matrix-sizes.R")
test_file("tests/testthat/test-daks-compatibility.R")
test_file("tests/testthat/test-daks-exact-match.R")
```

**Expected output:**
- Most tests should pass (✓)
- Any failures should be clearly indicated (✗)
- Summary at the end showing total tests run and passed

---

## Understanding Test Results

### What "PASS" means:

1. **Complete Data Tests**: 
   - Results match expected DAKS behavior
   - Diff values are in valid range [0, 1]
   - At least one quasi-order is selected
   - Results are deterministic

2. **Missing Data Tests**:
   - Algorithm completes without errors
   - Handles missing values appropriately
   - Results are reasonable given available data

3. **Performance Tests**:
   - Computation completes in reasonable time
   - Memory usage is acceptable
   - Scales appropriately with data size

### Interpreting Diff Values:

- **diff = 0**: Perfect fit, no violations of the quasi-order
- **diff = 0.1**: 10% of comparisons violate the quasi-order
- **diff = 0.5**: 50% violation rate - poor fit
- **diff = 1.0**: Complete mismatch (rare in practice)

### Understanding Selection:

- **1 quasi-order selected**: Clear best structure identified
- **Multiple selected**: Several structures fit equally well
- **Many selected**: Data may be ambiguous or random

---

## Troubleshooting

### Problem: "R command not found"

**Solution**: Install R following instructions in Step 2

### Problem: "package not installed" error

**Solution**: Either:
```r
# Install the package
install.packages("path/to/iita.na", repos = NULL, type = "source")
```
Or:
```r
# Load functions directly
source("R/iita.R")
source("R/data.R")
```

### Problem: "testthat not available"

**Solution**: Either install testthat:
```r
install.packages("testthat")
```
Or run tests manually without testthat (see Step 3)

### Problem: Tests take too long

**Solution**: 
- This is normal for large datasets
- Consider running smaller test cases first
- Large datasets (100x15) may take 10-30 seconds

### Problem: "Cannot open connection" or network errors

**Solution**:
- Some systems may have restricted internet access
- Run tests offline using the scripts provided
- All core functionality works without external packages

### Problem: Different results from DAKS

**Solution**:
- Verify you're using complete data (no NA values)
- Check R versions match
- Ensure you're using the same selection rule
- If results still differ, this may indicate a bug - please report it

---

## Summary of Testing Process

**Quick Test** (5 minutes):
1. Clone repository
2. Run Step 3 quick functionality test
3. Verify basic PASS results

**Comprehensive Test** (15 minutes):
1. Clone repository
2. Run Step 4 comprehensive test report
3. Review all sections pass
4. Check final summary

**Full Test with Manual Verification** (30 minutes):
1. Clone repository
2. Follow Steps 3-8 in order
3. Run each test category
4. Verify results manually
5. Compare with DAKS (optional)

---

## Next Steps

After completing these tests, you can:

1. **Review Documentation**: Read [TESTING.md](TESTING.md) for detailed test documentation
2. **Explore Examples**: Try examples in [USAGE_EXAMPLES.md](USAGE_EXAMPLES.md)
3. **Check Compatibility**: Review [DAKS_COMPATIBILITY.md](DAKS_COMPATIBILITY.md)
4. **Use the Package**: Apply iita_na to your own data
5. **Contribute**: Report issues or submit improvements

---

## Additional Resources

- **TESTING.md**: Comprehensive testing documentation
- **examples/generate_test_report.R**: Automated test report generator
- **examples/validate_daks_compatibility.R**: DAKS compatibility validator
- **tests/testthat/**: Automated test suite
- **README.md**: Package overview and quick start guide

---

## Support

If you encounter issues or have questions:

- GitHub Issues: https://github.com/Soumyadip-Dhara/iita-na/issues
- Email: soumyadip.dhara@example.com
- Check [TESTING.md](TESTING.md) for more details

---

**Last Updated**: November 2025  
**Version**: 0.1.0
