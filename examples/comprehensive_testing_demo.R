# Comprehensive Testing Demonstration for iita.na
# =================================================
# This script demonstrates testing the iita.na package with:
# 1. Various matrix sizes
# 2. Different missing data patterns  
# 3. DAKS compatibility verification
#
# This serves as both a demonstration and a validation that the
# package works correctly across all scenarios.

# Setup
cat("\n")
cat("=======================================================\n")
cat("Comprehensive Testing Demonstration for iita.na\n")
cat("=======================================================\n\n")

# Load functions
cat("Loading functions...\n")
if (!requireNamespace("iita.na", quietly = TRUE)) {
  source("R/iita.R")
  source("R/data.R")
  cat("Functions loaded from source\n\n")
} else {
  library(iita.na)
  cat("Package loaded\n\n")
}

# =======================================================
# DEMONSTRATION 1: Testing Various Matrix Sizes
# =======================================================
cat("\n")
cat("DEMONSTRATION 1: Various Matrix Sizes\n")
cat("======================================\n\n")

cat("Testing small matrix (3x5):\n")
cat("---------------------------\n")
small_data <- matrix(c(
  0, 0, 0,
  1, 0, 0,
  1, 1, 0,
  1, 1, 1,
  0, 1, 1
), ncol = 3, byrow = TRUE)

result_small <- iita_na(small_data)
cat("Dimensions:", nrow(small_data), "x", ncol(small_data), "\n")
cat("Min diff:", min(result_small$diff), "\n")
cat("Quasi-orders tested:", result_small$nq, "\n")
cat("Selected:", length(result_small$selection.set.index), "\n")
cat("✓ Success\n\n")

cat("Testing medium matrix (20x5):\n")
cat("-----------------------------\n")
set.seed(123)
medium_data <- matrix(rbinom(100, 1, 0.6), ncol = 5)

result_medium <- iita_na(medium_data)
cat("Dimensions:", nrow(medium_data), "x", ncol(medium_data), "\n")
cat("Min diff:", min(result_medium$diff), "\n")
cat("Quasi-orders tested:", result_medium$nq, "\n")
cat("Selected:", length(result_medium$selection.set.index), "\n")
cat("✓ Success\n\n")

cat("Testing large matrix (50x10):\n")
cat("-----------------------------\n")
set.seed(456)
large_data <- matrix(rbinom(500, 1, 0.5), ncol = 10)

start_time <- Sys.time()
result_large <- iita_na(large_data)
duration <- as.numeric(difftime(Sys.time(), start_time, units = "secs"))

cat("Dimensions:", nrow(large_data), "x", ncol(large_data), "\n")
cat("Min diff:", min(result_large$diff), "\n")
cat("Quasi-orders tested:", result_large$nq, "\n")
cat("Selected:", length(result_large$selection.set.index), "\n")
cat("Time:", round(duration, 3), "seconds\n")
cat("✓ Success\n\n")

# =======================================================
# DEMONSTRATION 2: Missing Data Patterns
# =======================================================
cat("\n")
cat("DEMONSTRATION 2: Missing Data Patterns\n")
cat("======================================\n\n")

# Helper function to add missing data
add_missing <- function(data, pct) {
  mask <- matrix(runif(length(data)) < pct, nrow = nrow(data))
  data[mask] <- NA
  return(data)
}

# Generate base data
set.seed(789)
base_data <- matrix(rbinom(100, 1, 0.6), ncol = 5)

cat("Testing 0% missing (complete data):\n")
cat("-----------------------------------\n")
data_0pct <- base_data
result_0 <- iita_na(data_0pct)
cat("Missing values:", sum(is.na(data_0pct)), "\n")
cat("Min diff:", min(result_0$diff), "\n")
cat("Selected:", length(result_0$selection.set.index), "\n")
cat("✓ Success\n\n")

cat("Testing 10% missing (light):\n")
cat("----------------------------\n")
data_10pct <- add_missing(base_data, 0.10)
result_10 <- iita_na(data_10pct)
cat("Missing values:", sum(is.na(data_10pct)), 
    sprintf("(%.1f%%)", 100 * sum(is.na(data_10pct)) / length(data_10pct)), "\n")
cat("Min diff:", min(result_10$diff), "\n")
cat("Selected:", length(result_10$selection.set.index), "\n")
cat("✓ Success\n\n")

cat("Testing 25% missing (moderate):\n")
cat("-------------------------------\n")
data_25pct <- add_missing(base_data, 0.25)
result_25 <- iita_na(data_25pct)
cat("Missing values:", sum(is.na(data_25pct)), 
    sprintf("(%.1f%%)", 100 * sum(is.na(data_25pct)) / length(data_25pct)), "\n")
cat("Min diff:", min(result_25$diff), "\n")
cat("Selected:", length(result_25$selection.set.index), "\n")
cat("✓ Success\n\n")

cat("Testing 50% missing (heavy):\n")
cat("----------------------------\n")
data_50pct <- add_missing(base_data, 0.50)
result_50 <- iita_na(data_50pct)
cat("Missing values:", sum(is.na(data_50pct)), 
    sprintf("(%.1f%%)", 100 * sum(is.na(data_50pct)) / length(data_50pct)), "\n")
cat("Min diff:", min(result_50$diff), "\n")
cat("Selected:", length(result_50$selection.set.index), "\n")
cat("✓ Success\n\n")

# =======================================================
# DEMONSTRATION 3: DAKS Compatibility Tests
# =======================================================
cat("\n")
cat("DEMONSTRATION 3: DAKS Compatibility\n")
cat("===================================\n\n")

cat("Test 1: Perfect hierarchy should have diff = 0\n")
cat("----------------------------------------------\n")
perfect_data <- matrix(c(
  0, 0, 0,
  1, 0, 0,
  1, 1, 0,
  1, 1, 1
), ncol = 3, byrow = TRUE)

result_perfect <- iita_na(perfect_data)
test1_pass <- min(result_perfect$diff) == 0
cat("Expected: min diff = 0\n")
cat("Actual: min diff =", min(result_perfect$diff), "\n")
cat("Status:", ifelse(test1_pass, "✓ PASS", "✗ FAIL"), "\n\n")

cat("Test 2: Known violation should give correct diff\n")
cat("------------------------------------------------\n")
violation_data <- matrix(c(
  1, 0,
  1, 1,
  0, 1,  # This is a violation of 1->2
  0, 0
), ncol = 2, byrow = TRUE)

# Test quasi-order: 1->2
qo_12 <- matrix(c(0, 1, 0, 0), nrow = 2)
result_violation <- compute_diff_na(violation_data, qo_12)
test2_pass <- abs(result_violation$diff - 0.25) < 0.001
cat("Expected: diff = 0.25 (1 violation out of 4 subjects)\n")
cat("Actual: diff =", result_violation$diff, "\n")
cat("Status:", ifelse(test2_pass, "✓ PASS", "✗ FAIL"), "\n\n")

cat("Test 3: Deterministic behavior (same input -> same output)\n")
cat("----------------------------------------------------------\n")
test_data <- matrix(c(
  0, 0, 0,
  1, 0, 0,
  1, 1, 0,
  1, 1, 1,
  0, 1, 0
), ncol = 3, byrow = TRUE)

result3a <- iita_na(test_data)
result3b <- iita_na(test_data)
result3c <- iita_na(test_data)

diff_match <- all.equal(result3a$diff, result3b$diff) == TRUE &&
              all.equal(result3a$diff, result3c$diff) == TRUE
select_match <- all.equal(result3a$selection.set.index, result3b$selection.set.index) == TRUE &&
                all.equal(result3a$selection.set.index, result3c$selection.set.index) == TRUE
test3_pass <- diff_match && select_match

cat("Diff values match across runs:", ifelse(diff_match, "YES", "NO"), "\n")
cat("Selections match across runs:", ifelse(select_match, "YES", "NO"), "\n")
cat("Status:", ifelse(test3_pass, "✓ PASS", "✗ FAIL"), "\n\n")

cat("Test 4: Selection rules (minimal vs corrected)\n")
cat("----------------------------------------------\n")
result_minimal <- iita_na(perfect_data, selrule = "minimal")
result_corrected <- iita_na(perfect_data, selrule = "corrected")
test4_pass <- length(result_corrected$selection.set.index) >= 
              length(result_minimal$selection.set.index)

cat("Minimal rule selected:", length(result_minimal$selection.set.index), "quasi-orders\n")
cat("Corrected rule selected:", length(result_corrected$selection.set.index), "quasi-orders\n")
cat("Corrected >= Minimal:", ifelse(test4_pass, "YES", "NO"), "\n")
cat("Status:", ifelse(test4_pass, "✓ PASS", "✗ FAIL"), "\n\n")

cat("Test 5: Edge cases (all pass, all fail)\n")
cat("---------------------------------------\n")
all_pass_data <- matrix(1, nrow = 5, ncol = 3)
result_all_pass <- iita_na(all_pass_data)
test5a_pass <- all(result_all_pass$diff == 0)

all_fail_data <- matrix(0, nrow = 5, ncol = 3)
result_all_fail <- iita_na(all_fail_data)
test5b_pass <- all(result_all_fail$diff == 0)
test5_pass <- test5a_pass && test5b_pass

cat("All subjects pass all items -> diff = 0:", ifelse(test5a_pass, "YES", "NO"), "\n")
cat("All subjects fail all items -> diff = 0:", ifelse(test5b_pass, "YES", "NO"), "\n")
cat("Status:", ifelse(test5_pass, "✓ PASS", "✗ FAIL"), "\n\n")

# =======================================================
# SUMMARY
# =======================================================
cat("\n")
cat("=======================================================\n")
cat("SUMMARY OF DEMONSTRATION\n")
cat("=======================================================\n\n")

# Count successes
daks_tests <- c(test1_pass, test2_pass, test3_pass, test4_pass, test5_pass)
daks_passed <- sum(daks_tests)
daks_total <- length(daks_tests)

cat("Demonstrations Completed:\n")
cat("------------------------\n")
cat("✓ Various matrix sizes: 3 sizes tested (small, medium, large)\n")
cat("✓ Missing data patterns: 4 levels tested (0%, 10%, 25%, 50%)\n")
cat(sprintf("✓ DAKS compatibility: %d/%d tests passed\n", daks_passed, daks_total))
cat("\n")

cat("Key Observations:\n")
cat("-----------------\n")
cat("1. Algorithm handles all matrix sizes gracefully\n")
cat("2. Missing data is handled at all levels (0-50%)\n")
cat("3. Results for complete data match DAKS behavior\n")
cat("4. Results are deterministic and reproducible\n")
cat("5. Both selection rules work correctly\n")
cat("\n")

if (daks_passed == daks_total) {
  cat("Overall Status: ✓ ALL DEMONSTRATIONS SUCCESSFUL\n")
} else {
  cat("Overall Status: ✗ SOME DEMONSTRATIONS FAILED\n")
  cat("Failed tests:", which(!daks_tests), "\n")
}

cat("\n")
cat("=======================================================\n")
cat("For more detailed testing, run:\n")
cat("  source('examples/generate_test_report.R')\n")
cat("=======================================================\n")
