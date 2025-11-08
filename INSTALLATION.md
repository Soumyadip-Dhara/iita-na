# Installation Guide for iita.na

## Prerequisites

- R version 3.5.0 or higher
- For development: roxygen2, testthat, devtools packages

## Installation Methods

### Method 1: Install from Source (Recommended)

1. Clone the repository or download the source code:
```bash
git clone https://github.com/Soumyadip-Dhara/iita-na.git
cd iita-na
```

2. Build the package:
```bash
R CMD build .
```

3. Install the built package:
```bash
R CMD INSTALL iita.na_0.1.0.tar.gz
```

### Method 2: Install Directly in R

```r
# If you have the source directory
install.packages("/path/to/iita-na", repos = NULL, type = "source")

# Or using devtools from GitHub (when available)
# devtools::install_github("Soumyadip-Dhara/iita-na")
```

## Verifying Installation

After installation, verify that the package works correctly:

```r
library(iita.na)

# Test with example data
data(knowledge_complete)
result <- iita(knowledge_complete)
print(result)
```

## Running Tests

For comprehensive testing instructions, see **[TESTING.md](TESTING.md)**.

Quick test from command line:

```bash
cd iita-na
R CMD check --as-cran iita.na_0.1.0.tar.gz
```

Or from within R:

```r
library(testthat)
library(iita.na)
test_package("iita.na")
```

The test suite includes 13 comprehensive tests covering:
- Complete data scenarios
- Missing data handling
- Edge cases
- Input validation
- Selection rules
- Helper functions

## Building Documentation

To rebuild the documentation (requires roxygen2):

```bash
cd iita-na
R -e "roxygen2::roxygenise('.')"
```

## Troubleshooting

### Issue: Missing dependencies

If you encounter errors about missing packages, install them first:

```r
install.packages(c("stats", "testthat"))
```

### Issue: Permission denied during installation

Use `sudo` on Unix-like systems:

```bash
sudo R CMD INSTALL iita.na_0.1.0.tar.gz
```

Or install to a user library:

```r
install.packages("iita.na_0.1.0.tar.gz", repos = NULL, type = "source", 
                 lib = "~/R/library")
```

## System Requirements

- Operating System: Linux, macOS, or Windows
- Memory: Minimum 100 MB RAM (more for large datasets)
- Disk Space: ~1 MB for installation

## Additional Resources

- Package documentation: `?iita` or `help(package = "iita.na")`
- Example datasets: `?knowledge_complete`, `?knowledge_missing`
- GitHub repository: https://github.com/Soumyadip-Dhara/iita-na
