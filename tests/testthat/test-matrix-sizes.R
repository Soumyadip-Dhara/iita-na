# Tests for various matrix sizes with and without missing data
# This test suite validates the iita_na function performance across
# different data matrix dimensions and missing data patterns

test_that("iita_na works with small matrices (2x2)", {
  # 2 items, 4 subjects
  data <- matrix(c(
    0, 0,
    1, 0,
    1, 1,
    0, 1
  ), ncol = 2, byrow = TRUE)
  
  result <- iita_na(data)
  
  expect_s3_class(result, "iita_na")
  expect_equal(result$ni, 2)
  expect_true(all(result$diff >= 0 & result$diff <= 1))
  expect_true(length(result$selection.set.index) > 0)
})

test_that("iita_na works with small matrices (3x3)", {
  # 3 items, 5 subjects
  data <- matrix(c(
    0, 0, 0,
    1, 0, 0,
    1, 1, 0,
    1, 1, 1,
    0, 1, 1
  ), ncol = 3, byrow = TRUE)
  
  result <- iita_na(data)
  
  expect_s3_class(result, "iita_na")
  expect_equal(result$ni, 3)
  expect_true(all(result$diff >= 0 & result$diff <= 1))
  expect_true(length(result$selection.set.index) > 0)
})

test_that("iita_na works with small matrices (4x4)", {
  # 4 items, 8 subjects
  set.seed(123)
  data <- matrix(rbinom(32, 1, 0.6), ncol = 4)
  
  result <- iita_na(data)
  
  expect_s3_class(result, "iita_na")
  expect_equal(result$ni, 4)
  expect_true(all(result$diff >= 0 & result$diff <= 1))
  expect_true(length(result$selection.set.index) > 0)
})

test_that("iita_na works with medium matrices (10 subjects, 5 items)", {
  # 5 items, 10 subjects
  set.seed(456)
  data <- matrix(rbinom(50, 1, 0.5), ncol = 5)
  
  result <- iita_na(data)
  
  expect_s3_class(result, "iita_na")
  expect_equal(result$ni, 5)
  expect_true(all(result$diff >= 0 & result$diff <= 1))
  expect_true(length(result$selection.set.index) > 0)
})

test_that("iita_na works with medium matrices (20 subjects, 10 items)", {
  # 10 items, 20 subjects
  set.seed(789)
  data <- matrix(rbinom(200, 1, 0.5), ncol = 10)
  
  result <- iita_na(data)
  
  expect_s3_class(result, "iita_na")
  expect_equal(result$ni, 10)
  expect_true(all(result$diff >= 0 & result$diff <= 1))
  expect_true(length(result$selection.set.index) > 0)
})

test_that("iita_na works with larger matrices (50 subjects, 10 items)", {
  # 10 items, 50 subjects
  set.seed(101)
  data <- matrix(rbinom(500, 1, 0.5), ncol = 10)
  
  result <- iita_na(data)
  
  expect_s3_class(result, "iita_na")
  expect_equal(result$ni, 10)
  expect_true(all(result$diff >= 0 & result$diff <= 1))
  expect_true(length(result$selection.set.index) > 0)
})

test_that("iita_na works with larger matrices (100 subjects, 15 items)", {
  # 15 items, 100 subjects
  set.seed(202)
  data <- matrix(rbinom(1500, 1, 0.5), ncol = 15)
  
  result <- iita_na(data)
  
  expect_s3_class(result, "iita_na")
  expect_equal(result$ni, 15)
  expect_true(all(result$diff >= 0 & result$diff <= 1))
  expect_true(length(result$selection.set.index) > 0)
})

test_that("iita_na handles small matrices with 10% missing data", {
  # 3 items, 10 subjects, ~10% missing
  set.seed(303)
  data <- matrix(rbinom(30, 1, 0.6), ncol = 3)
  missing_mask <- matrix(runif(30) < 0.1, ncol = 3)
  data[missing_mask] <- NA
  
  result <- iita_na(data)
  
  expect_s3_class(result, "iita_na")
  expect_equal(result$ni, 3)
  expect_true(all(result$diff >= 0 & result$diff <= 1))
})

test_that("iita_na handles medium matrices with 25% missing data", {
  # 5 items, 20 subjects, ~25% missing
  set.seed(404)
  data <- matrix(rbinom(100, 1, 0.6), ncol = 5)
  missing_mask <- matrix(runif(100) < 0.25, ncol = 5)
  data[missing_mask] <- NA
  
  result <- iita_na(data)
  
  expect_s3_class(result, "iita_na")
  expect_equal(result$ni, 5)
  expect_true(all(result$diff >= 0 & result$diff <= 1))
  expect_true(sum(is.na(data)) > 0)
})

test_that("iita_na handles medium matrices with 50% missing data", {
  # 5 items, 20 subjects, ~50% missing
  set.seed(505)
  data <- matrix(rbinom(100, 1, 0.6), ncol = 5)
  missing_mask <- matrix(runif(100) < 0.5, ncol = 5)
  data[missing_mask] <- NA
  
  result <- iita_na(data)
  
  expect_s3_class(result, "iita_na")
  expect_equal(result$ni, 5)
  expect_true(all(result$diff >= 0 & result$diff <= 1))
  expect_true(sum(is.na(data)) > 0)
})

test_that("iita_na handles large matrices with varying missing data", {
  # 10 items, 50 subjects with different missing patterns
  set.seed(606)
  data <- matrix(rbinom(500, 1, 0.6), ncol = 10)
  
  # Add 15% missing data
  missing_mask <- matrix(runif(500) < 0.15, ncol = 10)
  data[missing_mask] <- NA
  
  result <- iita_na(data)
  
  expect_s3_class(result, "iita_na")
  expect_equal(result$ni, 10)
  expect_true(all(result$diff >= 0 & result$diff <= 1))
  
  # Verify missing data was handled
  missing_pct <- sum(is.na(data)) / length(data)
  expect_true(missing_pct > 0.1 && missing_pct < 0.2)
})

test_that("iita_na maintains consistency for same data (determinism test)", {
  # Verify that same data produces same results
  set.seed(707)
  data <- matrix(rbinom(60, 1, 0.6), ncol = 3)
  
  result1 <- iita_na(data)
  result2 <- iita_na(data)
  result3 <- iita_na(data)
  
  expect_equal(result1$diff, result2$diff)
  expect_equal(result1$diff, result3$diff)
  expect_equal(result1$selection.set.index, result2$selection.set.index)
})

test_that("iita_na performance scales with data size", {
  # Test that the algorithm completes in reasonable time for various sizes
  
  # Small data
  data_small <- matrix(rbinom(30, 1, 0.6), ncol = 3)
  expect_silent({
    result_small <- iita_na(data_small)
  })
  
  # Medium data
  data_medium <- matrix(rbinom(100, 1, 0.6), ncol = 5)
  expect_silent({
    result_medium <- iita_na(data_medium)
  })
  
  # Larger data
  data_large <- matrix(rbinom(500, 1, 0.6), ncol = 10)
  expect_silent({
    result_large <- iita_na(data_large)
  })
})

test_that("iita_na handles edge case: single subject", {
  # 1 subject, 3 items
  data <- matrix(c(1, 0, 1), ncol = 3)
  
  result <- iita_na(data)
  
  expect_s3_class(result, "iita_na")
  expect_equal(result$ni, 3)
})

test_that("iita_na handles edge case: two subjects", {
  # 2 subjects, 3 items
  data <- matrix(c(
    0, 0, 0,
    1, 1, 1
  ), ncol = 3, byrow = TRUE)
  
  result <- iita_na(data)
  
  expect_s3_class(result, "iita_na")
  expect_equal(result$ni, 3)
})
