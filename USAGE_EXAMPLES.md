# Usage Examples for iita.na

This document provides detailed examples of using the iita.na package for inductive item tree analysis with and without missing data.

## Basic Usage

### Example 1: Simple Dataset with No Missing Data

```r
library(iita.na)

# Create a simple 4-subject, 3-item dataset
# Subjects progressively master items 1, 2, then 3
data <- matrix(c(
  0, 0, 0,  # Subject 1: Failed all
  1, 0, 0,  # Subject 2: Passed only item 1
  1, 1, 0,  # Subject 3: Passed items 1 and 2
  1, 1, 1   # Subject 4: Passed all items
), ncol = 3, byrow = TRUE)

# Run IITA analysis
result <- iita_na(data)
print(result)

# Access specific results
cat("Number of items:", result$ni, "\n")
cat("Diff values:", result$diff, "\n")
cat("Selected quasi-order indices:", result$selection.set.index, "\n")
```

### Example 2: Dataset with Missing Values

```r
# Same structure as above, but with missing data
data_missing <- matrix(c(
  0, 0, 0,
  1, NA, 0,  # Missing value for item 2
  1, 1, NA,  # Missing value for item 3
  1, 1, 1
), ncol = 3, byrow = TRUE)

# Run IITA analysis - missing values handled automatically
result_missing <- iita_na(data_missing)
print(result_missing)

# The algorithm uses pairwise deletion for missing data
# Results will be similar to complete data but adjusted for available information
```

## Working with Example Datasets

### Example 3: Knowledge Assessment - Complete Data

```r
library(iita.na)

# Load the included example dataset
data(knowledge_complete)

# Examine the data
head(knowledge_complete)
dim(knowledge_complete)  # 20 subjects, 5 items

# Run IITA
result <- iita_na(knowledge_complete)

# View selected quasi-orders
for (i in seq_along(result$selection.set.index)) {
  idx <- result$selection.set.index[i]
  cat("\nQuasi-order", i, "(index", idx, "):\n")
  qo <- result$implications[[i]]
  
  # Print prerequisite relations
  for (r in 1:nrow(qo)) {
    for (c in 1:ncol(qo)) {
      if (qo[r, c] == 1) {
        cat("  Item", r, "is prerequisite for Item", c, "\n")
      }
    }
  }
}
```

### Example 4: Knowledge Assessment - Missing Data

```r
# Load dataset with missing values
data(knowledge_missing)

# Check missing data pattern
cat("Total missing values:", sum(is.na(knowledge_missing)), "\n")
cat("Proportion missing:", 
    round(mean(is.na(knowledge_missing)) * 100, 1), "%\n")

# Run IITA with missing data
result_missing <- iita_na(knowledge_missing)

# Compare with complete data results
data(knowledge_complete)
result_complete <- iita(knowledge_complete)

cat("\nComparison:\n")
cat("Complete data - selected quasi-orders:", 
    length(result_complete$selection.set.index), "\n")
cat("Missing data - selected quasi-orders:", 
    length(result_missing$selection.set.index), "\n")
cat("Complete data - min diff:", min(result_complete$diff), "\n")
cat("Missing data - min diff:", min(result_missing$diff), "\n")
```

## Advanced Usage

### Example 5: Using Different Selection Rules

```r
library(iita.na)
data(knowledge_complete)

# Minimal selection rule (default)
result_minimal <- iita(knowledge_complete, selrule = "minimal")
cat("Minimal rule selected:", length(result_minimal$selection.set.index), 
    "quasi-orders\n")

# Corrected selection rule (more permissive)
result_corrected <- iita(knowledge_complete, selrule = "corrected")
cat("Corrected rule selected:", length(result_corrected$selection.set.index), 
    "quasi-orders\n")
```

### Example 6: Providing Custom Quasi-Orders

```r
# Generate quasi-orders for 3 items
qos <- generate_quasiorders(3)
cat("Generated", length(qos), "quasi-orders\n")

# Create custom dataset
data <- matrix(rbinom(30, 1, 0.6), ncol = 3)

# Test specific quasi-orders
result <- iita_na(data, v = qos)
print(result)
```

### Example 7: Computing Diff Values Manually

```r
# Create a simple dataset
data <- matrix(c(
  1, 0,
  1, 1,
  0, 1,
  1, 1
), ncol = 2, byrow = TRUE)

# Define a quasi-order: item 1 is prerequisite for item 2
qo <- matrix(c(0, 1,
               0, 0), nrow = 2, byrow = TRUE)

# Compute diff value
diff_result <- compute_diff_na(data, qo)
cat("Diff value:", diff_result$diff, "\n")
cat("Error rate:", diff_result$error_rate, "\n")

# Interpretation:
# Diff value represents the proportion of violations of the quasi-order
# A violation occurs when a subject passes item 2 but fails item 1
```

## Real-World Application Example

### Example 8: Analyzing Educational Test Data

```r
# Simulate a realistic educational assessment scenario
set.seed(42)

# 50 students, 6 test items
n_students <- 50
n_items <- 6

# Generate data with realistic patterns
# Items have increasing difficulty: 1 (easiest) to 6 (hardest)
test_data <- matrix(0, nrow = n_students, ncol = n_items)

for (i in 1:n_students) {
  # Student ability level
  ability <- runif(1, 0, 1)
  
  # Probability of passing each item based on ability and difficulty
  difficulties <- c(0.2, 0.35, 0.5, 0.65, 0.75, 0.85)
  for (j in 1:n_items) {
    prob_pass <- plogis((ability - difficulties[j]) * 5)
    test_data[i, j] <- rbinom(1, 1, prob_pass)
  }
}

# Add some missing data (students who skipped questions)
missing_mask <- matrix(runif(n_students * n_items) < 0.05, 
                       nrow = n_students, ncol = n_items)
test_data[missing_mask] <- NA

colnames(test_data) <- paste0("Q", 1:n_items)

# Analyze the prerequisite structure
result <- iita_na(test_data, selrule = "corrected")

# Display results
cat("\nTest Analysis Results\n")
cat("=====================\n")
cat("Students:", n_students, "\n")
cat("Questions:", n_items, "\n")
cat("Missing responses:", sum(is.na(test_data)), "\n")
cat("\nIdentified", length(result$selection.set.index), 
    "potential prerequisite structures\n")

# Show the best structure
if (length(result$selection.set.index) > 0) {
  cat("\nBest prerequisite structure:\n")
  best_qo <- result$implications[[1]]
  for (i in 1:nrow(best_qo)) {
    for (j in 1:ncol(best_qo)) {
      if (best_qo[i, j] == 1) {
        cat("  Q", i, "is a prerequisite for Q", j, "\n", sep = "")
      }
    }
  }
}
```

## Tips and Best Practices

1. **Data Preparation**: Ensure your data is in binary format (0, 1, or NA)
2. **Sample Size**: IITA works better with larger sample sizes (>20 subjects recommended)
3. **Missing Data**: The algorithm handles missing data automatically, but be aware that extensive missing data may reduce statistical power
4. **Interpretation**: Multiple selected quasi-orders suggest ambiguity in the data; consider collecting more data or using the corrected selection rule
5. **Validation**: Always validate your findings with domain expertise and cross-validation

## Common Issues and Solutions

### Issue: Too many quasi-orders selected

**Solution**: Use the "corrected" selection rule, which is more conservative, or collect more data to reduce ambiguity.

```r
result <- iita_na(data, selrule = "corrected")
```

### Issue: All data is missing for some items

**Solution**: Remove items with excessive missing data before analysis.

```r
# Check missing data per item
missing_per_item <- colMeans(is.na(data))
keep_items <- missing_per_item < 0.5  # Keep items with <50% missing
data_clean <- data[, keep_items]
```

### Issue: Results don't match expectations

**Solution**: IITA is exploratory. Results should be validated against theoretical expectations and additional data.
