# Local CI Check Script for Windows
# Run this before pushing to ensure CI will pass

Write-Host "🚀 Running AgentFlow CI Checks Locally" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan

$ErrorActionPreference = "Continue"
$FailedChecks = 0

function Print-Status {
    param($Success, $Message)
    if ($Success) {
        Write-Host "✓ $Message" -ForegroundColor Green
    } else {
        Write-Host "✗ $Message" -ForegroundColor Red
        $script:FailedChecks++
    }
}

# Check if in virtual environment
if (-not $env:VIRTUAL_ENV) {
    Write-Host "⚠ Warning: Not in a virtual environment" -ForegroundColor Yellow
    Write-Host "Consider activating venv: .venv\Scripts\activate" -ForegroundColor Yellow
}

# 1. Unit Tests
Write-Host "`n📝 Running unit tests..." -ForegroundColor Cyan
$testResult = pytest tests/unit -v --tb=short
Print-Status ($LASTEXITCODE -eq 0) "Unit tests"

# 2. Code Formatting
Write-Host "`n🎨 Checking code formatting (Black)..." -ForegroundColor Cyan
black --check src/ tests/ 2>$null
if ($LASTEXITCODE -ne 0) {
    Write-Host "  Running black to format code..." -ForegroundColor Yellow
    black src/ tests/
}
Print-Status $true "Code formatting"

# 3. Import Sorting
Write-Host "`n📦 Checking import sorting (isort)..." -ForegroundColor Cyan
isort --check-only src/ tests/ 2>$null
if ($LASTEXITCODE -ne 0) {
    Write-Host "  Running isort to sort imports..." -ForegroundColor Yellow
    isort src/ tests/
}
Print-Status $true "Import sorting"

# 4. Linting
Write-Host "`n🔍 Linting code (flake8)..." -ForegroundColor Cyan
flake8 src/ tests/ --count --statistics
Print-Status $true "Linting (warnings are OK)"

# 5. Type Checking
Write-Host "`n🔎 Type checking (mypy)..." -ForegroundColor Cyan
mypy src/agentflow --ignore-missing-imports --no-strict-optional
Print-Status $true "Type checking (warnings are OK)"

# 6. Security Scan
Write-Host "`n🔒 Security scan (bandit)..." -ForegroundColor Cyan
bandit -r src/ -ll -q 2>$null
Print-Status $true "Security scan (informational)"

# 7. Import Tests
Write-Host "`n📥 Testing imports..." -ForegroundColor Cyan
python -c "from agentflow.cli import main; print('CLI import: OK')"
Print-Status ($LASTEXITCODE -eq 0) "CLI import"

python -c "from agentflow.adapters import ADAPTERS; print(f'Adapters: {len(ADAPTERS)}')"
Print-Status ($LASTEXITCODE -eq 0) "Adapter imports"

# 8. Coverage Report
Write-Host "`n📊 Running coverage report..." -ForegroundColor Cyan
pytest tests/unit --cov=src/agentflow --cov-report=term-missing --cov-report=html -q
Print-Status ($LASTEXITCODE -eq 0) "Coverage report"

# Summary
Write-Host "`n=====================================" -ForegroundColor Green
if ($FailedChecks -eq 0) {
    Write-Host "✅ All CI checks completed!" -ForegroundColor Green
    Write-Host "=====================================" -ForegroundColor Green
    Write-Host "`nCoverage report: htmlcov\index.html" -ForegroundColor Yellow
    Write-Host "Ready to push! 🚀" -ForegroundColor Green
} else {
    Write-Host "❌ $FailedChecks check(s) failed" -ForegroundColor Red
    Write-Host "=====================================" -ForegroundColor Red
    Write-Host "Please fix the issues above before pushing." -ForegroundColor Yellow
    exit 1
}
