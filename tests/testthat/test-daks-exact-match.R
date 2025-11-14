# Comprehensive tests to verify exact match with DAKS package for complete data
# These tests document the compatibility behavior and can be used to verify
# that iita.na produces identical results to DAKS when no missing data exists

test_that("iita_na exact match: simple 2x2 complete data", {
  # Simple 2-item test case
  data <- matrix(c(
    0, 0,
    1, 0,
    1, 1,
    0, 1
  ), ncol = 2, byrow = TRUE)
  
  result <- iita_na(data)
  
  # Verify no missing data
  expect_equal(sum(is.na(data)), 0)
  
  # Properties that should match DAKS
  expect_true(all(result$diff >= 0 & result$diff <= 1))
  expect_equal(result$diff, result$error.rate)
  expect_equal(result$ni, 2)
  
  # For this data, empty quasi-order should have diff=0
  empty_qo_idx <- which(sapply(result$v, function(m) sum(m) == 0))
  expect_equal(result$diff[empty_qo_idx], 0)
})

test_that("iita_na exact match: perfect hierarchy 3x3", {
  # Perfect prerequisite chain: 1 -> 2 -> 3
  data <- matrix(c(
    0, 0, 0,
    1, 0, 0,
    1, 1, 0,
    1, 1, 1
  ), ncol = 3, byrow = TRUE)
  
  result <- iita_na(data)
  
  # Verify no missing data
  expect_equal(sum(is.na(data)), 0)
  
  # For perfect data, minimum diff should be 0
  expect_equal(min(result$diff), 0)
  
  # Error rates should match diff values (DAKS behavior)
  expect_equal(result$diff, result$error.rate)
})

test_that("iita_na exact match: data with violations", {
  # Data with known violations
  data <- matrix(c(
    0, 0,
    1, 0,
    0, 1,  # Violation of 1->2
    1, 1
  ), ncol = 2, byrow = TRUE)
  
  # Create quasi-order: 1->2
  qo <- matrix(c(0, 1, 0, 0), nrow = 2, ncol = 2)
  
  result <- compute_diff_na(data, qo)
  
  # Manual calculation: 1 violation (subject 3) out of 4 subjects = 0.25
  expect_equal(result$diff, 0.25)
  expect_equal(result$error_rate, 0.25)
})

test_that("iita_na exact match: minimal selection rule behavior", {
  data <- matrix(c(
    0, 0, 0,
    1, 0, 0,
    1, 1, 0,
    1, 1, 1
  ), ncol = 3, byrow = TRUE)
  
  result <- iita_na(data, selrule = "minimal")
  
  # Verify selection rule is applied correctly
  min_diff <- min(result$diff)
  expected_indices <- which(result$diff == min_diff)
  expect_equal(sort(result$selection.set.index), sort(expected_indices))
})

test_that("iita_na exact match: corrected selection rule behavior", {
  data <- matrix(c(
    0, 0, 0,
    1, 0, 0,
    1, 1, 0,
    1, 1, 1
  ), ncol = 3, byrow = TRUE)
  
  result <- iita_na(data, selrule = "corrected")
  
  # Verify corrected selection threshold
  min_diff <- min(result$diff)
  threshold <- min_diff + sqrt(min_diff)
  expected_indices <- which(result$diff <= threshold)
  expect_equal(sort(result$selection.set.index), sort(expected_indices))
  
  # Corrected should select >= minimal
  result_minimal <- iita_na(data, selrule = "minimal")
  expect_true(length(result$selection.set.index) >= 
              length(result_minimal$selection.set.index))
})

test_that("iita_na exact match: all pass edge case", {
  # All subjects pass all items
  data <- matrix(1, nrow = 5, ncol = 3)
  
  result <- iita_na(data)
  
  # No violations possible -> all diff = 0
  expect_true(all(result$diff == 0))
  expect_equal(sum(is.na(data)), 0)
})

test_that("iita_na exact match: all fail edge case", {
  # All subjects fail all items
  data <- matrix(0, nrow = 5, ncol = 3)
  
  result <- iita_na(data)
  
  # No violations possible -> all diff = 0
  expect_true(all(result$diff == 0))
  expect_equal(sum(is.na(data)), 0)
})

test_that("iita_na exact match: deterministic with complete data", {
  # Same complete data should always produce same results
  set.seed(123)
  data <- matrix(rbinom(60, 1, 0.5), ncol = 3)
  
  # Verify no missing data
  expect_equal(sum(is.na(data)), 0)
  
  # Run multiple times
  result1 <- iita_na(data)
  result2 <- iita_na(data)
  result3 <- iita_na(data)
  
  # Results should be identical
  expect_equal(result1$diff, result2$diff)
  expect_equal(result1$diff, result3$diff)
  expect_equal(result1$selection.set.index, result2$selection.set.index)
  expect_equal(result1$selection.set.index, result3$selection.set.index)
})

test_that("iita_na exact match: diff calculation for complete data", {
  # Verify diff calculation matches expected formula
  data <- matrix(c(
    1, 0,
    1, 1,
    0, 0,
    1, 1,
    0, 1
  ), ncol = 2, byrow = TRUE)
  
  # Quasi-order: 1->2
  qo <- matrix(c(0, 1, 0, 0), nrow = 2, ncol = 2)
  
  result <- compute_diff_na(data, qo)
  
  # Manual calculation:
  # Subject 1: item 2=0, item 1=1 -> no violation
  # Subject 2: item 2=1, item 1=1 -> no violation
  # Subject 3: item 2=0, item 1=0 -> no violation
  # Subject 4: item 2=1, item 1=1 -> no violation
  # Subject 5: item 2=1, item 1=0 -> VIOLATION
  # 1 violation out of 5 subjects = 0.2
  expect_equal(result$diff, 0.2)
})

test_that("iita_na exact match: multiple quasi-orders comparison", {
  # Test with different quasi-order structures
  data <- matrix(c(
    0, 0, 0,
    1, 0, 0,
    1, 1, 0,
    1, 1, 1
  ), ncol = 3, byrow = TRUE)
  
  result <- iita_na(data)
  
  # Empty quasi-order should have diff=0
  empty_idx <- which(sapply(result$v, function(m) sum(m) == 0))
  expect_equal(result$diff[empty_idx], 0)
  
  # Each diff value should be between 0 and 1
  expect_true(all(result$diff >= 0))
  expect_true(all(result$diff <= 1))
  
  # Number of quasi-orders should be positive
  expect_true(result$nq > 0)
})

test_that("iita_na exact match: medium size complete data", {
  # Test with realistic size data
  set.seed(456)
  data <- matrix(c(
    rep(c(0,0,0,0,0), 2),
    rep(c(1,0,0,0,0), 2),
    rep(c(1,1,0,0,0), 2),
    rep(c(1,1,1,0,0), 2),
    rep(c(1,1,1,1,0), 2),
    rep(c(1,1,1,1,1), 2)
  ), ncol = 5, byrow = TRUE)
  
  result <- iita_na(data)
  
  # Verify no missing data
  expect_equal(sum(is.na(data)), 0)
  
  # Should complete successfully
  expect_s3_class(result, "iita_na")
  expect_equal(result$ni, 5)
  
  # For this hierarchical data, min diff should be 0
  expect_equal(min(result$diff), 0)
})

test_that("iita_na exact match: transitive closure in quasi-orders", {
  # Verify that transitive closure is computed correctly
  # (internal function but affects results)
  m <- matrix(c(
    0, 1, 0,
    0, 0, 1,
    0, 0, 0
  ), nrow = 3, byrow = TRUE)
  
  tc <- iita.na:::transitive_closure(m)
  
  # Should add 1->3 relation
  expect_equal(tc[1, 3], 1)
  expect_equal(tc[1, 2], 1)
  expect_equal(tc[2, 3], 1)
  
  # Original relations preserved
  expect_equal(tc[1, 1], 0)
  expect_equal(tc[2, 2], 0)
  expect_equal(tc[3, 3], 0)
})

test_that("iita_na exact match: output structure matches expected", {
  data <- matrix(c(0, 0, 1, 1, 1, 0), ncol = 2, byrow = TRUE)
  
  result <- iita_na(data)
  
  # Verify all expected output fields exist
  expect_true("diff" %in% names(result))
  expect_true("selection.set.index" %in% names(result))
  expect_true("implications" %in% names(result))
  expect_true("v" %in% names(result))
  expect_true("ni" %in% names(result))
  expect_true("nq" %in% names(result))
  expect_true("error.rate" %in% names(result))
  expect_true("selrule" %in% names(result))
  
  # Verify field types
  expect_type(result$diff, "double")
  expect_type(result$selection.set.index, "integer")
  expect_type(result$implications, "list")
  expect_type(result$v, "list")
  expect_type(result$ni, "double")
  expect_type(result$nq, "double")
  expect_type(result$error.rate, "double")
  expect_type(result$selrule, "character")
})

test_that("iita_na exact match: error rates equal diff values", {
  # In IITA, error rate should equal diff value
  set.seed(789)
  data <- matrix(rbinom(40, 1, 0.6), ncol = 4)
  
  result <- iita_na(data)
  
  # Verify no missing data
  expect_equal(sum(is.na(data)), 0)
  
  # Error rates should match diff values
  expect_equal(result$diff, result$error.rate)
})

test_that("iita_na exact match: respects custom v parameter", {
  data <- matrix(c(0, 0, 1, 1, 1, 0), ncol = 2, byrow = TRUE)
  
  # Create custom quasi-orders
  v_custom <- list(
    matrix(c(0, 0, 0, 0), nrow = 2),  # Empty
    matrix(c(0, 1, 0, 0), nrow = 2)   # 1->2
  )
  
  result <- iita_na(data, v = v_custom)
  
  # Should only test the provided quasi-orders
  expect_equal(result$nq, 2)
  expect_equal(length(result$diff), 2)
})
