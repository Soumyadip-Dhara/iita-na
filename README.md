# iita.na - Inductive Item Tree Analysis with Missing Data Support

An R package that adapts the IITA (Inductive Item Tree Analysis) function from the DAKS package to handle datasets with missing values. For complete data (no missing values), this package produces identical results to the original DAKS implementation.

## Overview

IITA is a data analysis method for deriving quasi-orders (prerequisite structures) from binary data matrices in knowledge space theory. This package extends the original functionality to gracefully handle missing data using pairwise deletion strategies.

## Installation

You can install the package directly from the source:

```r
# Install from local source
install.packages("path/to/iita.na", repos = NULL, type = "source")

# Or using devtools from GitHub
# devtools::install_github("Soumyadip-Dhara/iita-na")
```

## Usage

### Basic Example with Complete Data

```r
library(iita.na)

# Create a binary response matrix (subjects x items)
# 1 = item passed, 0 = item failed
data <- matrix(c(
  0, 0, 0,  # Subject 1: Failed all items
  1, 0, 0,  # Subject 2: Passed only item 1
  1, 1, 0,  # Subject 3: Passed items 1 and 2
  1, 1, 1   # Subject 4: Passed all items
), ncol = 3, byrow = TRUE)

# Run IITA analysis
result <- iita(data)

# View results
print(result)
```

### Example with Missing Data

```r
# Create a dataset with missing values (NA)
data_na <- matrix(c(
  0, 0, 0,
  1, NA, 0,   # Missing value for item 2
  1, 1, NA,   # Missing value for item 3
  1, 1, 1
), ncol = 3, byrow = TRUE)

# Run IITA analysis - missing values are handled automatically
result_na <- iita(data_na)
print(result_na)
```

### Selection Rules

The `iita` function supports two selection rules:

- `"minimal"` (default): Selects quasi-orders with minimal diff values
- `"corrected"`: Applies a corrected selection procedure with a threshold

```r
# Using corrected selection rule
result <- iita(data, selrule = "corrected")
```

## Features

- **Missing Data Support**: Handles NA values using pairwise deletion
- **Backward Compatibility**: Produces identical results to DAKS for complete data
- **Multiple Selection Rules**: Supports both minimal and corrected selection
- **Comprehensive Testing**: Includes extensive test suite

## How Missing Data is Handled

When computing the diff value (discrepancy between data and quasi-order):
- For each prerequisite relation i→j, the function examines each subject
- If either item i or j has missing data for a subject, that observation is excluded from the calculation for that specific relation
- This pairwise deletion approach ensures maximum use of available data while maintaining statistical validity

## Output Structure

The `iita` function returns a list with:
- `diff`: Vector of diff values for each quasi-order
- `selection.set.index`: Indices of selected quasi-orders
- `implications`: List of implications (prerequisite relations) for selected quasi-orders
- `v`: The set of competing quasi-orders tested
- `ni`: Number of items
- `nq`: Number of quasi-orders
- `error.rate`: Error rates for each quasi-order

## Testing

For comprehensive testing instructions, see [TESTING.md](TESTING.md). Quick test:

```r
# Install test dependencies
install.packages(c("testthat", "devtools"))

# Run all tests
library(testthat)
library(iita.na)
test_package("iita.na")
```

Or using R CMD check:

```bash
R CMD build .
R CMD check --as-cran iita.na_0.1.0.tar.gz
```

## Validation

To validate that iita.na handles missing data correctly and produces identical results to DAKS for complete data, see [VALIDATION.md](VALIDATION.md). This includes:
- Missing data handling verification
- Direct comparison with DAKS package
- Complete validation scripts

## References

- Original DAKS package: https://cran.r-project.org/package=DAKS
- Sargin, A., & Ünlü, A. (2009). Inductive item tree analysis: Corrections, improvements, and comparisons. Mathematical Social Sciences, 58(3), 376-392.

## License

GPL (>= 2)

## Contributing

Contributions are welcome! Please feel free to submit issues or pull requests.