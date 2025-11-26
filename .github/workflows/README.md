## CI/CD Pipeline Explanation (GitHub Actions)

This project uses a 2-stage CI/CD pipeline implemented using GitHub Actions.

This pipeline ensures that our code is validated, built, containerized, and deployed automatically to the AKS cluster whenever changes are pushed to the main branch.

## 🚀 Pipeline Overview

## The pipeline consists of two jobs:

## 🟦 Job 1 — CI (Continuous Integration)

 Triggered on:

 Pull Requests to main

 Pushes to main

## Purpose:

Validate infrastructure code, verify container builds, and lint Kubernetes manifests before deployment.

## CI Stages:

### 1. Terraform Validation

Ensures infrastructure code is formatted and valid:

 terraform fmt -check

 terraform init -backend=false

 terraform validate

✔ Avoids applying broken Terraform code to cloud.

### 2. Docker Build Test

Builds backend & frontend images locally in GitHub runner:

 docker build ./app/backend

 docker build ./app/frontend

 ✔ Ensures Dockerfiles contain no syntax errors

 ✔ Confirms application builds successfully

### 3. Kubernetes YAML Linting

 Uses kubeval to validate manifests:

 kubeval --strict

 ✔ Catches schema errors early

 ✔ Ensures manifests are compatible with K8s API

### 4. Upload CI Artifacts

 Terraform & K8s files are uploaded for debugging:

 actions/upload-artifact

 ✔ Helps reviewers inspect configurations

## 📌 Result:

 If CI passes → code is considered safe to deploy

 If CI fails → deployment is blocked

## 🟩 Job 2 — CD (Continuous Deployment)

 Triggered only when:

 Code is pushed to main

 CI job finishes successfully

## Purpose:

Build Docker images → push to Docker Hub → deploy to AKS.

### 1. Azure Authentication

GitHub Actions logs into Azure using a Service Principal stored in secrets:

azure/login@v2

 ✔ Secure

 ✔ Automated

 ✔ No manual login required

 2. Set Kubernetes Context

 Connects kubectl to AKS:

azure/aks-set-context@v4

✔ All kubectl commands now target your AKS cluster.

### 3. Terraform Plan

 Runs in “read-only” mode:

 terraform init

 terraform plan

 ✔ Ensures infra drift is visible

 ✔ Assures infra did not accidentally change


### 4. Build & Push Docker Images

Both images are built and pushed to Docker Hub with unique Git SHA tags:

 docker build

 docker push

 ✔ Ensures reproducible deployments

 ✔ Every commit creates a new image version

### 5. Kubernetes Deployment

 Applies your application manifests:

 kubectl apply -R -f k8s/app

 ✔ Deploys backend

 ✔ Deploys frontend

 ✔ Deploys ingress

(I intentionally excluded monitoring manifests to avoid CRD errors.)

### 6. Update Deployments with New Image Tags

 Automated rolling updates:

kubectl set image deployment/backend backend=<sha>

kubectl set image deployment/frontend frontend=<sha>

 ✔ Zero-downtime rollouts

 ✔ Ensures new version is deployed cleanly

### 7. Rollout Verification

 Checks that pods become ready:

 kubectl rollout status

 ✔ Detects failed deployments

 ✔ Automatically stops pipeline if rollout fails

### 8. Smoke Test

 A temporary test pod performs:

wget [http://backend:5000/api/health](http://backend:5000/api/health)

 ✔ Confirms backend API is working

 ✔ Validates In-cluster networking

 ✔ Ensures service discovery works

 If the test passes → deployment succeeds

 If it fails → pipeline stops immediately

 CI/CD Flow

 Developer Push -->

    GitHub Actions (CI) -->

        Terraform Validate

        Docker Build Test

        K8s Lint

    If CI Success -->

        GitHub Actions (CD) -->

            Docker Build + Push

            Deploy to AKS

            Rollout Verify

            Smoke Test

 Deployment Ready in AKS