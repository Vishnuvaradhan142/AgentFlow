# CI/CD Pipeline Documentation

## Overview

AgentFlow uses GitHub Actions for continuous integration and deployment. The CI/CD pipeline ensures code quality, runs tests, and automates releases.

## Workflows

### 1. CI Workflow (`.github/workflows/ci.yml`)

Runs on every push and pull request to `main` and `develop` branches.

#### Jobs

##### **Test** (Matrix Strategy)
- **Platforms**: Ubuntu, Windows, macOS
- **Python Versions**: 3.10, 3.11, 3.12
- **Steps**:
  - Install dependencies
  - Run unit tests
  - Verify CLI and adapter imports

##### **Lint** (Code Quality)
- **Tools**:
  - **Black**: Code formatting checker
  - **isort**: Import sorting verification
  - **Flake8**: Linting and syntax checking
  - **mypy**: Type checking
- **Note**: Linting failures are non-blocking (continue-on-error) to allow gradual adoption

##### **Coverage**
- Runs unit tests with coverage reporting
- Uploads results to Codecov
- Generates coverage reports (XML and terminal)

##### **Security**
- **Safety**: Checks dependencies for known vulnerabilities
- **Bandit**: Scans code for security issues
- **Note**: Security scans are non-blocking but generate reports

##### **Build**
- Builds distribution packages (wheel and source)
- Validates packages with twine
- Uploads build artifacts

##### **Integration** (Main branch only)
- Tests viewer server startup
- Runs end-to-end tests with mock adapter
- Only runs on pushes to `main`

##### **Docs**
- Validates documentation files exist
- Checks YAML syntax in example files

##### **Summary**
- Aggregates results from all jobs
- Posts summary to GitHub Actions UI

### 2. Release Workflow (`.github/workflows/release.yml`)

Triggered by version tags (e.g., `v0.2.0`) or manual dispatch.

#### Steps
1. Build distribution packages
2. Validate packages
3. Create GitHub Release with auto-generated notes
4. Upload wheel and source distributions
5. (Optional) Publish to PyPI

### 3. Dependabot (`.github/dependabot.yml`)

Automated dependency updates:
- **Python packages**: Weekly on Mondays
- **GitHub Actions**: Weekly on Mondays
- Limits: 5 PRs for Python, 3 for Actions

## Issue Templates

### Bug Report (`.github/ISSUE_TEMPLATE/bug_report.yml`)
Structured form for reporting bugs with:
- Bug description
- Reproduction steps
- Expected vs actual behavior
- Environment details (OS, Python version, adapter)
- Error logs

### Feature Request (`.github/ISSUE_TEMPLATE/feature_request.yml`)
Template for proposing new features with:
- Problem statement
- Proposed solution
- Alternatives considered
- Use case and examples
- Willingness to contribute

### Documentation (`.github/ISSUE_TEMPLATE/documentation.yml`)
For documentation improvements with:
- Documentation type
- What's unclear/missing
- Suggested improvements
- File/section location

## Pull Request Template

Located at `.github/PULL_REQUEST_TEMPLATE.md`, includes:
- Description and linked issues
- Type of change checkboxes
- Testing details and results
- Comprehensive checklist
- Space for screenshots and context

## Local Development

### Running CI Checks Locally

#### 1. Install development dependencies
```bash
pip install -e ".[dev]"
```

#### 2. Run unit tests
```bash
pytest tests/unit -v
```

#### 3. Run tests with coverage
```bash
pytest tests/unit --cov=src/agentflow --cov-report=term-missing
```

#### 4. Check code formatting
```bash
# Check formatting
black --check src/ tests/

# Auto-format
black src/ tests/
```

#### 5. Check import sorting
```bash
# Check imports
isort --check-only src/ tests/

# Auto-sort
isort src/ tests/
```

#### 6. Run linter
```bash
flake8 src/ tests/
```

#### 7. Run type checker
```bash
mypy src/agentflow --ignore-missing-imports
```

#### 8. Security scan
```bash
# Check dependencies
safety check

# Scan code
bandit -r src/
```

### Running All Checks
Create a pre-commit script or run:
```bash
pytest tests/unit && \
black --check src/ tests/ && \
isort --check-only src/ tests/ && \
flake8 src/ tests/ && \
mypy src/agentflow --ignore-missing-imports
```

## Configuration Files

### `setup.cfg`
Legacy configuration for:
- Flake8 settings
- Pytest markers
- Coverage exclusions

### `pyproject.toml`
Modern configuration for:
- Black (code formatting)
- isort (import sorting)
- mypy (type checking)
- pytest settings
- Coverage reporting

## Continuous Deployment

### Creating a Release

#### Automated (Recommended)
1. Create and push a version tag:
   ```bash
   git tag v0.2.0
   git push origin v0.2.0
   ```
2. GitHub Actions automatically:
   - Builds packages
   - Creates GitHub release
   - Uploads artifacts

#### Manual
1. Go to Actions → Release workflow
2. Click "Run workflow"
3. Enter version (e.g., `v0.2.0`)
4. Confirm

### Publishing to PyPI

Currently disabled. To enable:
1. Generate PyPI API token
2. Add as repository secret: `PYPI_API_TOKEN`
3. Uncomment PyPI publish step in `release.yml`

## Badge Integration

Add to README.md:
```markdown
[![CI](https://github.com/stancsz/AgentFlow/workflows/CI/badge.svg)](https://github.com/stancsz/AgentFlow/actions)
[![codecov](https://codecov.io/gh/stancsz/AgentFlow/branch/main/graph/badge.svg)](https://codecov.io/gh/stancsz/AgentFlow)
[![Python 3.10+](https://img.shields.io/badge/python-3.10+-blue.svg)](https://www.python.org/downloads/)
```

## Troubleshooting

### CI Failures

#### Test Failures
- Check the test matrix for which Python version/OS failed
- Run tests locally with that configuration
- Review test logs in GitHub Actions

#### Linting Failures (Non-blocking)
- Run `black src/ tests/` to auto-format
- Run `isort src/ tests/` to fix imports
- Address flake8 issues manually

#### Coverage Drop
- Check which files lack coverage
- Add tests for uncovered code
- Review coverage report in artifacts

#### Security Alerts
- Review Dependabot PRs
- Update vulnerable dependencies
- Check Bandit reports for code issues

### Common Issues

#### Import Errors in Tests
- Ensure package is installed: `pip install -e ".[dev]"`
- Check Python path and virtual environment

#### Mypy Errors
- Add type hints gradually
- Use `# type: ignore` for third-party issues
- Configure exclusions in `pyproject.toml`

#### Windows Path Issues
- Use `Path` objects from `pathlib`
- Avoid hardcoded path separators

## Future Improvements

- [ ] Add performance benchmarking
- [ ] Implement mutation testing
- [ ] Add security scanning for Docker images
- [ ] Create nightly builds for integration tests
- [ ] Add automated changelog generation
- [ ] Implement semantic versioning checks
- [ ] Add PR size limits and complexity checks

## Contributing to CI/CD

To improve the CI/CD pipeline:
1. Test changes in a fork first
2. Ensure backward compatibility
3. Update this documentation
4. Add comments in workflow files
5. Test with different scenarios (PR, push, tag)

## Resources

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [pytest Documentation](https://docs.pytest.org/)
- [Black Documentation](https://black.readthedocs.io/)
- [Codecov Documentation](https://docs.codecov.com/)
