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
# Note: The main function is iita_na() to avoid conflicts with the DAKS package

# Create a binary response matrix (subjects x items)
# 1 = item passed, 0 = item failed
data <- matrix(c(
  0, 0, 0,  # Subject 1: Failed all items
  1, 0, 0,  # Subject 2: Passed only item 1
  1, 1, 0,  # Subject 3: Passed items 1 and 2
  1, 1, 1   # Subject 4: Passed all items
), ncol = 3, byrow = TRUE)

# Run IITA analysis
result <- iita_na(data)

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
result_na <- iita_na(data_na)
print(result_na)
```

### Selection Rules

The `iita` function supports two selection rules:

- `"minimal"` (default): Selects quasi-orders with minimal diff values
- `"corrected"`: Applies a corrected selection procedure with a threshold

```r
# Using corrected selection rule
result <- iita_na(data, selrule = "corrected")
```

## Features

- **Missing Data Support**: Handles NA values using pairwise deletion
- **Backward Compatibility**: Produces identical results to DAKS for complete data ([see detailed documentation](DAKS_COMPATIBILITY.md))
- **Multiple Selection Rules**: Supports both minimal and corrected selection
- **Comprehensive Testing**: Includes extensive test suite

## How Missing Data is Handled

When computing the diff value (discrepancy between data and quasi-order):
- For each prerequisite relation i→j, the function examines each subject
- If either item i or j has missing data for a subject, that observation is excluded from the calculation for that specific relation
- This pairwise deletion approach ensures maximum use of available data while maintaining statistical validity

## Output Structure

The `iita_na` function returns a list with:
- `diff`: Vector of diff values for each quasi-order
- `selection.set.index`: Indices of selected quasi-orders
- `implications`: List of implications (prerequisite relations) for selected quasi-orders
- `v`: The set of competing quasi-orders tested
- `ni`: Number of items
- `nq`: Number of quasi-orders
- `error.rate`: Error rates for each quasi-order

### Understanding Multiple Selected Quasi-Orders

It's common for IITA to select multiple quasi-orders, especially with small datasets or perfect hierarchical structures. This happens because:

1. **Relations not in a quasi-order are not tested**: A quasi-order with fewer relations doesn't create violations for relations it doesn't specify
2. **Multiple structures can fit equally well**: When data is perfectly hierarchical, both minimal and more complex structures may have diff=0
3. **This is standard IITA behavior**: The algorithm correctly identifies all quasi-orders that fit the data equally well

For example, with data showing a perfect chain 1→2→3:
- The empty quasi-order (no relations) has diff=0 because it makes no claims to violate
- Single relations like 1→2 have diff=0 because this relation isn't violated
- The complete chain 1→2→3 also has diff=0 because all relations hold

This is not a bug but a feature - it shows you all structures that are consistent with your data. You can then choose among them based on theoretical considerations or examine the most complex selected structure (typically the one with most relations).

## DAKS Compatibility

**For datasets without missing values, this package produces exactly the same results as the DAKS package.**

This compatibility is achieved through:
- Identical algorithm implementation for the core IITA method
- Same diff value calculations for complete data
- Same selection rules (minimal and corrected)
- Pairwise deletion that becomes transparent when no data is missing

See [DAKS_COMPATIBILITY.md](DAKS_COMPATIBILITY.md) for comprehensive documentation including:
- Mathematical proof of equivalence
- Code comparison examples
- Validation procedures
- Theoretical justification

**Quick validation**: Run `source("examples/validate_daks_compatibility.R")` to verify implementation correctness with automated tests.

## Testing

This package includes comprehensive testing for:
- **Various matrix sizes**: From 2x4 to 100x15, all tested and validated
- **Missing data patterns**: 0%, 10%, 25%, and 50% missing data levels
- **DAKS compatibility**: Verified identical results for complete data

### Quick Test

```r
# Generate and run comprehensive test report
source("examples/generate_test_report.R")

# Compare with DAKS on PISA dataset (requires DAKS package)
source("examples/compare_with_daks_pisa.R")
```

### Documentation

- **[TESTING.md](TESTING.md)**: Comprehensive testing documentation with detailed findings
- **[STEP_BY_STEP_TESTING_GUIDE.md](STEP_BY_STEP_TESTING_GUIDE.md)**: Complete guide from cloning to test results
- **[DAKS_COMPATIBILITY.md](DAKS_COMPATIBILITY.md)**: Detailed DAKS compatibility verification
- **[PISA_COMPARISON_GUIDE.md](PISA_COMPARISON_GUIDE.md)**: Guide for comparing with DAKS on PISA dataset

### Key Findings

✓ All matrix sizes (2x4 to 100x15) tested successfully  
✓ Missing data handled gracefully at all levels (0-50%)  
✓ DAKS compatibility verified for complete data (5/5 tests pass)  
✓ Performance scales well with data size  
✓ Results are deterministic and reliable

## References

- Original DAKS package: https://cran.r-project.org/package=DAKS
- Sargin, A., & Ünlü, A. (2009). Inductive item tree analysis: Corrections, improvements, and comparisons. Mathematical Social Sciences, 58(3), 376-392.

## License

GPL (>= 2)

## Contributing

Contributions are welcome! Please feel free to submit issues or pull requests.