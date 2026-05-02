# Architecture — Spring Boot Hello World · Docker CI/CD Pipeline

## Overview
GitHub Actions pipeline that compiles a Spring Boot 
application, packages it as a Docker image, and pushes 
it to DockerHub on every push to main/master branches.

---

## Pipeline Design Decisions

## Decision 1 — Two-Job Structure (Build → Docker)
The pipeline is split into two explicit jobs:

Job 1: build
  - Compiles Java source with Maven
  - Runs unit tests
  - Packages the JAR (mvn package)
  - Uploads JAR as GitHub Actions artifact

Job 2: docker
  - Downloads the JAR artifact from Job 1
  - Builds Docker image
  - Pushes to DockerHub

Why split? Each job has a single responsibility.
If tests fail, Docker never runs — no broken image 
is ever pushed. In my current role at Siemens I 
enforce the same pattern across 60+ microservices —
the artifact is the contract between build and deploy.

## Decision 2 — Artifact Upload Between Jobs
```yaml
- uses: actions/upload-artifact@v4  # Job 1
- uses: actions/download-artifact@v4  # Job 2
```
Jobs run on separate runners — the filesystem does 
not persist between them. Passing the JAR as an 
artifact is the correct pattern, not re-building 
in the Docker job.

## Decision 3 — Docker Tag Strategy
Two tags pushed on every build:
- `latest` — always points to most recent main build
- `${{ github.sha }}` — immutable, traceable to commit

The SHA tag is critical in production — it means 
every running container can be traced back to the 
exact commit that built it. `latest` alone is 
an anti-pattern in real deployments.

## Decision 4 — Multi-Branch Triggers
```yaml
on:
  push:
    branches: [main, master, feature/**]
```
Covers both `main` and `master` naming conventions
and feature branches — a real-world repo has all three.

## Decision 5 — Secrets for DockerHub
DockerHub credentials are stored as GitHub Secrets:
- `DOCKERHUB_USERNAME`
- `DOCKERHUB_TOKEN` (access token, not password)

Token-based auth over password — tokens can be 
scoped and rotated without changing the account 
password. Same principle I apply to IRSA token 
management in AWS.

---

## Pipeline Flow
