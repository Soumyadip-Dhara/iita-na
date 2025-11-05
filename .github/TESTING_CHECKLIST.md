# Testing Checklist for iita.na

Use this checklist to ensure thorough testing before releases or major changes.

## Pre-Release Testing Checklist

### 1. Environment Setup
- [ ] R version 3.5.0 or higher installed
- [ ] testthat package installed
- [ ] devtools package installed
- [ ] roxygen2 package installed

### 2. Automated Tests
- [ ] Run `test_package("iita.na")` - All 13 tests pass
- [ ] Run `R CMD check --as-cran` - Status: OK
- [ ] No warnings in check output
- [ ] No notes in check output (or all notes are acceptable)

### 3. Manual Testing - Core Functions

#### iita() Function
- [ ] Works with complete data (no NA values)
- [ ] Works with missing data (contains NA values)
- [ ] Works with all missing data
- [ ] Handles single item datasets
- [ ] Handles large datasets (100+ subjects)
- [ ] Selection rule "minimal" works
- [ ] Selection rule "corrected" works
- [ ] Returns correct result structure (class "iita")
- [ ] All result components present (diff, selection.set.index, implications, etc.)

#### generate_quasiorders() Function
- [ ] Works with 1 item
- [ ] Works with 2 items
- [ ] Works with 3 items
- [ ] Works with 5+ items
- [ ] Returns list of matrices
- [ ] All matrices are square and binary

#### compute_diff_na() Function
- [ ] Computes diff correctly for complete data
- [ ] Computes diff correctly with missing data
- [ ] Handles all missing data gracefully
- [ ] Returns values between 0 and 1

#### print.iita() Function
- [ ] Displays readable output
- [ ] Shows all key information
- [ ] Works with single selected quasi-order
- [ ] Works with multiple selected quasi-orders

### 4. Input Validation
- [ ] Rejects non-binary data (values other than 0, 1, NA)
- [ ] Rejects invalid selection rules
- [ ] Handles data.frame input (converts to matrix)
- [ ] Handles matrix input
- [ ] Appropriate error messages for all invalid inputs

### 5. Example Datasets
- [ ] knowledge_complete loads correctly
- [ ] knowledge_missing loads correctly
- [ ] Both datasets work with iita() function
- [ ] Both datasets have proper documentation

### 6. Documentation
- [ ] All exported functions have help pages (`?iita`)
- [ ] Examples in help pages run without errors
- [ ] README.md is up to date
- [ ] TESTING.md is comprehensive
- [ ] INSTALLATION.md has correct instructions
- [ ] USAGE_EXAMPLES.md has working examples

### 7. Edge Cases
- [ ] Empty quasi-order (no prerequisites) works
- [ ] Data with no variance (all 0s or all 1s)
- [ ] Data with perfect prerequisite structure
- [ ] Data with random patterns (no clear structure)
- [ ] Single subject dataset
- [ ] Single item dataset

### 8. Performance
- [ ] Runs in reasonable time (<5 seconds for 50 subjects × 5 items)
- [ ] Memory usage is acceptable (<100 MB for typical datasets)
- [ ] No memory leaks (run multiple times)

### 9. Cross-Platform Testing
- [ ] Works on Linux
- [ ] Works on macOS
- [ ] Works on Windows
- [ ] Works with R 3.6.x
- [ ] Works with R 4.0.x
- [ ] Works with R 4.2.x

### 10. CI/CD
- [ ] GitHub Actions workflow runs successfully
- [ ] All CI tests pass on all platforms
- [ ] Artifacts are generated correctly on failures

### 11. Code Quality
- [ ] No syntax errors
- [ ] No undefined variables
- [ ] Consistent code style
- [ ] Appropriate comments where needed
- [ ] No TODO or FIXME comments (or all documented as issues)

### 12. Package Structure
- [ ] DESCRIPTION file is correct and complete
- [ ] NAMESPACE file is properly generated
- [ ] All R files in R/ directory
- [ ] All tests in tests/testthat/
- [ ] All data files in data/ directory
- [ ] All documentation in man/ directory
- [ ] .Rbuildignore excludes appropriate files

### 13. Final Verification
- [ ] Package builds without errors: `R CMD build .`
- [ ] Package installs without errors: `R CMD INSTALL iita.na_*.tar.gz`
- [ ] Can load package: `library(iita.na)`
- [ ] Can run example: `data(knowledge_complete); iita(knowledge_complete)`
- [ ] Can run all examples from USAGE_EXAMPLES.md

## Quick Test Commands

```r
# Load and test
library(testthat)
library(iita.na)

# Run all tests
test_package("iita.na")

# Quick manual test
data(knowledge_complete)
result <- iita(knowledge_complete)
print(result)

data(knowledge_missing)
result <- iita(knowledge_missing, selrule = "corrected")
print(result)
```

```bash
# Full check
R CMD build .
R CMD check --as-cran iita.na_0.1.0.tar.gz
```

## Notes

- This checklist should be completed before:
  - Creating a new release
  - Merging major changes
  - Submitting to CRAN
  - Making the package public

- Document any failures or unexpected behavior as GitHub issues

- Keep this checklist updated as new features are added
