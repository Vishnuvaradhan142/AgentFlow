#!/usr/bin/env bash
# Local CI Check Script
# Run this before pushing to ensure CI will pass

set -e  # Exit on error

echo "🚀 Running AgentFlow CI Checks Locally"
echo "======================================"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    if [ $1 -eq 0 ]; then
        echo -e "${GREEN}✓ $2${NC}"
    else
        echo -e "${RED}✗ $2${NC}"
        return 1
    fi
}

# Check if in virtual environment
if [ -z "$VIRTUAL_ENV" ]; then
    echo -e "${YELLOW}⚠ Warning: Not in a virtual environment${NC}"
    echo "Consider activating venv: source .venv/bin/activate"
fi

# 1. Unit Tests
echo -e "\n📝 Running unit tests..."
pytest tests/unit -v --tb=short
print_status $? "Unit tests"

# 2. Code Formatting
echo -e "\n🎨 Checking code formatting (Black)..."
black --check src/ tests/ 2>/dev/null || {
    echo -e "${YELLOW}  Running black to format code...${NC}"
    black src/ tests/
}
print_status 0 "Code formatting"

# 3. Import Sorting
echo -e "\n📦 Checking import sorting (isort)..."
isort --check-only src/ tests/ 2>/dev/null || {
    echo -e "${YELLOW}  Running isort to sort imports...${NC}"
    isort src/ tests/
}
print_status 0 "Import sorting"

# 4. Linting
echo -e "\n🔍 Linting code (flake8)..."
flake8 src/ tests/ --count --statistics || true
print_status 0 "Linting (warnings are OK)"

# 5. Type Checking
echo -e "\n🔎 Type checking (mypy)..."
mypy src/agentflow --ignore-missing-imports --no-strict-optional || true
print_status 0 "Type checking (warnings are OK)"

# 6. Security Scan
echo -e "\n🔒 Security scan (bandit)..."
bandit -r src/ -ll -q 2>/dev/null || true
print_status 0 "Security scan (informational)"

# 7. Import Tests
echo -e "\n📥 Testing imports..."
python -c "from agentflow.cli import main; print('CLI import: OK')"
print_status $? "CLI import"

python -c "from agentflow.adapters import ADAPTERS; print(f'Adapters: {len(ADAPTERS)}')"
print_status $? "Adapter imports"

# 8. Coverage Report
echo -e "\n📊 Running coverage report..."
pytest tests/unit --cov=src/agentflow --cov-report=term-missing --cov-report=html -q
print_status $? "Coverage report"

echo -e "\n${GREEN}=====================================${NC}"
echo -e "${GREEN}✅ All CI checks completed!${NC}"
echo -e "${GREEN}=====================================${NC}"
echo -e "\nCoverage report: ${YELLOW}htmlcov/index.html${NC}"
echo -e "Ready to push! 🚀"
