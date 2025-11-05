test_that("iita works with complete data", {
  # Simple 3-item dataset with clear prerequisite structure
  # Item 1 is easiest, Item 2 requires Item 1, Item 3 requires Item 2
  data <- matrix(c(
    0, 0, 0,  # Failed all
    1, 0, 0,  # Passed only item 1
    1, 1, 0,  # Passed items 1 and 2
    1, 1, 1   # Passed all
  ), ncol = 3, byrow = TRUE)
  
  result <- iita(data)
  
  # Basic structure checks
  expect_s3_class(result, "iita")
  expect_true(is.list(result))
  expect_true(all(c("diff", "selection.set.index", "implications", "v", "ni", "nq") %in% names(result)))
  expect_equal(result$ni, 3)
  expect_true(result$nq > 0)
  expect_true(length(result$diff) == result$nq)
  expect_true(all(result$diff >= 0 & result$diff <= 1))
})

test_that("iita works with missing data", {
  # Dataset with missing values
  data <- matrix(c(
    0, 0, 0,
    1, NA, 0,
    1, 1, NA,
    1, 1, 1
  ), ncol = 3, byrow = TRUE)
  
  result <- iita(data)
  
  # Should complete without error
  expect_s3_class(result, "iita")
  expect_equal(result$ni, 3)
  expect_true(length(result$selection.set.index) > 0)
})

test_that("iita handles all missing data", {
  # Dataset with only missing values
  data <- matrix(NA, nrow = 3, ncol = 3)
  
  result <- iita(data)
  
  # Should complete without error
  expect_s3_class(result, "iita")
  expect_equal(result$ni, 3)
})

test_that("iita validates input", {
  # Non-binary data should throw error
  data <- matrix(c(0, 1, 2, 3), ncol = 2)
  expect_error(iita(data), "must contain only 0, 1, or NA")
  
  # Invalid selrule
  data <- matrix(c(0, 1, 0, 1), ncol = 2)
  expect_error(iita(data, selrule = "invalid"), "must be either 'minimal' or 'corrected'")
  
  # Non-matrix input should be handled
  data <- data.frame(x = c(0, 1), y = c(0, 1))
  expect_silent(iita(data))
})

test_that("compute_diff_na handles missing data correctly", {
  # Create a simple dataset
  data <- matrix(c(
    1, 0,
    1, 1,
    NA, 1,
    1, NA
  ), ncol = 2, byrow = TRUE)
  
  # Create a quasi-order where item 1 is prerequisite for item 2
  qo <- matrix(c(0, 1, 0, 0), nrow = 2, ncol = 2)
  
  result <- compute_diff_na(data, qo)
  
  expect_true(is.list(result))
  expect_true("diff" %in% names(result))
  expect_true("error_rate" %in% names(result))
  expect_true(result$diff >= 0 && result$diff <= 1)
})

test_that("generate_quasiorders produces valid output", {
  # Test with 2 items
  qos <- generate_quasiorders(2)
  
  expect_true(is.list(qos))
  expect_true(length(qos) > 0)
  expect_true(all(sapply(qos, is.matrix)))
  expect_true(all(sapply(qos, function(m) nrow(m) == 2 && ncol(m) == 2)))
  expect_true(all(sapply(qos, function(m) all(m %in% c(0, 1)))))
})

test_that("transitive_closure works correctly", {
  # Create a simple relation: 1->2, 2->3
  m <- matrix(c(0, 1, 0,
                0, 0, 1,
                0, 0, 0), nrow = 3, byrow = TRUE)
  
  tc <- iita.na:::transitive_closure(m)
  
  # Should add 1->3
  expect_equal(tc[1, 3], 1)
  expect_equal(tc[1, 2], 1)
  expect_equal(tc[2, 3], 1)
})

test_that("iita produces consistent results for same data", {
  data <- matrix(c(
    0, 0, 0,
    1, 0, 0,
    1, 1, 0,
    1, 1, 1
  ), ncol = 3, byrow = TRUE)
  
  result1 <- iita(data)
  result2 <- iita(data)
  
  expect_equal(result1$diff, result2$diff)
  expect_equal(result1$selection.set.index, result2$selection.set.index)
  expect_equal(result1$ni, result2$ni)
})

test_that("print.iita works without error", {
  data <- matrix(c(0, 0, 1, 1, 1, 0), ncol = 2, byrow = TRUE)
  result <- iita(data)
  
  expect_output(print(result), "Inductive Item Tree Analysis")
  expect_output(print(result), "Number of items:")
})

test_that("iita handles single item", {
  data <- matrix(c(0, 1, 0, 1), ncol = 1)
  result <- iita(data)
  
  expect_equal(result$ni, 1)
  expect_s3_class(result, "iita")
})

test_that("iita corrected selection rule works", {
  data <- matrix(c(
    0, 0, 0,
    1, 0, 0,
    1, 1, 0,
    1, 1, 1
  ), ncol = 3, byrow = TRUE)
  
  result <- iita(data, selrule = "corrected")
  
  expect_s3_class(result, "iita")
  expect_true(length(result$selection.set.index) > 0)
})
