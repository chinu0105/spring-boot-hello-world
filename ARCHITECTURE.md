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
  - Packages the JAR (mvn package -DskipTests)
  - Uploads JAR as GitHub Actions artifact

Job 2: docker
  - Downloads the JAR artifact from Job 1
  - Builds Docker image
  - Pushes to DockerHub

Why split? Single responsibility per job.
If the Docker push fails (registry down, bad credentials),
only the docker job retries — no recompilation needed.
The JAR is the contract between build and deploy.

Note: Tests are skipped here with -DskipTests.
In a full production pipeline, a separate test job
would run first and gate the build — ensuring no
broken image is ever pushed.

## Decision 2 — Artifact Upload Between Jobs
```yaml
- uses: actions/upload-artifact@v4  # Job 1
- uses: actions/download-artifact@v4  # Job 2
```
Jobs run on separate runners — the filesystem does
not persist between them. Passing the JAR as an
artifact is the correct pattern, not re-building
in the Docker job.

## Decision 3 — Dockerfile: Single Stage, JRE Only
The Dockerfile uses a single stage with JRE only:

FROM eclipse-temurin:17-jre-alpine

No Maven, no compiler, no build tools in the final
image. The JAR is already built by the pipeline —
Docker only packages and runs it.

This keeps the image under 100MB and removes
unnecessary attack surface from the runtime container.

## Decision 4 — Docker Tag Strategy
Two tags pushed on every build to main/master:
- `latest` — always points to most recent build
- `SHORT_SHA` — immutable, traceable to exact commit

Feature branches get a single tag:
- `feature-login-a1b2c3d4` — isolated, never touches latest

The SHA tag is critical in production — every running
container can be traced back to the exact commit that
built it. `latest` alone is an anti-pattern in real
deployments because it gives no traceability.

## Decision 5 — Multi-Branch Triggers
```yaml
on:
  push:
    branches: [main, master, feature/**]
```
Covers both `main` and `master` naming conventions
and feature branches — a real-world repo has all three.

## Decision 6 — Secrets for DockerHub
DockerHub credentials are stored as GitHub Secrets:
- `DOCKERHUB_USERNAME`
- `DOCKERHUB_TOKEN` (access token, not password)

Token-based auth over password — tokens can be
scoped and rotated without changing the account
password. Same principle I apply to IRSA token
management in AWS at Siemens.

---

## What I Would Add in Production
- Separate test job before build — mvn test with JaCoCo
- Trivy image scan before push — block on CRITICAL CVEs
- OIDC authentication - DockerHub doesn't support OIDC directly yet. But AWS ECR does — and this is where it's most powerful in production
- Multi-platform build (linux/amd64 + linux/arm64)
