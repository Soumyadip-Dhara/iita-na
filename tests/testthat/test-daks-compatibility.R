# Tests to validate DAKS compatibility for complete data
# These tests verify that the implementation produces expected results
# that would match DAKS output for data without missing values

test_that("iita produces consistent results for complete data - simple case", {
  # Create a dataset with perfect prerequisite structure
  # Item 1 -> Item 2 -> Item 3 (linear chain)
  data <- matrix(c(
    0, 0, 0,  # Failed all
    1, 0, 0,  # Passed only item 1
    1, 1, 0,  # Passed items 1 and 2
    1, 1, 1   # Passed all
  ), ncol = 3, byrow = TRUE)
  
  result <- iita(data)
  
  # For this perfect data, the best quasi-order should have diff = 0
  expect_equal(min(result$diff), 0)
  
  # Should select at least one quasi-order
  expect_true(length(result$selection.set.index) > 0)
  
  # All diff values should be >= 0 and <= 1
  expect_true(all(result$diff >= 0 & result$diff <= 1))
  
  # Error rates should match diff values for IITA
  expect_equal(result$diff, result$error.rate)
})

test_that("iita handles violations correctly in complete data", {
  # Create data with one violation of the prerequisite 1->2
  data <- matrix(c(
    0, 0,  # Both failed
    1, 0,  # Passed 1, failed 2 (consistent)
    0, 1,  # Failed 1, passed 2 (VIOLATION)
    1, 1   # Both passed
  ), ncol = 2, byrow = TRUE)
  
  result <- iita(data)
  
  # The empty quasi-order (no prerequisites) should have diff = 0
  # because there are no prerequisites to violate
  empty_qo_index <- which(sapply(result$v, function(m) sum(m) == 0))
  expect_equal(result$diff[empty_qo_index], 0)
  
  # A quasi-order with 1->2 should have diff > 0 due to the violation
  # (one violation out of 4 subjects = 0.25 for that relation)
  qo_with_12 <- which(sapply(result$v, function(m) m[1,2] == 1 && sum(m) == 1))
  if (length(qo_with_12) > 0) {
    expect_true(result$diff[qo_with_12[1]] > 0)
  }
})

test_that("iita minimal selection rule works correctly", {
  # Simple dataset
  data <- matrix(c(
    0, 0, 0,
    1, 0, 0,
    1, 1, 0,
    1, 1, 1
  ), ncol = 3, byrow = TRUE)
  
  result <- iita(data, selrule = "minimal")
  
  # Should select only quasi-orders with minimum diff
  min_diff <- min(result$diff)
  expected_indices <- which(result$diff == min_diff)
  expect_equal(sort(result$selection.set.index), sort(expected_indices))
})

test_that("iita corrected selection rule works correctly", {
  # Simple dataset
  data <- matrix(c(
    0, 0, 0,
    1, 0, 0,
    1, 1, 0,
    1, 1, 1
  ), ncol = 3, byrow = TRUE)
  
  result <- iita(data, selrule = "corrected")
  
  # Should select quasi-orders within threshold
  min_diff <- min(result$diff)
  threshold <- min_diff + sqrt(min_diff)
  expected_indices <- which(result$diff <= threshold)
  expect_equal(sort(result$selection.set.index), sort(expected_indices))
  
  # Corrected should select at least as many as minimal
  result_minimal <- iita(data, selrule = "minimal")
  expect_true(length(result$selection.set.index) >= length(result_minimal$selection.set.index))
})

test_that("compute_diff_na behaves correctly with complete data", {
  # Complete data with no missing values
  data <- matrix(c(
    1, 0,
    1, 1,
    0, 0,
    1, 1
  ), ncol = 2, byrow = TRUE)
  
  # Quasi-order: item 1 is prerequisite for item 2
  qo <- matrix(c(0, 1, 0, 0), nrow = 2, ncol = 2)
  
  result <- compute_diff_na(data, qo)
  
  # No violations in this data (when 2=1, then 1=1)
  expect_equal(result$diff, 0)
  expect_equal(result$error_rate, 0)
})

test_that("compute_diff_na counts violations correctly", {
  # Data with clear violation
  data <- matrix(c(
    1, 0,  # No violation (2=0)
    1, 1,  # No violation (1=1, 2=1)
    0, 1,  # VIOLATION (2=1 but 1=0)
    0, 0   # No violation (2=0)
  ), ncol = 2, byrow = TRUE)
  
  # Quasi-order: item 1 is prerequisite for item 2
  qo <- matrix(c(0, 1, 0, 0), nrow = 2, ncol = 2)
  
  result <- compute_diff_na(data, qo)
  
  # 1 violation out of 4 subjects = 0.25
  expect_equal(result$diff, 0.25)
  expect_equal(result$error_rate, 0.25)
})

test_that("iita produces deterministic results", {
  # Same data should produce same results every time
  data <- matrix(c(
    0, 0, 0,
    1, 0, 0,
    1, 1, 0,
    1, 1, 1,
    0, 1, 0
  ), ncol = 3, byrow = TRUE)
  
  result1 <- iita(data)
  result2 <- iita(data)
  result3 <- iita(data)
  
  # All results should be identical
  expect_equal(result1$diff, result2$diff)
  expect_equal(result1$diff, result3$diff)
  expect_equal(result1$selection.set.index, result2$selection.set.index)
  expect_equal(result1$selection.set.index, result3$selection.set.index)
})

test_that("iita handles edge case: all subjects pass all items", {
  # All subjects passed all items
  data <- matrix(1, nrow = 5, ncol = 3)
  
  result <- iita(data)
  
  # No violations possible, all diff values should be 0
  expect_true(all(result$diff == 0))
  
  # Should work without errors
  expect_s3_class(result, "iita")
})

test_that("iita handles edge case: all subjects fail all items", {
  # All subjects failed all items
  data <- matrix(0, nrow = 5, ncol = 3)
  
  result <- iita(data)
  
  # No violations possible (no one passed anything), all diff values should be 0
  expect_true(all(result$diff == 0))
  
  # Should work without errors
  expect_s3_class(result, "iita")
})

test_that("iita with complete data never uses pairwise deletion logic", {
  # This test verifies that for complete data, the pairwise deletion
  # check (!is.na) is always true, making behavior identical to DAKS
  
  data <- matrix(c(
    0, 0, 0,
    1, 0, 0,
    1, 1, 0,
    1, 1, 1
  ), ncol = 3, byrow = TRUE)
  
  # Verify no missing data
  expect_equal(sum(is.na(data)), 0)
  
  result <- iita(data)
  
  # Create quasi-order for testing
  qo <- matrix(c(0, 1, 0, 0, 0, 1, 0, 0, 0), nrow = 3, ncol = 3)
  
  # Manually compute diff without any NA checks (like DAKS would)
  total_violations <- 0
  total_comparisons <- 0
  
  for (i in 1:3) {
    for (j in 1:3) {
      if (i != j && qo[i, j] == 1) {
        for (subj in 1:4) {
          total_comparisons <- total_comparisons + 1
          if (data[subj, j] == 1 && data[subj, i] == 0) {
            total_violations <- total_violations + 1
          }
        }
      }
    }
  }
  
  expected_diff <- if (total_comparisons > 0) total_violations / total_comparisons else 0
  
  # Compute using our function
  computed <- compute_diff_na(data, qo)
  
  # Should match exactly
  expect_equal(computed$diff, expected_diff)
})

test_that("iita example datasets work correctly", {
  # Load and test the knowledge_complete dataset
  data(knowledge_complete)
  
  # Should have no missing values
  expect_equal(sum(is.na(knowledge_complete)), 0)
  
  # Should run without errors
  result <- iita(knowledge_complete)
  
  expect_s3_class(result, "iita")
  expect_equal(result$ni, ncol(knowledge_complete))
  expect_true(length(result$diff) > 0)
  expect_true(all(result$diff >= 0 & result$diff <= 1))
})

test_that("transitive closure is computed correctly", {
  # Test the transitive closure helper function
  # Create a chain: 1->2, 2->3
  m <- matrix(c(
    0, 1, 0,
    0, 0, 1,
    0, 0, 0
  ), nrow = 3, byrow = TRUE)
  
  tc <- iita.na:::transitive_closure(m)
  
  # Should add 1->3 (transitive relation)
  expect_equal(tc[1, 3], 1)
  expect_equal(tc[1, 2], 1)
  expect_equal(tc[2, 3], 1)
  
  # Should preserve original relations
  expect_equal(sum(tc[1,]), 2)  # 1->2 and 1->3
  expect_equal(sum(tc[2,]), 1)  # 2->3
  expect_equal(sum(tc[3,]), 0)  # no outgoing relations
})
