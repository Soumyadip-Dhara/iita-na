# Testing Overview for iita.na

This document provides a high-level overview of the testing infrastructure for the iita.na R package.

## Quick Navigation

| Document | Purpose | Audience |
|----------|---------|----------|
| [QUICKTEST.md](../QUICKTEST.md) | Quick reference for common tests | All users |
| [TESTING.md](../TESTING.md) | Comprehensive testing guide | Developers & Contributors |
| [TESTING_CHECKLIST.md](TESTING_CHECKLIST.md) | Pre-release verification checklist | Maintainers |
| [test.yml](workflows/test.yml) | CI/CD configuration | DevOps |

## Testing Levels

### 1. Automated Unit Tests
- **Location**: `tests/testthat/test-iita.R`
- **Framework**: testthat
- **Coverage**: 13 tests covering:
  - Core functionality
  - Missing data handling
  - Edge cases
  - Input validation
  - Helper functions
  - Selection rules
- **How to run**: `test_package("iita.na")`
- **Expected result**: All 13 tests pass

### 2. Package Checks
- **Command**: `R CMD check --as-cran`
- **Validates**:
  - Package structure
  - Documentation completeness
  - Example code correctness
  - CRAN compliance
  - Cross-platform compatibility
- **Expected result**: Status OK, no warnings or notes

### 3. Manual Testing
- **Guide**: [TESTING.md](../TESTING.md) sections 4-5
- **Includes**:
  - Basic functionality verification
  - Missing data handling
  - Example datasets
  - Selection rules
  - Edge cases
  - Custom data testing
- **Time required**: 5-10 minutes

### 4. Continuous Integration
- **Platform**: GitHub Actions
- **Workflow**: `.github/workflows/test.yml`
- **Matrix**:
  - OS: Ubuntu, macOS, Windows
  - R versions: 3.6, 4.0, 4.2
  - Total: 9 configurations
- **Triggers**: Push to main/develop, Pull requests
- **Time**: ~5-10 minutes per configuration

## Testing Workflow

### For Users Testing the Package

```
1. Install package
   ↓
2. Run quick test (QUICKTEST.md)
   ↓
3. Try examples (USAGE_EXAMPLES.md)
   ↓
4. Test with own data
```

### For Developers Making Changes

```
1. Make code changes
   ↓
2. Run unit tests (test_package)
   ↓
3. Fix any failures
   ↓
4. Run R CMD check
   ↓
5. Manual verification (if needed)
   ↓
6. Commit and push
   ↓
7. CI runs automatically
   ↓
8. Review CI results
```

### For Maintainers Before Release

```
1. Complete TESTING_CHECKLIST.md
   ↓
2. Ensure all CI passes
   ↓
3. Run tests on multiple platforms
   ↓
4. Verify documentation is current
   ↓
5. Update version and NEWS
   ↓
6. Create release
```

## Test Infrastructure Files

### Source Files
```
iita-na/
├── R/
│   ├── iita.R              # Main functions (tested)
│   └── data.R              # Data documentation
├── tests/
│   ├── testthat.R          # Test runner
│   └── testthat/
│       └── test-iita.R     # 13 unit tests
└── data/
    ├── knowledge_complete.rda  # Test data
    └── knowledge_missing.rda   # Test data
```

### Documentation Files
```
iita-na/
├── TESTING.md              # Comprehensive guide (11 KB)
├── QUICKTEST.md            # Quick reference (1.7 KB)
├── INSTALLATION.md         # Includes testing section
├── README.md               # Includes testing section
└── .github/
    ├── TESTING_CHECKLIST.md    # Pre-release checklist (4.7 KB)
    ├── TESTING_OVERVIEW.md     # This file
    └── workflows/
        └── test.yml            # CI/CD configuration
```

## Test Statistics

### Automated Tests
- **Total tests**: 13
- **Functions tested**: 8
  - iita()
  - generate_quasiorders()
  - compute_diff_na()
  - transitive_closure()
  - print.iita()
  - Input validation
  - Edge cases
  - Consistency checks

### Test Execution Time
- Unit tests: < 1 second
- R CMD check: 2-3 minutes
- Full CI matrix: ~5-10 minutes per config

### Test Coverage
- Core functionality: ✓ Complete
- Missing data handling: ✓ Complete
- Edge cases: ✓ Complete
- Documentation examples: ✓ All runnable
- Cross-platform: ✓ Linux, macOS, Windows
- R versions: ✓ 3.6, 4.0, 4.2

## Common Testing Scenarios

### "I just want to verify the package works"
→ See [QUICKTEST.md](../QUICKTEST.md)

### "I'm making code changes and need to test"
→ See [TESTING.md](../TESTING.md) sections 3-4

### "I'm preparing a release"
→ Complete [TESTING_CHECKLIST.md](TESTING_CHECKLIST.md)

### "I need to set up automated testing"
→ See [TESTING.md](../TESTING.md) section 6 (Continuous Integration)

### "Tests are failing and I need help"
→ See [TESTING.md](../TESTING.md) section 7 (Troubleshooting)

## Key Testing Commands

```r
# Quick test
library(testthat); library(iita.na); test_package("iita.na")

# With detailed output
test_package("iita.na", reporter = "progress")

# Specific test file
test_file("tests/testthat/test-iita.R")
```

```bash
# Full package check
R CMD build .
R CMD check --as-cran iita.na_0.1.0.tar.gz

# Fast check (no manual)
R CMD check --no-manual iita.na_0.1.0.tar.gz
```

## Success Criteria

### For Unit Tests
- All 13 tests pass
- No failures, warnings, or skips
- Execution time < 1 second

### For Package Check
- Status: OK
- Zero errors
- Zero warnings
- Zero notes (or only acceptable notes)

### For Manual Testing
- All examples run without errors
- Results are interpretable and correct
- Edge cases handled gracefully
- Error messages are clear

### For CI
- All 9 configurations pass
- No platform-specific failures
- Artifacts available on failure

## Maintenance

This testing infrastructure should be maintained by:

1. **Adding tests** when adding new features
2. **Updating documentation** when changing functionality
3. **Reviewing CI results** on every PR
4. **Running full checklist** before releases
5. **Keeping R versions current** in CI matrix

## Support

For questions about testing:

1. Check the relevant documentation file
2. Review test files in `tests/testthat/`
3. Check CI logs for failures
4. Open an issue: https://github.com/Soumyadip-Dhara/iita-na/issues

---

**Last Updated**: November 2025  
**Package Version**: 0.1.0  
**Test Count**: 13  
**CI Configurations**: 9 (3 OS × 3 R versions)
