# azure-full-stack-terraform
[![Terraform CI](https://github.com/atrakic/azure-full-stack-terraform/actions/workflows/ci.yml/badge.svg)](https://github.com/atrakic/azure-full-stack-terraform/actions/workflows/ci.yml)
[![Docker Compose CI](https://github.com/atrakic/azure-full-stack-terraform/actions/workflows/ci-docker-compose.yml/badge.svg)](https://github.com/atrakic/azure-full-stack-terraform/actions/workflows/ci-docker-compose.yml)
[![Terraform Docs](https://github.com/atrakic/azure-full-stack-terraform/actions/workflows/docs.yml/badge.svg)](https://github.com/atrakic/azure-full-stack-terraform/actions/workflows/docs.yml)
[![license](https://img.shields.io/github/license/atrakic/azure-full-stack-terraform.svg)](https://github.com/atrakic/azure-full-stack-terraform/blob/main/LICENSE)

> Example repo how to build and a deploy full stack project (API+frontEnd) on Azure Cloud with terraform.

![](./docs/screenshot.png)

<!-- BEGIN_TF_DOCS -->


## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >=3.86.0 |
| <a name="requirement_docker"></a> [docker](#requirement\_docker) | 3.6.2 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_api"></a> [api](#module\_api) | ./modules/app | n/a |
| <a name="module_base"></a> [base](#module\_base) | ./modules/base | n/a |
| <a name="module_naming"></a> [naming](#module\_naming) | git::https://github.com/Azure/terraform-azurerm-naming.git | 75d5afae4cb01f4446025e81f76af6b60c1f927b |
| <a name="module_web"></a> [web](#module\_web) | ./modules/app | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cors_origin"></a> [cors\_origin](#input\_cors\_origin) | Allowed CORS origin for the web frontend (e.g. https://myapp.azurewebsites.net). Leave empty to emit no Access-Control-Allow-Origin header (most restrictive). | `string` | `""` | no |
| <a name="input_location"></a> [location](#input\_location) | The Azure region where all resources will be deployed. | `string` | `"northeurope"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_api"></a> [api](#output\_api) | API service hostname and deployment details. |
| <a name="output_location"></a> [location](#output\_location) | The location of the resource. |
| <a name="output_web"></a> [web](#output\_web) | Web frontend hostname and deployment details. |
<!-- END_TF_DOCS -->

## CORS Configuration

The web frontend proxies API requests through nginx (`/api` -> `API_URI`). Cross-Origin Resource Sharing (CORS) headers are baked into the nginx config at **Docker build time** via the `CORS_ORIGIN` build argument.

### Behaviour

| `CORS_ORIGIN` value               | CORS headers emitted                                                    | Effect                                                  |
| --------------------------------- | ----------------------------------------------------------------------- | ------------------------------------------------------- |
| _(empty, default)_                | _(none)_                                                                | Most restrictive — browser blocks cross-origin requests |
| `https://myapp.azurewebsites.net` | `Access-Control-Allow-Origin: https://myapp.azurewebsites.net` (+ Methods & Headers) | Only that exact origin is allowed          |

### Setting a restricted origin via Terraform

```hcl
# terraform.tfvars
cors_origin = "https://webXXXXX.azurewebsites.net"
```

Or pass it at plan/apply time:

```bash
terraform apply -var='cors_origin=https://webXXXXX.azurewebsites.net'
```

### Setting a restricted origin at Docker build time (local)

```bash
docker build \
  --build-arg API_URI=https://api.example.com \
  --build-arg CORS_ORIGIN=https://myapp.example.com \
  src/web/
```

> **Note:** Wildcard (`*`) is intentionally not supported. To open access during local development use the Docker Compose setup, which runs both services on the same origin.
