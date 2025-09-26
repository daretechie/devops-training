# Project Submission Guide: Advanced GitHub Actions CI/CD (EC2 Pipeline)

This document describes exactly what to implement, what to capture as evidence (screenshots/logs), and how to troubleshoot. Submit this file along with the requested artifacts for grading. Repository reference: [advanced-actions-demo](https://github.com/daretechie/advanced-actions-demo).

## What you will deliver

- Functional CI pipeline with matrix builds and caching
- Reusable workflow for lint/test
- Secure deploy workflow targeting an EC2-based environment (or placeholder with clear OIDC/secret usage)
- Evidence artifacts (screenshots/logs) listed below

## Prerequisites

- GitHub repository: [advanced-actions-demo](https://github.com/daretechie/advanced-actions-demo)
- AWS account with permissions to create IAM roles and an EC2 instance
- Recommended: OIDC-based authentication from GitHub to AWS (no long-lived secrets)

## Implementation Steps

1. Fork or clone the repository

   - Confirm workflows exist in `.github/workflows/`:
     - `build.yml` (matrix build)
     - `reusable-lint-test.yml` (workflow_call)
     - `deploy.yml` (manual dispatch; least-privilege; secrets/OIDC ready)

2. Local validation (optional but recommended)

   - Install and run:
     - `npm ci || npm install`
     - `npm test`
     - `npm run lint`

3. Push a feature branch and open a Pull Request

   - Verify the Build workflow runs for the PR
   - Confirm parallel jobs for Node 18 and 20, with caching enabled

4. Configure deployment to EC2 (preferred: OIDC)

   - Create an IAM role with a trust policy for GitHub OIDC
     - Audience: `sts.amazonaws.com`
     - Condition restricts `repository` to `daretechie/advanced-actions-demo` and relevant `ref`
   - Grant least-privilege permissions to deploy (e.g., `ec2:Describe*`, `ssm:SendCommand`, `s3:GetObject` as needed)
   - In `deploy.yml`, enable OIDC:
     - Add `permissions: id-token: write` and keep `contents: read`
     - Use `aws-actions/configure-aws-credentials` with role-to-assume
   - Provision an EC2 instance with access path for your deployment mechanism (e.g., SSM Session Manager, user data, or SSH via ephemeral key)

5. Parameterize environments

   - Use `workflow_dispatch` inputs (already scaffolded) to choose `preview`, `staging`, or `prod`
   - Optionally configure GitHub Environments with protection rules and required reviewers

6. Wire the actual deployment step

   - Example strategies:
     - SSM Run Command invoking an install/update script on EC2
     - SCP/rsync build artifacts to EC2, then systemd restart
     - Pull from artifact storage (S3/CodeArtifact) in a bootstrapped script
   - Replace the placeholder "Deploy" step in `deploy.yml` with real commands

7. Run the deployment
   - Trigger `Deploy (Placeholder)` from the Actions tab (or renamed deploy workflow)
   - Select the environment (e.g., `preview`) and run

## Evidence to capture and submit

Place images in `docs/images/` and reference them below.

- CI Pipeline

  - Screenshot of Actions run overview for a PR showing matrix jobs
  - Screenshot of a job log where dependencies were restored from cache
  - Snippet of `build.yml` and `reusable-lint-test.yml` in the repo

- Security

  - Screenshot of `permissions:` usage in `deploy.yml`
  - If using OIDC: screenshot of IAM role trust relationship and `configure-aws-credentials` step logs showing role assumption
  - If using secrets: screenshot of repository/environment secrets list (values redacted)

- Deployment
  - Screenshot of manual `workflow_dispatch` input form and a successful run
  - Screenshot or log excerpt from the deploy step indicating success (e.g., service restarted, version shown)
  - EC2 instance screenshot (instance details) relevant to the deployment

## Troubleshooting Guide

- Workflows not triggering

  - Ensure you pushed to `main` or opened a PR targeting `main`
  - Confirm `.github/workflows/` file names and `on:` triggers

- Cache not restoring

  - For npm, ensure lockfile exists and the cache key matches (`setup-node` with `cache: npm` handles this)
  - Verify identical Node version and OS for cache hits

- OIDC role assumption failing

  - Check `permissions: id-token: write` in the workflow
  - Validate IAM trust policy conditions match your repository and branch/ref
  - Ensure the `aws-actions/configure-aws-credentials` action references the correct `role-to-assume` and AWS Region

- EC2 connectivity or command failures

  - Prefer SSM over SSH; ensure the instance has SSM agent and appropriate IAM instance profile
  - Validate network access for pulling artifacts or hitting registries

- Least privilege errors
  - Inspect error messages for missing actions (e.g., `ssm:SendCommand`)
  - Add only the minimal additional permissions required

## Grading Checklist (self-check)

- Build pipeline

  - Descriptive names, modular reusable workflow, matrix strategy, caching enabled
  - PR run shows parallel jobs across Node 18 and 20

- Security

  - `permissions:` defined with least privilege
  - Either OIDC assumed-role or properly scoped secrets

- Deployment

  - Manual dispatch with environment input
  - Evidence of a successful run (logs/screenshots)

- Documentation
  - This `SUBMISSION.md` completed with referenced screenshots in `docs/images/`
  - Repository linked: [advanced-actions-demo](https://github.com/daretechie/advanced-actions-demo)

## Where to put artifacts

- Create the directory: `docs/images/`
- Name files descriptively, e.g.:
  - `ci-matrix-run.png`
  - `cache-hit.png`
  - `deploy-dispatch.png`
  - `oidc-trust-policy.png`
  - `ec2-instance-details.png`
