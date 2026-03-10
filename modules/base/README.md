# base

<!-- BEGIN_TF_DOCS -->


## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >=3.86.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >=3.86.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_application_insights.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/application_insights) | resource |
| [azurerm_container_registry.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/container_registry) | resource |
| [azurerm_resource_group.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_service_plan.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/service_plan) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_location"></a> [location](#input\_location) | The Azure region where resources will be deployed. | `any` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | The base name used for naming Azure resources. | `any` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to assign to the resources. | `map(any)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_application_insights_connection_string"></a> [application\_insights\_connection\_string](#output\_application\_insights\_connection\_string) | The connection string for Application Insights. |
| <a name="output_application_insights_instrumentation_key"></a> [application\_insights\_instrumentation\_key](#output\_application\_insights\_instrumentation\_key) | The instrumentation key for Application Insights. |
| <a name="output_azurerm_container_registry_admin_password"></a> [azurerm\_container\_registry\_admin\_password](#output\_azurerm\_container\_registry\_admin\_password) | The admin password of the Azure Container Registry. |
| <a name="output_azurerm_container_registry_admin_username"></a> [azurerm\_container\_registry\_admin\_username](#output\_azurerm\_container\_registry\_admin\_username) | The admin username of the Azure Container Registry. |
| <a name="output_azurerm_container_registry_id"></a> [azurerm\_container\_registry\_id](#output\_azurerm\_container\_registry\_id) | The ID of the Azure Container Registry. |
| <a name="output_azurerm_container_registry_login_server"></a> [azurerm\_container\_registry\_login\_server](#output\_azurerm\_container\_registry\_login\_server) | The login server URL of the Azure Container Registry. |
| <a name="output_azurerm_resource_group_id"></a> [azurerm\_resource\_group\_id](#output\_azurerm\_resource\_group\_id) | The ID of the Azure Resource Group. |
| <a name="output_azurerm_resource_group_name"></a> [azurerm\_resource\_group\_name](#output\_azurerm\_resource\_group\_name) | The name of the Azure Resource Group. |
| <a name="output_azurerm_service_plan_id"></a> [azurerm\_service\_plan\_id](#output\_azurerm\_service\_plan\_id) | The ID of the Azure App Service Plan. |
<!-- END_TF_DOCS -->
