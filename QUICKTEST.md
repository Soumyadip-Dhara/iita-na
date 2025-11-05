# Quick Test Reference

This is a quick reference for testing the iita.na package. For comprehensive documentation, see [TESTING.md](TESTING.md).

## Prerequisites

```r
# Install test dependencies
install.packages(c("testthat", "devtools"))
```

## Run All Tests

```r
library(testthat)
library(iita.na)
test_package("iita.na")
```

Expected result: **13 tests should PASS**

## Quick Manual Test

```r
library(iita.na)

# Test 1: Complete data
data <- matrix(c(0,0,0, 1,0,0, 1,1,0, 1,1,1), ncol=3, byrow=TRUE)
result <- iita(data)
print(result)  # Should show clear prerequisite structure

# Test 2: Missing data
data_na <- matrix(c(0,0,0, 1,NA,0, 1,1,NA, 1,1,1), ncol=3, byrow=TRUE)
result_na <- iita(data_na)
print(result_na)  # Should handle NA gracefully

# Test 3: Example datasets
data(knowledge_complete)
result <- iita(knowledge_complete)
print(result)  # Should run without errors
```

## Full Package Check

```bash
R CMD build .
R CMD check --as-cran iita.na_0.1.0.tar.gz
```

Expected result: **Status: OK**

## Validation Against DAKS

To validate missing data handling and compare with DAKS:

```r
# See VALIDATION.md for complete scripts
library(DAKS)
library(iita.na)

# Quick comparison
data <- matrix(c(0,0,0, 1,0,0, 1,1,0, 1,1,1), ncol=3, byrow=TRUE)
daks_result <- DAKS::iita(data, v=1)
iita_result <- iita(data)

# Should be identical for complete data
all(abs(daks_result$diff - iita_result$diff) < 1e-10)
```

See **[VALIDATION.md](VALIDATION.md)** for comprehensive validation tests.

## CI/CD Testing

The package includes GitHub Actions workflow for automated testing across:
- Multiple OS: Ubuntu, macOS, Windows
- Multiple R versions: 3.6, 4.0, 4.2

See `.github/workflows/test.yml`

## Common Issues

| Issue | Solution |
|-------|----------|
| Package not found | `R CMD INSTALL iita.na_0.1.0.tar.gz` |
| testthat not found | `install.packages("testthat")` |
| Tests fail | Check [Troubleshooting](TESTING.md#troubleshooting) |

## Need Help?

- **Full documentation**: [TESTING.md](TESTING.md)
- **Installation**: [INSTALLATION.md](INSTALLATION.md)
- **Examples**: [USAGE_EXAMPLES.md](USAGE_EXAMPLES.md)
- **Issues**: https://github.com/Soumyadip-Dhara/iita-na/issues
