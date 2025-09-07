# CI/CD & GitHub Actions Quick Note

## Core Concepts

- **Continuous Integration (CI):** The practice of frequently merging developer code changes into a central repository, where automated builds and tests are run.
- **Continuous Deployment (CD):** The automated process of releasing software changes to production.
- **Benefits:** Faster release cycles, improved code quality, and increased developer productivity.

## GitHub Actions

- A CI/CD platform integrated directly into GitHub.
- Workflows are defined in YAML files located in the `.github/workflows` directory of your repository.

### Key Components

| Component    | Description                                                                  |
| :----------- | :--------------------------------------------------------------------------- |
| **Workflow** | An automated process composed of one or more jobs.                           |
| **Event**    | A specific activity that triggers a workflow (e.g., `push`, `pull_request`). |
| **Job**      | A set of steps that execute on the same runner.                              |
| **Step**     | An individual task that can run commands or actions.                         |
| **Action**   | A reusable piece of code that performs a complex task.                       |
| **Runner**   | A server that executes your workflows.                                       |

## Example Node.js Workflow

This workflow builds and tests a Node.js application on pushes and pull requests to the `main` branch.

- **File:** `.github/workflows/nodejs.yml`

```yaml
name: Node.js CI

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  build:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        node-version: [14.x, 16.x]
    steps:
      - uses: actions/checkout@v2
      - name: Use Node.js ${{ matrix.node-version }}
        uses: actions/setup-node@v1
        with:
          node-version: ${{ matrix.node-version }}
      - run: npm ci
      - run: npm run build --if-present
      - run: npm test
```

Explanation:
name: This simply names your workflow. It's what appears on GitHub when the workflow is running.

on: This section defines when the workflow is triggered. Here, it's set to activate on push and pull request events to the main branch.

jobs: Jobs are a set of steps that execute on the same runner. In this example, there's one job named build.

runs-on: Defines the type of machine to run the job on. Here, it's using the latest Ubuntu virtual machine.

strategy.matrix: This allows you to run the job on multiple versions of Node.js, ensuring compatibility.

steps: A sequence of tasks executed as part of the job.

actions/checkout@v2: Checks out your repository under $GITHUB_WORKSPACE.
actions/setup-node@v1: Sets up the Node.js environment.
npm ci: Installs dependencies defined in package-lock.json.
npm run build --if-present: Runs the build script from package.json if it's present.
npm test: Runs tests specified in package.json.
This workflow is a basic example for a Node.js project, demonstrating how to automate testing across different Node.js versions and ensuring that your code integrates and works as expected in a clean environment.
