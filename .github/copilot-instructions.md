# Copilot Cloud Agent Onboarding Guide

## Repository purpose
- Demo full-stack deployment on Azure using Terraform.
- Provisions shared Azure infra (`modules/base`) plus two Linux Web Apps (`modules/app`) for API and web.
- Local verification uses Docker Compose (`compose.yml` + `compose.ci.yml`) and `tests/test.sh`.

## Tech stack and key files
- Terraform root: `/tmp/workspace/atrakic/azure-full-stack-terraform/main.tf`
- Terraform modules:
  - `/tmp/workspace/atrakic/azure-full-stack-terraform/modules/base`
  - `/tmp/workspace/atrakic/azure-full-stack-terraform/modules/app`
- App images are Dockerfile-driven:
  - API: `/tmp/workspace/atrakic/azure-full-stack-terraform/src/api/Dockerfile`
  - Web: `/tmp/workspace/atrakic/azure-full-stack-terraform/src/web/Dockerfile`
  - CLI sample: `/tmp/workspace/atrakic/azure-full-stack-terraform/src/cli/Dockerfile`
- CI workflows:
  - Terraform CI: `/tmp/workspace/atrakic/azure-full-stack-terraform/.github/workflows/ci.yml`
  - Docker Compose CI: `/tmp/workspace/atrakic/azure-full-stack-terraform/.github/workflows/ci-docker-compose.yml`
  - Terraform docs automation: `/tmp/workspace/atrakic/azure-full-stack-terraform/.github/workflows/docs.yml`

## How to work efficiently in this repo
1. Identify scope first:
   - `**/*.tf` or `modules/**` changes: run Terraform formatting/validation checks.
   - `src/**`, `compose*.yml`, or `tests/**` changes: run Docker Compose CI command locally if possible.
2. Keep changes minimal and module-oriented:
   - Shared infra goes in `modules/base`.
   - Containerized app/web app behavior belongs in `modules/app` and corresponding Dockerfiles.
3. Preserve terraform-docs blocks (`<!-- BEGIN_TF_DOCS -->`) in README files.

## Validation commands (mirrors repo workflows)
Run from repository root `/tmp/workspace/atrakic/azure-full-stack-terraform`.

### Terraform-focused
```bash
terraform fmt -check -recursive
terraform init -backend=false
terraform validate
```

### Docker Compose CI equivalent
```bash
DOCKER_BUILDKIT=1 docker compose -f compose.yml -f compose.ci.yml up --build --quiet-pull --force-recreate --no-color --remove-orphans --exit-code-from ci
```

## Important conventions and gotchas
- Terraform style uses standard `terraform fmt` output (2-space indentation from `.editorconfig`).
- Root variable `cors_origin` is propagated to web image build arg `CORS_ORIGIN` to control nginx CORS headers.
- API container default port is `3000`; web container serves on `8080` (host mapped to `8000` in compose).
- Workflow trigger paths are selective; when changing CI behavior, verify the matching workflow file path filters.

## Errors encountered during onboarding and workarounds
1. `terraform: command not found` in the current agent sandbox.
   - Workaround: install Terraform in the environment before running Terraform checks, or rely on GitHub Actions `Terraform CI` workflow for validation.
2. `pre-commit: command not found` in the current agent sandbox.
   - Workaround: install `pre-commit` (and hook dependencies) only when pre-commit checks are required locally.
3. Docker Compose CI command failed in sandbox with:
   - `web  | nginx: [emerg] host not found in upstream "api:3000" in /etc/nginx/conf.d/default.conf:4`
   - command exit code observed: `137`
   - Workaround: rerun Compose after ensuring clean state (`docker compose down --remove-orphans`) and verify `api` service is resolvable before `web` starts; if this remains flaky in sandbox, use GitHub Actions `Docker Compose CI` as source of truth.

## What to avoid
- Do not rewrite generated terraform-docs sections manually.
- Do not assume local cloud credentials exist; Terraform plan/apply may require Azure auth env vars.
- Do not broaden workflow trigger paths unless intentionally changing CI scope.
