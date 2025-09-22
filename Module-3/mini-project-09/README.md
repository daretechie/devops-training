# GitHub Actions CI/CD Demo

This repository, [daretechie/github-actions-cicd-demo](https://github.com/daretechie/github-actions-cicd-demo), demonstrates a complete Continuous Integration and Continuous Deployment (CI/CD) pipeline using GitHub Actions.

## Overview

The CI/CD pipeline is defined in the `.github/workflows/cicd.yml` file and consists of several jobs that are triggered on push and pull requests to the `main` and `develop` branches. The pipeline automates the testing, code quality analysis, security scanning, building, and deployment of a Node.js application.

## CI/CD Pipeline Breakdown

The pipeline is composed of the following jobs:

### 1. `test`

- **Purpose:** Runs unit tests and code coverage reports.
- **Details:** This job uses a build matrix to test the application against multiple versions of Node.js (18.x and 20.x). It also caches npm dependencies to speed up the build process.

### 2. `code-quality`

- **Purpose:** Performs static code analysis to ensure code quality.
- **Details:** This job uses ESLint to lint the codebase and uploads the results to GitHub Code Scanning as a SARIF file.

### 3. `security`

- **Purpose:** Scans the project for vulnerabilities.
- **Details:** This job uses Trivy to scan the filesystem for vulnerabilities and uploads the results to GitHub Code Scanning as a SARIF file.

### 4. `build`

- **Purpose:** Builds and packages the application into a Docker image.
- **Details:** This job builds a Docker image, tags it with the branch name and commit SHA, and pushes it to the GitHub Container Registry (ghcr.io).

### 5. `deploy-staging`

- **Purpose:** Deploys the application to a staging environment.
- **Details:** This is a simulated deployment to a staging environment for further testing.

### 6. `integration-tests`

- **Purpose:** Runs integration tests against the staging environment.
- **Details:** This job simulates running integration tests against the deployed application in the staging environment.

### 7. `deploy-production`

- **Purpose:** Deploys the application to a production environment.
- **Details:** This is a simulated deployment to a production environment.

### 8. `smoke-tests`

- **Purpose:** Runs smoke tests against the production environment.
- **Details:** This job simulates running smoke tests to verify the production deployment.

### 9. `notify`

- **Purpose:** Sends a notification about the deployment status.
- **Details:** This job sends a success or failure notification based on the outcome of the previous jobs.

## Troubleshooting

During the setup of this CI/CD pipeline, several issues were encountered and resolved:

### 1. SARIF Upload Failure

- **Error:** `Error: Resource not accessible by integration`
- **Cause:** The workflow lacked the necessary permissions to upload SARIF files to GitHub Code Scanning.
- **Resolution:** Added the `security-events: write` permission to the `security` job in the `.github/workflows/cicd.yml` file.

```yaml
permissions:
  security-events: write
  actions: read
  contents: read
```

### 2. Docker Cache Export Failure

- **Error:** `ERROR: failed to build: Cache export is not supported for the docker driver.`
- **Cause:** The default Docker driver in GitHub Actions does not support cache export.
- **Resolution:** Added the `docker/setup-buildx-action@v3` step to the `build` job to set up a different buildx driver that supports cache export.

```yaml
- name: Set up Docker Buildx
  uses: docker/setup-buildx-action@v3
```

### 3. Docker Image Push Failure

- **Error:** `denied: installation not allowed to Create organization package`
- **Cause:** The `GITHUB_TOKEN` did not have the necessary permissions to create packages (container images) in the GitHub Container Registry.
- **Resolution:** Added the `packages: write` permission to the `build` job in the `.github/workflows/cicd.yml` file.

```yaml
permissions:
  contents: read
  packages: write
```

## Evidence of Successful Workflow

To verify that the pipeline is running successfully, navigate to the "Actions" tab in your GitHub repository. You should see a list of workflow runs. A successful run will have a green checkmark next to it.

You can click on a workflow run to see the details of each job.

**Screenshot of a successful workflow run:**

![Successful Workflow Run](placeholder-for-successful-run-image.png)

**Screenshot of the `build` job details:**

![Build Job Details](placeholder-for-build-job-image.png)

**Screenshot of the security scan results:**

![Security Scan Results](placeholder-for-security-scan-image.png)
