# Project Submission Guide: GitHub Actions EC2 Pipeline

Repository: `https://github.com/daretechie/github-actions-ec2-pipeline`

This document provides step-by-step instructions, evidence checklist, and troubleshooting guidance to help reviewers verify the CI/CD pipeline, cloud deployment, monitoring, and release automation for grading.

## 1) Overview

- App: Node.js/Express API with static frontend
- CI: Test + automated version tagging on `main`
- CD: Tag-triggered multi-stage deploy to AWS EC2 (staging → approval → production)
- Process manager: PM2 with zero-downtime swap via `current` symlink, rollback, and health checks
- Monitoring: Scheduled health-check workflow that creates a GitHub issue on failures

## 2) Prerequisites

- GitHub repository access and Actions enabled
- Two EC2 instances (recommended): staging and production
  - Or a single instance with only the production job enabled
- Repo secrets set:
  - `DEV_EC2_HOST`, `DEV_EC2_USER`, `DEV_EC2_KEY`
  - `PROD_EC2_HOST`, `PROD_EC2_USER`, `PROD_EC2_KEY`
  - `REPO_ACCESS_TOKEN` (classic PAT, repo scope) for tag pushes in CI
- GitHub Environments created: `staging`, `production` (with approval rules if desired)

## 3) Architecture

- Workflows
  - `.github/workflows/ci.yml`: CI on push branches; runs tests; bumps SemVer patch and pushes `v*` tag on `main`
  - `.github/workflows/release.yml`: On `v*` tag → package → deploy-staging (environment: staging) → deploy-production (environment: production) → create release
  - `.github/workflows/health-check.yml`: Every 5 minutes and manual; checks `/api/health` for DEV/PROD URLs; opens issue on failures
- Deploy
  - Artifact is uploaded once and reused for staging and production
  - `scripts/deploy.sh`: creates timestamped release dir, updates `current` symlink, starts/refreshes PM2, health-check and rollback, cleans old releases

## 4) EC2 Preparation (one-time)

On each instance (replace USER/IP):

```bash
ssh -i <key.pem> ubuntu@<EC2_IP>
sudo apt update && sudo apt upgrade -y
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install -y nodejs
sudo npm install -g pm2
sudo apt install nginx -y # optional reverse proxy
sudo mkdir -p /var/www/app /var/www/backup
sudo chown -R $USER:$USER /var/www/app /var/www/backup
```

## 5) Secrets and Settings

- Repository → Settings → Secrets and variables → Actions → New repository secret
  - Add `DEV_*` and `PROD_*` secrets (host, user, private key)
  - Add `REPO_ACCESS_TOKEN` (classic PAT, repo scope)
- Repository → Settings → Actions → General → Workflow permissions → Read and write permissions
- Settings → Environments: add `staging` and `production` and optional required reviewers for approvals

## 6) Running the Pipeline

1. Push changes to a feature branch → CI runs (tests only)
2. Merge to `main` → CI runs, then bumps tag `vX.Y.Z` using PAT
3. Tag push triggers `release.yml`:
   - `package`: build tarball and upload artifact
   - `deploy-staging`: download artifact, deploy over SSH to staging EC2, health-check passes
   - `deploy-production`: waits for environment approval in Actions UI; on approval deploys to production EC2
   - `create-release`: creates GitHub Release named after the tag

## 7) Verification Steps (what to capture for evidence)

Capture screenshots and attach to your submission (use a folder like `submission_images/`):

- CI run on `main` showing tests and tag creation
- Tags view showing `vX.Y.Z`
- Actions run for `Release and Deploy` showing stages `package`, `deploy-staging`, approval gate, `deploy-production`, and `create-release`
- Release page showing the created release for the tag
- PM2 status on EC2 after deployment
  - `pm2 status`
- Health endpoint responses
  - `curl http://<STAGING_IP>:3000/api/health`
  - `curl http://<PROD_IP>:3000/api/health`
- Health-check workflow run creating an issue when an environment is down (optional test)

## 8) Accessing the Application

- Direct: `http://<EC2_IP>:3000/` and `http://<EC2_IP>:3000/api/health`
- Optional Nginx reverse proxy (HTTP only) example is included in root `README.md`

## 9) Troubleshooting

- Release workflow didn’t start after CI:
  - Ensure CI uses `REPO_ACCESS_TOKEN` in bump job; confirm PAT has `repo` scope
- Create release failed with 403:
  - Ensure `create-release` job has `permissions: contents: write` and repo workflow permissions are set to Read and write
- Health-check workflow cannot create issues:
  - Ensure job `permissions: issues: write` and repo workflow permissions are Read and write
- PM2 reload points to old path:
  - Script uses `current/src/server.js`. If you previously used absolute timestamp path, delete and restart PM2 with `pm2 start /var/www/app/current/src/server.js --name app`
- Health check 404:
  - Endpoint is `/api/health` (not `/health`)
- Node/npm errors on EC2:
  - Confirm Node 20.x installed via Nodesource, rerun `npm ci --omit=dev`
- SSH failures:
  - Verify user, host, and private key formatting in secrets; ensure port 22 open; set perms `chmod 600` on key file when testing locally

## 10) Security Notes

- Use repository secrets; avoid committing credentials
- Limit inbound rules to required ports (22/80/443/3000 as needed)
- Consider rotating keys and using AWS SSM or Systems Manager for access

## 11) Mapping to Course Outcomes

- CI fundamentals: tests on push, caching, Node 20
- Automated versioning and tagging: SemVer patch via action
- Tag-based releases: automated GitHub Releases
- Cloud deployment: staged EC2 deploy via GitHub Actions over SSH
- Zero-downtime and rollback: PM2 + symlink strategy + health checks
- Monitoring: scheduled health-check workflow creating issues
- Documentation: README with setup, troubleshooting, and evidence checklist

## 12) Repository Reference

- Project repo: `https://github.com/daretechie/github-actions-ec2-pipeline`

## 13) Evidence Screenshots

Here are the screenshots as evidence of project completion.

**1. CI run on `main` showing tests and tag creation**
![CI run on main](submission_images/ci-main-success.png)

**2. Tags view showing `vX.Y.Z`**
![Tags view](submission_images/tag-created.png)

**3. Actions run for `Release and Deploy`**
![Release and Deploy stages](submission_images/release-workflow-stages.png)

**4. Release page showing the created release**
![Release page](submission_images/release-page.png)

**5. PM2 status on EC2 after deployment**
![PM2 status on production EC2](submission_images/pm2-status-prod.png)

**6. Health endpoint responses (Staging)**
![Health endpoint on staging](submission_images/health-staging.png)

**7. Health endpoint responses (Production)**
![Health endpoint on production](submission_images/health-prod.png)

**8. Health-check workflow run creating an issue**
![Health-check issue creation](submission_images/health-check-issue.png)
