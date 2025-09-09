# GitHub Actions & CI/CD: YAML Workflows Guide

## Overview

GitHub Actions transforms your repository into a powerful automation platform. Think of it as your development orchestra conductor - coordinating builds, tests, and deployments seamlessly. This guide covers YAML syntax, workflow structure, and continuous integration implementation.

## Prerequisites

Before diving in, ensure you have:

- GitHub account with repository access
- Git installed locally
- Node.js and npm (for examples)
- Text editor (VS Code recommended)
- Basic understanding of version control
- Command line familiarity

## Understanding YAML for GitHub Actions

### What is YAML?

YAML (Yet Another Markup Language) is a human-readable data format used for configuration files. Key principles:

- **Indentation matters**: Use spaces, not tabs
- **Key-value pairs**: `key: value`
- **Lists**: Use hyphens (`-`)
- **Case-sensitive**: `Name` ≠ `name`

### Basic YAML Structure

```yaml
name: My Workflow
on: [push, pull_request]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Setup Node.js
        run: npm install
```

![YAML Structure Diagram Placeholder]

## Workflow Components Deep Dive

### 1. Workflow File Location

Store workflows in `.github/workflows/` directory:

```
repository-root/
├── .github/
│   └── workflows/
│       ├── ci.yml
│       └── deploy.yml
└── src/
```

### 2. Essential Components

#### Events (Triggers)

Define when workflows run:

```yaml
on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]
  schedule:
    - cron: "0 2 * * 1" # Every Monday at 2 AM
```

#### Jobs

Independent units of work:

```yaml
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      # Job steps here

  test:
    needs: build # Runs after build completes
    runs-on: ubuntu-latest
    steps:
      # Test steps here
```

#### Steps

Individual tasks within jobs:

```yaml
steps:
  - name: Checkout code
    uses: actions/checkout@v4

  - name: Custom command
    run: echo "Hello, World!"

  - name: Multi-line script
    run: |
      echo "Line 1"
      echo "Line 2"
```

![Workflow Components Diagram Placeholder]

## Building and Testing Code

### Complete CI Workflow Example

```yaml
name: CI Pipeline

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

env:
  NODE_VERSION: "18"

jobs:
  build-and-test:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout repository
        uses: actions/checkout@v4

      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: ${{ env.NODE_VERSION }}
          cache: "npm"

      - name: Install dependencies
        run: npm ci

      - name: Run linting
        run: npm run lint

      - name: Build application
        run: npm run build

      - name: Run tests
        run: npm test -- --coverage

      - name: Upload coverage reports
        uses: codecov/codecov-action@v3
        with:
          file: ./coverage/lcov.info
```

![CI Pipeline Flow Diagram Placeholder]

## Advanced YAML Features

### Environment Variables

Define at different levels:

```yaml
# Workflow level
env:
  GLOBAL_VAR: "global-value"

jobs:
  example:
    runs-on: ubuntu-latest
    # Job level
    env:
      JOB_VAR: "job-value"

    steps:
      - name: Print variables
        # Step level
        env:
          STEP_VAR: "step-value"
        run: |
          echo "Global: $GLOBAL_VAR"
          echo "Job: $JOB_VAR"
          echo "Step: $STEP_VAR"
```

### Working with Secrets

Store sensitive data securely:

```yaml
steps:
  - name: Deploy to production
    env:
      API_KEY: ${{ secrets.API_KEY }}
      DB_PASSWORD: ${{ secrets.DB_PASSWORD }}
    run: |
      echo "Deploying with API key"
      # Never echo secrets directly!
```

![Secrets Management Diagram Placeholder]

### Conditional Execution

Control when steps run:

```yaml
steps:
  - name: Deploy to staging
    if: github.ref == 'refs/heads/develop'
    run: npm run deploy:staging

  - name: Deploy to production
    if: github.ref == 'refs/heads/main' && github.event_name == 'push'
    run: npm run deploy:production
```

### Step Outputs and Inputs

Share data between steps:

````yaml# GitHub Actions & CI/CD: YAML Workflows Guide

## Overview

GitHub Actions transforms your repository into a powerful automation platform. Think of it as your development orchestra conductor - coordinating builds, tests, and deployments seamlessly. This guide covers YAML syntax, workflow structure, and continuous integration implementation.

## Prerequisites

Before diving in, ensure you have:

- GitHub account with repository access
- Git installed locally
- Node.js and npm (for examples)
- Text editor (VS Code recommended)
- Basic understanding of version control
- Command line familiarity

## Understanding YAML for GitHub Actions

### What is YAML?

YAML (Yet Another Markup Language) is a human-readable data format used for configuration files. Key principles:

- **Indentation matters**: Use spaces, not tabs
- **Key-value pairs**: `key: value`
- **Lists**: Use hyphens (`-`)
- **Case-sensitive**: `Name` ≠ `name`

### Basic YAML Structure

```yaml
name: My Workflow
on: [push, pull_request]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Setup Node.js
        run: npm install
````

![YAML Structure Diagram Placeholder]

## Workflow Components Deep Dive

### 1. Workflow File Location

Store workflows in `.github/workflows/` directory:

```
repository-root/
├── .github/
│   └── workflows/
│       ├── ci.yml
│       └── deploy.yml
└── src/
```

### 2. Essential Components

#### Events (Triggers)

Define when workflows run:

```yaml
on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]
  schedule:
    - cron: "0 2 * * 1" # Every Monday at 2 AM
```

#### Jobs

Independent units of work:

```yaml
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      # Job steps here

  test:
    needs: build # Runs after build completes
    runs-on: ubuntu-latest
    steps:
      # Test steps here
```

#### Steps

Individual tasks within jobs:

```yaml
steps:
  - name: Checkout code
    uses: actions/checkout@v4

  - name: Custom command
    run: echo "Hello, World!"

  - name: Multi-line script
    run: |
      echo "Line 1"
      echo "Line 2"
```

![Workflow Components Diagram Placeholder]

## Building and Testing Code

### Complete CI Workflow Example

```yaml
name: CI Pipeline

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

env:
  NODE_VERSION: "18"

jobs:
  build-and-test:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout repository
        uses: actions/checkout@v4

      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: ${{ env.NODE_VERSION }}
          cache: "npm"

      - name: Install dependencies
        run: npm ci

      - name: Run linting
        run: npm run lint

      - name: Build application
        run: npm run build

      - name: Run tests
        run: npm test -- --coverage

      - name: Upload coverage reports
        uses: codecov/codecov-action@v3
        with:
          file: ./coverage/lcov.info
```

![CI Pipeline Flow Diagram Placeholder]

## Advanced YAML Features

### Environment Variables

Define at different levels:

```yaml
# Workflow level
env:
  GLOBAL_VAR: "global-value"

jobs:
  example:
    runs-on: ubuntu-latest
    # Job level
    env:
      JOB_VAR: "job-value"

    steps:
      - name: Print variables
        # Step level
        env:
          STEP_VAR: "step-value"
        run: |
          echo "Global: $GLOBAL_VAR"
          echo "Job: $JOB_VAR"
          echo "Step: $STEP_VAR"
```

### Working with Secrets

Store sensitive data securely:

```yaml
steps:
  - name: Deploy to production
    env:
      API_KEY: ${{ secrets.API_KEY }}
      DB_PASSWORD: ${{ secrets.DB_PASSWORD }}
    run: |
      echo "Deploying with API key"
      # Never echo secrets directly!
```

![Secrets Management Diagram Placeholder]

### Conditional Execution

Control when steps run:

```yaml
steps:
  - name: Deploy to staging
    if: github.ref == 'refs/heads/develop'
    run: npm run deploy:staging

  - name: Deploy to production
    if: github.ref == 'refs/heads/main' && github.event_name == 'push'
    run: npm run deploy:production
```

### Step Outputs and Inputs

Share data between steps:

```yaml
jobs:
  build:
    runs-on: ubuntu-latest
    outputs:
      build-version: ${{ steps.version.outputs.version }}

    steps:
      - name: Get version
        id: version
        run: |
          VERSION=$(node -p "require('./package.json').version")
          echo "version=$VERSION" >> $GITHUB_OUTPUT

      - name: Use version
        run: echo "Building version ${{ steps.version.outputs.version }}"
```

## Build Matrices

Run jobs across multiple configurations:

```yaml
jobs:
  test:
    runs-on: ${{ matrix.os }}
    strategy:
      matrix:
        os: [ubuntu-latest, windows-latest, macos-latest]
        node-version: [16, 18, 20]
        include:
          - os: ubuntu-latest
            node-version: 18
            experimental: true
        exclude:
          - os: windows-latest
            node-version: 16

    steps:
      - uses: actions/checkout@v4
      - name: Setup Node.js ${{ matrix.node-version }}
        uses: actions/setup-node@v3
        with:
          node-version: ${{ matrix.node-version }}
      - run: npm test
```

![Matrix Build Diagram Placeholder]

## Common Troubleshooting

### Issue: YAML Syntax Errors

**Problem**: Workflow fails with "Invalid workflow file"

**Solutions**:

- Check indentation (use spaces, not tabs)
- Validate YAML syntax online
- Ensure proper quotes around special characters
- Verify file encoding is UTF-8

```yaml
# ❌ Wrong (mixed indentation)
jobs:
	build:
    runs-on: ubuntu-latest

# ✅ Correct (consistent spaces)
jobs:
  build:
    runs-on: ubuntu-latest
```

### Issue: Action Not Found

**Problem**: `Error: Could not find action 'actions/checkout@v5'`

**Solutions**:

- Use existing action versions: `actions/checkout@v4`
- Check action marketplace for correct syntax
- Verify internet connectivity for public actions

### Issue: Permission Denied

**Problem**: `Error: EACCES: permission denied`

**Solutions**:

```yaml
- name: Make script executable
  run: chmod +x ./scripts/deploy.sh

- name: Run with sudo (if needed)
  run: sudo ./scripts/setup.sh
```

### Issue: Environment Variables Not Working

**Problem**: Variables appear as empty strings

**Solutions**:

```yaml
# ❌ Wrong syntax
run: echo ${{env.MY_VAR}}

# ✅ Correct syntax
run: echo ${{ env.MY_VAR }}

# ✅ Alternative for shell
run: echo "$MY_VAR"
env:
  MY_VAR: ${{ env.MY_VAR }}
```

### Issue: Matrix Job Failures

**Problem**: One matrix configuration fails, stopping others

**Solutions**:

```yaml
strategy:
  fail-fast: false # Continue other jobs even if one fails
  matrix:
    node-version: [16, 18, 20]
```

### Issue: Secrets Not Available

**Problem**: `Error: Secret [SECRET_NAME] not found`

**Solutions**:

1. Verify secret exists in repository settings
2. Check secret name spelling (case-sensitive)
3. Ensure proper repository permissions
4. Use correct context: `${{ secrets.SECRET_NAME }}`

## Best Practices

### 1. Security

- Never log secrets or sensitive data
- Use least privilege principle for tokens
- Regularly rotate secrets and tokens

### 2. Performance

- Use caching for dependencies
- Optimize Docker layers if using containers
- Consider job parallelization

### 3. Maintenance

- Pin action versions for stability
- Use meaningful step names
- Add comments for complex logic
- Keep workflows DRY (Don't Repeat Yourself)

### 4. Testing

- Test workflows in feature branches
- Use workflow_dispatch for manual testing
- Validate with different event triggers

## Example: Complete Node.js CI/CD Workflow

```yaml
name: Node.js CI/CD Pipeline

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

env:
  NODE_VERSION: "18"
  REGISTRY: ghcr.io
  IMAGE_NAME: ${{ github.repository }}

jobs:
  test:
    runs-on: ubuntu-latest

    strategy:
      matrix:
        node-version: [16, 18, 20]

    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Setup Node.js ${{ matrix.node-version }}
        uses: actions/setup-node@v3
        with:
          node-version: ${{ matrix.node-version }}
          cache: "npm"

      - name: Install dependencies
        run: npm ci

      - name: Run tests
        run: npm test

  build-and-deploy:
    needs: test
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'

    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: ${{ env.NODE_VERSION }}
          cache: "npm"

      - name: Install dependencies
        run: npm ci

      - name: Build application
        run: npm run build

      - name: Deploy to production
        env:
          DEPLOY_TOKEN: ${{ secrets.DEPLOY_TOKEN }}
        run: |
          echo "Deploying to production..."
          npm run deploy
```

![Complete CI/CD Pipeline Diagram Placeholder]

## Quick Reference

### Essential Actions

- `actions/checkout@v4` - Check out repository
- `actions/setup-node@v3` - Setup Node.js
- `actions/cache@v3` - Cache dependencies
- `actions/upload-artifact@v3` - Store build artifacts

### Context Variables

- `${{ github.repository }}` - Repository name
- `${{ github.ref }}` - Branch/tag reference
- `${{ github.sha }}` - Commit SHA
- `${{ runner.os }}` - Runner operating system

### Common Event Filters

```yaml
on:
  push:
    branches: [main]
    paths: ["src/**"]
    tags: ["v*"]
  schedule:
    - cron: "0 0 * * 0" # Weekly
```

## Next Steps

Now that you understand GitHub Actions fundamentals:

1. What specific workflow challenges are you facing in your current projects?
2. Which CI/CD practices would benefit your team most?
3. How might you adapt these examples to your technology stack?

Practice by creating a simple workflow in your repository, then gradually add complexity as you become more comfortable with the concepts.
jobs:
build:
runs-on: ubuntu-latest
outputs:
build-version: ${{ steps.version.outputs.version }}

    steps:
    - name: Get version
      id: version
      run: |
        VERSION=$(node -p "require('./package.json').version")
        echo "version=$VERSION" >> $GITHUB_OUTPUT

    - name: Use version
      run: echo "Building version ${{ steps.version.outputs.version }}"

````

## Build Matrices

Run jobs across multiple configurations:

```yaml
jobs:
  test:
    runs-on: ${{ matrix.os }}
    strategy:
      matrix:
        os: [ubuntu-latest, windows-latest, macos-latest]
        node-version: [16, 18, 20]
        include:
          - os: ubuntu-latest
            node-version: 18
            experimental: true
        exclude:
          - os: windows-latest
            node-version: 16

    steps:
    - uses: actions/checkout@v4
    - name: Setup Node.js ${{ matrix.node-version }}
      uses: actions/setup-node@v3
      with:
        node-version: ${{ matrix.node-version }}
    - run: npm test
````

![Matrix Build Diagram Placeholder]

## Common Troubleshooting

### Issue: YAML Syntax Errors

**Problem**: Workflow fails with "Invalid workflow file"

**Solutions**:

- Check indentation (use spaces, not tabs)
- Validate YAML syntax online
- Ensure proper quotes around special characters
- Verify file encoding is UTF-8

```yaml
# ❌ Wrong (mixed indentation)
jobs:
	build:
    runs-on: ubuntu-latest

# ✅ Correct (consistent spaces)
jobs:
  build:
    runs-on: ubuntu-latest
```

### Issue: Action Not Found

**Problem**: `Error: Could not find action 'actions/checkout@v5'`

**Solutions**:

- Use existing action versions: `actions/checkout@v4`
- Check action marketplace for correct syntax
- Verify internet connectivity for public actions

### Issue: Permission Denied

**Problem**: `Error: EACCES: permission denied`

**Solutions**:

```yaml
- name: Make script executable
  run: chmod +x ./scripts/deploy.sh

- name: Run with sudo (if needed)
  run: sudo ./scripts/setup.sh
```

### Issue: Environment Variables Not Working

**Problem**: Variables appear as empty strings

**Solutions**:

```yaml
# ❌ Wrong syntax
run: echo ${{env.MY_VAR}}

# ✅ Correct syntax
run: echo ${{ env.MY_VAR }}

# ✅ Alternative for shell
run: echo "$MY_VAR"
env:
  MY_VAR: ${{ env.MY_VAR }}
```

### Issue: Matrix Job Failures

**Problem**: One matrix configuration fails, stopping others

**Solutions**:

```yaml
strategy:
  fail-fast: false # Continue other jobs even if one fails
  matrix:
    node-version: [16, 18, 20]
```

### Issue: Secrets Not Available

**Problem**: `Error: Secret [SECRET_NAME] not found`

**Solutions**:

1. Verify secret exists in repository settings
2. Check secret name spelling (case-sensitive)
3. Ensure proper repository permissions
4. Use correct context: `${{ secrets.SECRET_NAME }}`

## Best Practices

### 1. Security

- Never log secrets or sensitive data
- Use least privilege principle for tokens
- Regularly rotate secrets and tokens

### 2. Performance

- Use caching for dependencies
- Optimize Docker layers if using containers
- Consider job parallelization

### 3. Maintenance

- Pin action versions for stability
- Use meaningful step names
- Add comments for complex logic
- Keep workflows DRY (Don't Repeat Yourself)

### 4. Testing

- Test workflows in feature branches
- Use workflow_dispatch for manual testing
- Validate with different event triggers

## Example: Complete Node.js CI/CD Workflow

```yaml
name: Node.js CI/CD Pipeline

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

env:
  NODE_VERSION: "18"
  REGISTRY: ghcr.io
  IMAGE_NAME: ${{ github.repository }}

jobs:
  test:
    runs-on: ubuntu-latest

    strategy:
      matrix:
        node-version: [16, 18, 20]

    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Setup Node.js ${{ matrix.node-version }}
        uses: actions/setup-node@v3
        with:
          node-version: ${{ matrix.node-version }}
          cache: "npm"

      - name: Install dependencies
        run: npm ci

      - name: Run tests
        run: npm test

  build-and-deploy:
    needs: test
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'

    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: ${{ env.NODE_VERSION }}
          cache: "npm"

      - name: Install dependencies
        run: npm ci

      - name: Build application
        run: npm run build

      - name: Deploy to production
        env:
          DEPLOY_TOKEN: ${{ secrets.DEPLOY_TOKEN }}
        run: |
          echo "Deploying to production..."
          npm run deploy
```

![Complete CI/CD Pipeline Diagram Placeholder]

## Quick Reference

### Essential Actions

- `actions/checkout@v4` - Check out repository
- `actions/setup-node@v3` - Setup Node.js
- `actions/cache@v3` - Cache dependencies
- `actions/upload-artifact@v3` - Store build artifacts

### Context Variables

- `${{ github.repository }}` - Repository name
- `${{ github.ref }}` - Branch/tag reference
- `${{ github.sha }}` - Commit SHA
- `${{ runner.os }}` - Runner operating system

### Common Event Filters

```yaml
on:
  push:
    branches: [main]
    paths: ["src/**"]
    tags: ["v*"]
  schedule:
    - cron: "0 0 * * 0" # Weekly
```

## Next Steps

Now that you understand GitHub Actions fundamentals:

1. What specific workflow challenges are you facing in your current projects?
2. Which CI/CD practices would benefit your team most?
3. How might you adapt these examples to your technology stack?

Practice by creating a simple workflow in your repository, then gradually add complexity as you become more comfortable with the concepts.
