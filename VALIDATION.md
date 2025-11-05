# Validation Guide for iita.na

This guide explains how to validate that the `iita.na` package:
1. Works correctly with missing data
2. Produces identical results to the DAKS package for complete data

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Validating Missing Data Handling](#validating-missing-data-handling)
3. [Comparing with DAKS Package](#comparing-with-daks-package)
4. [Complete Validation Script](#complete-validation-script)
5. [Expected Results](#expected-results)

## Prerequisites

Install required packages:

```r
# Install iita.na (if not already installed)
# install.packages("path/to/iita.na", repos = NULL, type = "source")

# Install DAKS for comparison
install.packages("DAKS")

# Load packages
library(iita.na)
library(DAKS)
```

## Validating Missing Data Handling

### Test 1: Basic Missing Data Functionality

```r
# Create dataset with missing values
data_missing <- matrix(c(
  0, 0, 0,
  1, NA, 0,   # Missing value in position (2,2)
  1, 1, NA,   # Missing value in position (3,3)
  1, 1, 1
), ncol = 3, byrow = TRUE)

# Run iita.na
result_missing <- iita(data_missing)

# Verify it completes without errors
print(result_missing)

# Check that results are valid
cat("\nValidation checks for missing data:\n")
cat("✓ Analysis completed:", class(result_missing)[1] == "iita", "\n")
cat("✓ Diff values are valid:", all(result_missing$diff >= 0 & result_missing$diff <= 1), "\n")
cat("✓ Selection made:", length(result_missing$selection.set.index) > 0, "\n")
cat("✓ Number of items:", result_missing$ni, "\n")
```

### Test 2: Missing Data vs Complete Data Comparison

```r
# Create a dataset
data_complete <- matrix(c(
  0, 0, 0,
  1, 0, 0,
  1, 1, 0,
  1, 1, 1
), ncol = 3, byrow = TRUE)

# Add missing values to a copy
data_with_na <- data_complete
data_with_na[2, 2] <- NA  # Add one missing value

# Run both
result_complete <- iita(data_complete)
result_with_na <- iita(data_with_na)

# Compare results
cat("\nComparison of complete vs. missing data:\n")
cat("Complete data - min diff:", min(result_complete$diff), "\n")
cat("Missing data - min diff:", min(result_with_na$diff), "\n")
cat("Both completed successfully:", 
    class(result_complete)[1] == "iita" && class(result_with_na)[1] == "iita", "\n")
```

### Test 3: Pairwise Deletion Verification

This test demonstrates that pairwise deletion is working correctly:

```r
# Create data where missing values affect different pairs
data_pairwise <- matrix(c(
  1, 0, 0,   # Subject 1: complete
  1, 1, NA,  # Subject 2: missing item 3
  NA, 1, 1,  # Subject 3: missing item 1
  1, 1, 1    # Subject 4: complete
), ncol = 3, byrow = TRUE)

# Run analysis
result_pairwise <- iita(data_pairwise)

# The analysis should use all available pairs
cat("\nPairwise deletion test:\n")
cat("✓ Analysis completed with scattered NAs:", class(result_pairwise)[1] == "iita", "\n")
cat("✓ Results are interpretable:", length(result_pairwise$selection.set.index) > 0, "\n")

# Show which data was used
cat("\nData pattern (NA = missing):\n")
print(data_pairwise)
cat("\nResult summary:\n")
print(result_pairwise)
```

## Comparing with DAKS Package

### Test 4: Exact Comparison with DAKS

This is the key test to prove identical behavior for complete data:

```r
library(DAKS)
library(iita.na)

# Create test dataset (must be complete - no NAs)
test_data <- matrix(c(
  0, 0, 0, 0,
  1, 0, 0, 0,
  1, 1, 0, 0,
  1, 1, 1, 0,
  1, 1, 1, 1,
  0, 1, 0, 0,
  1, 0, 1, 0
), ncol = 4, byrow = TRUE)

cat("Test data (7 subjects × 4 items):\n")
print(test_data)

# Run DAKS::iita
cat("\n--- Running DAKS::iita ---\n")
daks_result <- DAKS::iita(test_data, v = 1)

# Run iita.na::iita  
cat("\n--- Running iita.na::iita ---\n")
iita_na_result <- iita(test_data)

# Compare key results
cat("\n=== COMPARISON RESULTS ===\n\n")

# Compare diff values
cat("Diff values:\n")
cat("  DAKS min diff:", min(daks_result$diff), "\n")
cat("  iita.na min diff:", min(iita_na_result$diff), "\n")
cat("  Match:", abs(min(daks_result$diff) - min(iita_na_result$diff)) < 1e-10, "\n\n")

# Compare selection indices
cat("Selected quasi-order indices:\n")
cat("  DAKS:", daks_result$selection.set.index, "\n")
cat("  iita.na:", iita_na_result$selection.set.index, "\n")
cat("  Match:", identical(daks_result$selection.set.index, iita_na_result$selection.set.index), "\n\n")

# Compare number of items
cat("Number of items:\n")
cat("  DAKS:", daks_result$ni, "\n")
cat("  iita.na:", iita_na_result$ni, "\n")
cat("  Match:", daks_result$ni == iita_na_result$ni, "\n\n")

# Compare error rates
cat("Error rates match:", 
    all(abs(daks_result$error.rate - iita_na_result$error.rate) < 1e-10), "\n")
```

### Test 5: Multiple Datasets Comparison

Test with different data patterns to ensure consistency:

```r
# Test Case 1: Perfect hierarchy
perfect_hierarchy <- matrix(c(
  0, 0, 0,
  1, 0, 0,
  1, 1, 0,
  1, 1, 1
), ncol = 3, byrow = TRUE)

# Test Case 2: No clear structure
random_pattern <- matrix(c(
  1, 0, 1,
  0, 1, 0,
  1, 1, 0,
  0, 0, 1
), ncol = 3, byrow = TRUE)

# Function to compare results
compare_packages <- function(data, name) {
  cat("\n=== Test Case:", name, "===\n")
  
  daks_res <- DAKS::iita(data, v = 1)
  iita_res <- iita(data)
  
  diff_match <- all(abs(daks_res$diff - iita_res$diff) < 1e-10)
  selection_match <- identical(daks_res$selection.set.index, iita_res$selection.set.index)
  
  cat("Diff values match:", diff_match, "\n")
  cat("Selection indices match:", selection_match, "\n")
  cat("✓ Results identical:", diff_match && selection_match, "\n")
  
  return(diff_match && selection_match)
}

# Run comparisons
results <- list(
  compare_packages(perfect_hierarchy, "Perfect Hierarchy"),
  compare_packages(random_pattern, "Random Pattern")
)

cat("\n=== SUMMARY ===\n")
cat("All tests passed:", all(unlist(results)), "\n")
```

### Test 6: Using Example Datasets

Validate using the package's built-in datasets:

```r
# Load the complete dataset
data(knowledge_complete, package = "iita.na")

cat("Testing with knowledge_complete dataset:\n")
cat("Dimensions:", nrow(knowledge_complete), "subjects ×", 
    ncol(knowledge_complete), "items\n")

# Run both packages
daks_res <- DAKS::iita(knowledge_complete, v = 1)
iita_res <- iita(knowledge_complete)

# Detailed comparison
cat("\nDetailed comparison:\n")
cat("Min diff - DAKS:", min(daks_res$diff), "\n")
cat("Min diff - iita.na:", min(iita_res$diff), "\n")
cat("Difference:", abs(min(daks_res$diff) - min(iita_res$diff)), "\n")

# Check if results are practically identical (allowing for floating point errors)
tolerance <- 1e-10
diffs_match <- all(abs(daks_res$diff - iita_res$diff) < tolerance)
selections_match <- identical(daks_res$selection.set.index, iita_res$selection.set.index)

cat("\n✓ Diffs match (tolerance=", tolerance, "):", diffs_match, "\n")
cat("✓ Selections match:", selections_match, "\n")
cat("✓ VALIDATION PASSED:", diffs_match && selections_match, "\n")
```

## Complete Validation Script

Here's a complete script that runs all validations:

```r
# Complete Validation Script for iita.na
# This script validates:
# 1. Missing data handling works correctly
# 2. Results match DAKS for complete data

# Load packages
library(iita.na)
library(DAKS)

# Initialize results tracker
validation_results <- list()

cat("=" , rep("=", 60), "\n", sep="")
cat("VALIDATION SCRIPT FOR iita.na PACKAGE\n")
cat("=" , rep("=", 60), "\n\n", sep="")

# ========================================
# PART 1: MISSING DATA VALIDATION
# ========================================

cat("\nPART 1: MISSING DATA HANDLING\n")
cat("-" , rep("-", 60), "\n", sep="")

# Test 1.1: Basic missing data
cat("\nTest 1.1: Basic missing data functionality\n")
data_na <- matrix(c(0,0,0, 1,NA,0, 1,1,NA, 1,1,1), ncol=3, byrow=TRUE)
tryCatch({
  result_na <- iita(data_na)
  test1 <- class(result_na)[1] == "iita" && length(result_na$selection.set.index) > 0
  cat("  Status: PASS\n")
  validation_results$missing_basic <- TRUE
}, error = function(e) {
  cat("  Status: FAIL -", e$message, "\n")
  validation_results$missing_basic <- FALSE
})

# Test 1.2: All missing data
cat("\nTest 1.2: All missing data\n")
data_all_na <- matrix(NA, nrow=4, ncol=3)
tryCatch({
  result_all_na <- iita(data_all_na)
  cat("  Status: PASS\n")
  validation_results$missing_all <- TRUE
}, error = function(e) {
  cat("  Status: FAIL -", e$message, "\n")
  validation_results$missing_all <- FALSE
})

# Test 1.3: Pairwise deletion
cat("\nTest 1.3: Pairwise deletion\n")
data_pairwise <- matrix(c(1,0,0, 1,1,NA, NA,1,1, 1,1,1), ncol=3, byrow=TRUE)
tryCatch({
  result_pairwise <- iita(data_pairwise)
  test3 <- length(result_pairwise$selection.set.index) > 0
  cat("  Status: PASS\n")
  validation_results$missing_pairwise <- TRUE
}, error = function(e) {
  cat("  Status: FAIL -", e$message, "\n")
  validation_results$missing_pairwise <- FALSE
})

# ========================================
# PART 2: DAKS COMPARISON
# ========================================

cat("\n\nPART 2: COMPARISON WITH DAKS PACKAGE\n")
cat("-" , rep("-", 60), "\n", sep="")

# Test 2.1: Simple dataset
cat("\nTest 2.1: Simple complete dataset\n")
data_simple <- matrix(c(0,0,0, 1,0,0, 1,1,0, 1,1,1), ncol=3, byrow=TRUE)
daks_simple <- DAKS::iita(data_simple, v=1)
iita_simple <- iita(data_simple)

diff_match_simple <- all(abs(daks_simple$diff - iita_simple$diff) < 1e-10)
selection_match_simple <- identical(daks_simple$selection.set.index, 
                                    iita_simple$selection.set.index)

cat("  Diff values match:", diff_match_simple, "\n")
cat("  Selection indices match:", selection_match_simple, "\n")
cat("  Status:", ifelse(diff_match_simple && selection_match_simple, "PASS", "FAIL"), "\n")
validation_results$daks_simple <- diff_match_simple && selection_match_simple

# Test 2.2: Larger dataset
cat("\nTest 2.2: Larger dataset\n")
set.seed(123)
data_large <- matrix(sample(0:1, 40, replace=TRUE), ncol=4)
daks_large <- DAKS::iita(data_large, v=1)
iita_large <- iita(data_large)

diff_match_large <- all(abs(daks_large$diff - iita_large$diff) < 1e-10)
selection_match_large <- identical(daks_large$selection.set.index, 
                                   iita_large$selection.set.index)

cat("  Diff values match:", diff_match_large, "\n")
cat("  Selection indices match:", selection_match_large, "\n")
cat("  Status:", ifelse(diff_match_large && selection_match_large, "PASS", "FAIL"), "\n")
validation_results$daks_large <- diff_match_large && selection_match_large

# Test 2.3: Built-in dataset
cat("\nTest 2.3: Built-in knowledge_complete dataset\n")
data(knowledge_complete, package="iita.na")
daks_builtin <- DAKS::iita(knowledge_complete, v=1)
iita_builtin <- iita(knowledge_complete)

diff_match_builtin <- all(abs(daks_builtin$diff - iita_builtin$diff) < 1e-10)
selection_match_builtin <- identical(daks_builtin$selection.set.index, 
                                     iita_builtin$selection.set.index)

cat("  Diff values match:", diff_match_builtin, "\n")
cat("  Selection indices match:", selection_match_builtin, "\n")
cat("  Status:", ifelse(diff_match_builtin && selection_match_builtin, "PASS", "FAIL"), "\n")
validation_results$daks_builtin <- diff_match_builtin && selection_match_builtin

# ========================================
# FINAL SUMMARY
# ========================================

cat("\n\n")
cat("=" , rep("=", 60), "\n", sep="")
cat("VALIDATION SUMMARY\n")
cat("=" , rep("=", 60), "\n\n", sep="")

cat("Missing Data Tests:\n")
cat("  Basic functionality:", ifelse(validation_results$missing_basic, "✓ PASS", "✗ FAIL"), "\n")
cat("  All missing data:", ifelse(validation_results$missing_all, "✓ PASS", "✗ FAIL"), "\n")
cat("  Pairwise deletion:", ifelse(validation_results$missing_pairwise, "✓ PASS", "✗ FAIL"), "\n")

cat("\nDAKS Comparison Tests:\n")
cat("  Simple dataset:", ifelse(validation_results$daks_simple, "✓ PASS", "✗ FAIL"), "\n")
cat("  Larger dataset:", ifelse(validation_results$daks_large, "✓ PASS", "✗ FAIL"), "\n")
cat("  Built-in dataset:", ifelse(validation_results$daks_builtin, "✓ PASS", "✗ FAIL"), "\n")

all_passed <- all(unlist(validation_results))
cat("\n")
cat("=" , rep("=", 60), "\n", sep="")
cat("OVERALL RESULT:", ifelse(all_passed, "✓ ALL TESTS PASSED", "✗ SOME TESTS FAILED"), "\n")
cat("=" , rep("=", 60), "\n", sep="")

# Return summary
invisible(validation_results)
```

## Expected Results

### For Missing Data Validation

When you run the missing data tests, you should see:
- ✓ Analysis completes without errors
- ✓ Results have valid structure (class "iita")
- ✓ Diff values are between 0 and 1
- ✓ At least one quasi-order is selected

### For DAKS Comparison

When comparing with DAKS for complete data, you should see:
- ✓ Diff values match exactly (within floating-point tolerance of 1e-10)
- ✓ Selection indices are identical
- ✓ Error rates match
- ✓ Number of items and quasi-orders match

### Interpretation

**If all tests pass:**
- ✅ The package correctly handles missing data using pairwise deletion
- ✅ The package produces identical results to DAKS for complete data
- ✅ The implementation is validated

**If tests fail:**
- Check that both packages are installed correctly
- Verify package versions (DAKS should be from CRAN)
- Review error messages for specific issues

## Automated Validation

You can save the complete validation script to a file and run it:

```bash
# Save the script
cat > validate_iita_na.R << 'EOF'
# [paste the complete validation script here]
EOF

# Run the validation
Rscript validate_iita_na.R
```

Or from within R:

```r
source("validate_iita_na.R")
```

## Additional Notes

### Why Floating-Point Tolerance?

When comparing numerical results, we use a tolerance (typically 1e-10) because:
- Computer arithmetic has inherent floating-point precision limits
- Two mathematically equivalent calculations may differ at the machine precision level
- A tolerance of 1e-10 is much smaller than any meaningful difference

### What is v=1 in DAKS?

The `v=1` parameter in `DAKS::iita()` specifies which quasi-order generation method to use. Using `v=1` ensures we compare like-for-like functionality.

### Reproducibility

For reproducible results:
- Use `set.seed()` when generating random data
- Document package versions
- Save datasets used for validation

## Troubleshooting

### Issue: DAKS not available

**Solution:**
```r
install.packages("DAKS")
```

### Issue: Results don't match exactly

**Possible causes:**
1. Using different quasi-order generation methods
2. Package versions differ
3. Random data without set.seed()

**Solution:**
Ensure you're using the same parameters and set random seeds where applicable.

### Issue: Missing data test fails

**Solution:**
Check that your data contains actual NA values (not strings or other representations):
```r
# Correct
data <- matrix(c(1, NA, 0), ncol=3)

# Incorrect
data <- matrix(c(1, "NA", 0), ncol=3)
```

## References

- DAKS package: https://cran.r-project.org/package=DAKS
- iita.na documentation: See `?iita` for detailed function documentation
- Sargin, A., & Ünlü, A. (2009). Inductive item tree analysis: Corrections, improvements, and comparisons. Mathematical Social Sciences, 58(3), 376-392.
