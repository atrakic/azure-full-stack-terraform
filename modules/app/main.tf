variable "location" {
  description = "The Azure region where resources will be deployed."
}
variable "name" {
  description = "The name of the web application."
}
variable "resource_group_id" {
  description = "The ID of the Azure Resource Group."
}
variable "resource_group_name" {
  description = "The name of the Azure Resource Group."
}
variable "image_context" {
  description = "The build context path for the Docker image."
}
variable "docker_image_name" {
  description = "The fully qualified Docker image name including registry and tag."
}
variable "service_plan_id" {
  description = "The ID of the Azure App Service Plan."
}
variable "acr_login_server" {
  description = "The login server URL of the Azure Container Registry."
}
variable "acr_admin_username" {
  description = "The admin username for the Azure Container Registry."
}
variable "acr_admin_password" {
  description = "The admin password for the Azure Container Registry."
}
variable "dockerfile" {
  description = "Path to the Dockerfile used to build the Docker image."
  default     = "Dockerfile"
}

variable "app_settings" {
  description = "A map of application settings for the web app."
  type        = map(string)
  default     = {}
}

variable "site_config" {
  type = object({
    always_on             = optional(bool, true)
    linux_fx_version      = optional(string)
    api_definition_url    = optional(string)
    api_management_api_id = optional(string)
    app_command_line      = optional(string)
    # auto_heal_enabled                             = optional(bool)
    auto_swap_slot_name                           = optional(string)
    app_scale_limit                               = optional(number)
    application_insights_connection_string        = optional(string)
    application_insights_key                      = optional(string)
    container_registry_managed_identity_client_id = optional(string)
    container_registry_use_managed_identity       = optional(bool)
    default_documents                             = optional(list(string))
    elastic_instance_minimum                      = optional(number)
    ftps_state                                    = optional(string, "FtpsOnly")
    health_check_eviction_time_in_min             = optional(number)
    health_check_path                             = optional(string)
    http2_enabled                                 = optional(bool, true)
    ip_restriction_default_action                 = optional(string, "Allow")
    load_balancing_mode                           = optional(string, "LeastRequests")
    local_mysql_enabled                           = optional(bool, false)
    managed_pipeline_mode                         = optional(string, "Integrated")
    minimum_tls_version                           = optional(string, "1.3")
    pre_warmed_instance_count                     = optional(number)
    remote_debugging_enabled                      = optional(bool, false)
    remote_debugging_version                      = optional(string)
    runtime_scale_monitoring_enabled              = optional(bool)
    scm_type                                      = optional(string, "None")
    scm_ip_restriction_default_action             = optional(string, "Allow")
    scm_minimum_tls_version                       = optional(string, "1.3")
    scm_use_main_ip_restriction                   = optional(bool, false)
    use_32_bit_worker                             = optional(bool, false)
    vnet_route_all_enabled                        = optional(bool, false)
    websockets_enabled                            = optional(bool, false)
    worker_count                                  = optional(number)
    app_service_logs = optional(map(object({
      disk_quota_mb         = optional(number, 35)
      retention_period_days = optional(number)
    })), {})
    application_stack = optional(map(object({
      docker = optional(list(object({
        image_name        = string
        image_tag         = string
        registry_password = optional(string)
        registry_url      = string
        registry_username = optional(string)
      })))
      docker_image_name        = optional(string)
      docker_registry_url      = optional(string)
      docker_registry_username = optional(string)
      docker_registry_password = optional(string)
      docker_container_name    = optional(string)
      docker_container_tag     = optional(string)
    })), {})
    cors = optional(map(object({
      allowed_origins     = optional(list(string))
      support_credentials = optional(bool, false)
    })), {})
    ip_restriction = optional(map(object({
      action                    = optional(string, "Allow")
      ip_address                = optional(string)
      name                      = optional(string)
      priority                  = optional(number, 65000)
      service_tag               = optional(string)
      virtual_network_subnet_id = optional(string)
      headers = optional(map(object({
        x_azure_fdid      = optional(list(string))
        x_fd_health_probe = optional(list(string), ["1"])
        x_forwarded_for   = optional(list(string))
        x_forwarded_host  = optional(list(string))
      })), {})
    })), {})
    scm_ip_restriction = optional(map(object({
      action                    = optional(string, "Allow")
      ip_address                = optional(string)
      name                      = optional(string)
      priority                  = optional(number, 65000)
      service_tag               = optional(string)
      virtual_network_subnet_id = optional(string)
      headers = optional(map(object({
        x_azure_fdid      = optional(list(string))
        x_fd_health_probe = optional(list(string), ["1"])
        x_forwarded_for   = optional(list(string))
        x_forwarded_host  = optional(list(string))
      })), {})
    })), {})
  })
  default = {}
}

variable "auth_settings" {
  type = map(object({
    additional_login_parameters    = optional(map(string))
    allowed_external_redirect_urls = optional(list(string))
    default_provider               = optional(string)
    enabled                        = optional(bool, false)
    issuer                         = optional(string)
    runtime_version                = optional(string)
    token_refresh_extension_hours  = optional(number, 72)
    token_store_enabled            = optional(bool, false)
    unauthenticated_client_action  = optional(string)
    active_directory = optional(map(object({
      client_id                  = optional(string)
      allowed_audiences          = optional(list(string))
      client_secret              = optional(string)
      client_secret_setting_name = optional(string)
    })), {})
    facebook = optional(map(object({
      app_id                  = optional(string)
      app_secret              = optional(string)
      app_secret_setting_name = optional(string)
      oauth_scopes            = optional(list(string))
    })), {})
    github = optional(map(object({
      client_id                  = optional(string)
      client_secret              = optional(string)
      client_secret_setting_name = optional(string)
      oauth_scopes               = optional(list(string))
    })), {})
    google = optional(map(object({
      client_id                  = optional(string)
      client_secret              = optional(string)
      client_secret_setting_name = optional(string)
      oauth_scopes               = optional(list(string))
    })), {})
    microsoft = optional(map(object({
      client_id                  = optional(string)
      client_secret              = optional(string)
      client_secret_setting_name = optional(string)
      oauth_scopes               = optional(list(string))
    })), {})
    twitter = optional(map(object({
      consumer_key                 = optional(string)
      consumer_secret              = optional(string)
      consumer_secret_setting_name = optional(string)
    })), {})
  }))
  default = {
  }
  description = <<EXAMPLE
    ```terraform
  auth_settings = {
    example = {
      enabled = true
      active_directory = {
        client_id                  = "00000000-0000-0000-0000-000000000000"
        allowed_audiences          = ["00000000-0000-0000-0000-000000000000"]
        client_secret              = "00000000-0000-0000-0000-000000000000"
        client_secret_setting_name = "00000000-0000-0000-0000-000000000000"
      }
    }
  }
  ```
  EXAMPLE
}

variable "auth_settings_v2" {
  type = map(object({
    auth_enabled                            = optional(bool, false)
    config_file_path                        = optional(string)
    default_provider                        = optional(string)
    excluded_paths                          = optional(list(string))
    forward_proxy_convention                = optional(string, "NoProxy")
    forward_proxy_custom_host_header_name   = optional(string)
    forward_proxy_custom_scheme_header_name = optional(string)
    http_route_api_prefix                   = optional(string, "/.auth")
    require_authentication                  = optional(bool, false)
    require_https                           = optional(bool, true)
    runtime_version                         = optional(string, "~1")
    unauthenticated_action                  = optional(string, "RedirectToLoginPage")
    active_directory_v2 = optional(map(object({
      allowed_applications                 = optional(list(string))
      allowed_audiences                    = optional(list(string))
      allowed_groups                       = optional(list(string))
      allowed_identities                   = optional(list(string))
      client_id                            = optional(string)
      client_secret_certificate_thumbprint = optional(string)
      client_secret_setting_name           = optional(string)
      jwt_allowed_client_applications      = optional(list(string))
      jwt_allowed_groups                   = optional(list(string))
      login_parameters                     = optional(map(any))
      tenant_auth_endpoint                 = optional(string)
      www_authentication_disabled          = optional(bool, false)
    })), {})
    apple_v2 = optional(map(object({
      client_id                  = optional(string)
      client_secret_setting_name = optional(string)
      login_scopes               = optional(list(string))
    })), {})
    azure_static_web_app_v2 = optional(map(object({
      client_id = optional(string)
    })), {})
    custom_oidc_v2 = optional(map(object({
      authorisation_endpoint        = optional(string)
      certification_uri             = optional(string)
      client_credential_method      = optional(string)
      client_id                     = optional(string)
      client_secret_setting_name    = optional(string)
      issuer_endpoint               = optional(string)
      name                          = optional(string)
      name_claim_type               = optional(string)
      openid_configuration_endpoint = optional(string)
      scopes                        = optional(list(string))
      token_endpoint                = optional(string)
    })), {})
    facebook_v2 = optional(map(object({
      app_id                  = optional(string)
      app_secret_setting_name = optional(string)
      graph_api_version       = optional(string)
      login_scopes            = optional(list(string))
    })), {})
    github_v2 = optional(map(object({
      client_id                  = optional(string)
      client_secret_setting_name = optional(string)
      login_scopes               = optional(list(string))
    })), {})
    google_v2 = optional(map(object({
      client_id                  = optional(string)
      client_secret_setting_name = optional(string)
      allowed_audiences          = optional(list(string))
      login_scopes               = optional(list(string))
    })), {})
    login = optional(map(object({
      allowed_external_redirect_urls    = optional(list(string))
      cookie_expiration_convention      = optional(string, "FixedTime")
      cookie_expiration_time            = optional(string, "08:00:00")
      logout_endpoint                   = optional(string)
      nonce_expiration_time             = optional(string, "00:05:00")
      preserve_url_fragments_for_logins = optional(bool, false)
      token_refresh_extension_time      = optional(number, 72)
      token_store_enabled               = optional(bool, false)
      token_store_path                  = optional(string)
      token_store_sas_setting_name      = optional(string)
      validate_nonce                    = optional(bool, true)
      })),
      {
        login = {}
    })
    microsoft_v2 = optional(map(object({
      client_id                  = optional(string)
      client_secret_setting_name = optional(string)
      allowed_audiences          = optional(list(string))
      login_scopes               = optional(list(string))
    })), {})
    twitter_v2 = optional(map(object({
      consumer_key                 = optional(string)
      consumer_secret_setting_name = optional(string)
    })), {})
  }))
  default = {}
}

variable "storage_shares_to_mount" {
  type = map(object({
    access_key   = string
    account_name = string
    mount_path   = string
    name         = string
    share_name   = string
    type         = optional(string, "AzureFiles")
  }))
  default = {
  }
}

variable "tags" {
  description = "A map of tags to assign to the resources."
  type        = map(any)
  default     = {}
}

resource "docker_registry_image" "this" {
  name          = docker_image.this.name
  keep_remotely = false
}

resource "docker_image" "this" {
  name = var.docker_image_name # "${data.azurerm_container_registry.acr.login_server}/${local.image_name}"
  #keep_locally = false

  build {
    no_cache   = true
    dockerfile = var.dockerfile
    context    = var.image_context
  }
}

resource "azurerm_linux_web_app" "this" {
  name = var.name

  # checkov:skip=CKV_AZURE_78: "Ensure FTP deployments are disabled":
  # checkov:skip=CKV_AZURE_214: "Ensure App Service is set to be always on"
  # checkov:skip=CKV_AZURE_18: "Ensure that 'HTTP Version' is the latest if used to run the web app"
  # checkov:skip=CKV_AZURE_63: "Ensure that App service enables HTTP logging"
  # checkov:skip=CKV_AZURE_222: "Ensure that Azure Web App public network access is disabled"
  # checkov:skip=CKV_AZURE_13: "Ensure App Service Authentication is set on Azure App Service"
  # checkov:skip=CKV_AZURE_17: "Ensure the web app has 'Client Certificates (Incoming client certificates)' set"
  # checkov:skip=CKV_AZURE_88: "Ensure that app services use Azure Files"
  # checkov:skip=CKV_AZURE_66: "Ensure that App service enables failed request tracing"
  # checkov:skip=CKV_AZURE_65: "Ensure that App service enables detailed error messages"

  resource_group_name = var.resource_group_name
  location            = var.location
  service_plan_id     = var.service_plan_id
  https_only          = true

  site_config {
    http2_enabled                           = var.site_config.http2_enabled
    container_registry_use_managed_identity = true
    always_on                               = var.site_config.always_on
    ftps_state                              = var.site_config.ftps_state
    health_check_path                       = var.site_config.health_check_path

    dynamic "application_stack" {
      for_each = var.site_config.application_stack

      content {
        docker_image_name = docker_image.this.name # local.image_name
        #docker_image_name        = application_stack.value.docker_image_name
        docker_registry_password = application_stack.value.docker_registry_password
        docker_registry_url      = application_stack.value.docker_registry_url
        docker_registry_username = application_stack.value.docker_registry_username
      }

    }
    dynamic "cors" {
      for_each = var.site_config.cors

      content {
        allowed_origins     = cors.value.allowed_origins
        support_credentials = cors.value.support_credentials
      }
    }
    dynamic "ip_restriction" {
      for_each = var.site_config.ip_restriction

      content {
        action                    = ip_restriction.value.action
        ip_address                = ip_restriction.value.ip_address
        name                      = ip_restriction.value.name
        priority                  = ip_restriction.value.priority
        service_tag               = ip_restriction.value.service_tag
        virtual_network_subnet_id = ip_restriction.value.virtual_network_subnet_id

        dynamic "headers" {
          for_each = ip_restriction.value.headers

          content {
            x_azure_fdid      = headers.value.x_azure_fdid
            x_fd_health_probe = headers.value.x_fd_health_probe
            x_forwarded_for   = headers.value.x_forwarded_for
            x_forwarded_host  = headers.value.x_forwarded_host
          }
        }
      }
    }
    dynamic "scm_ip_restriction" {
      # one or more scm_ip_restriction blocks
      for_each = var.site_config.scm_ip_restriction

      content {
        action                    = scm_ip_restriction.value.action
        ip_address                = scm_ip_restriction.value.ip_address
        name                      = scm_ip_restriction.value.name
        priority                  = scm_ip_restriction.value.priority
        service_tag               = scm_ip_restriction.value.service_tag
        virtual_network_subnet_id = scm_ip_restriction.value.virtual_network_subnet_id

        dynamic "headers" {
          for_each = scm_ip_restriction.value.headers

          content {
            x_azure_fdid      = headers.value.x_azure_fdid
            x_fd_health_probe = headers.value.x_fd_health_probe
            x_forwarded_for   = headers.value.x_forwarded_for
            x_forwarded_host  = headers.value.x_forwarded_host
          }
        }
      }
    }
  }
  dynamic "auth_settings" {
    for_each = var.auth_settings

    content {
      enabled                        = auth_settings.value.enabled
      additional_login_parameters    = auth_settings.value.additional_login_parameters
      allowed_external_redirect_urls = auth_settings.value.allowed_external_redirect_urls
      default_provider               = auth_settings.value.default_provider
      issuer                         = auth_settings.value.issuer
      runtime_version                = auth_settings.value.runtime_version
      token_refresh_extension_hours  = auth_settings.value.token_refresh_extension_hours
      token_store_enabled            = auth_settings.value.token_store_enabled
      unauthenticated_client_action  = auth_settings.value.unauthenticated_client_action

      dynamic "active_directory" {
        for_each = auth_settings.value.active_directory

        content {
          client_id                  = active_directory.value.client_id
          allowed_audiences          = active_directory.value.allowed_audiences
          client_secret              = active_directory.value.client_secret
          client_secret_setting_name = active_directory.value.client_secret_setting_name
        }
      }
      dynamic "facebook" {
        for_each = auth_settings.value.facebook

        content {
          app_id                  = facebook.value.app_id
          app_secret              = facebook.value.app_secret
          app_secret_setting_name = facebook.value.app_secret_setting_name
          oauth_scopes            = facebook.value.oauth_scopes
        }
      }
      dynamic "github" {
        for_each = auth_settings.value.github

        content {
          client_id                  = github.value.client_id
          client_secret              = github.value.client_secret
          client_secret_setting_name = github.value.client_secret_setting_name
          oauth_scopes               = github.value.oauth_scopes
        }
      }
      dynamic "google" {
        for_each = auth_settings.value.google

        content {
          client_id                  = google.value.client_id
          client_secret              = google.value.client_secret
          client_secret_setting_name = google.value.client_secret_setting_name
          oauth_scopes               = google.value.oauth_scopes
        }
      }
      dynamic "microsoft" {
        for_each = auth_settings.value.microsoft

        content {
          client_id                  = microsoft.value.client_id
          client_secret              = microsoft.value.client_secret
          client_secret_setting_name = microsoft.value.client_secret_setting_name
          oauth_scopes               = microsoft.value.oauth_scopes
        }
      }
      dynamic "twitter" {
        for_each = auth_settings.value.twitter

        content {
          consumer_key                 = twitter.value.consumer_key
          consumer_secret              = twitter.value.consumer_secret
          consumer_secret_setting_name = twitter.value.consumer_secret_setting_name
        }
      }
    }
  }
  dynamic "auth_settings_v2" {
    for_each = var.auth_settings_v2

    content {
      auth_enabled                            = auth_settings_v2.value.auth_enabled
      config_file_path                        = auth_settings_v2.value.config_file_path
      default_provider                        = auth_settings_v2.value.default_provider
      excluded_paths                          = auth_settings_v2.value.excluded_paths
      forward_proxy_convention                = auth_settings_v2.value.forward_proxy_convention
      forward_proxy_custom_host_header_name   = auth_settings_v2.value.forward_proxy_custom_host_header_name
      forward_proxy_custom_scheme_header_name = auth_settings_v2.value.forward_proxy_custom_scheme_header_name
      http_route_api_prefix                   = auth_settings_v2.value.http_route_api_prefix
      require_authentication                  = auth_settings_v2.value.require_authentication
      require_https                           = auth_settings_v2.value.require_https
      runtime_version                         = auth_settings_v2.value.runtime_version
      unauthenticated_action                  = auth_settings_v2.value.unauthenticated_action

      dynamic "login" {
        for_each = auth_settings_v2.value.login

        content {
          allowed_external_redirect_urls    = login.value.allowed_external_redirect_urls
          cookie_expiration_convention      = login.value.cookie_expiration_convention
          cookie_expiration_time            = login.value.cookie_expiration_time
          logout_endpoint                   = login.value.logout_endpoint
          nonce_expiration_time             = login.value.nonce_expiration_time
          preserve_url_fragments_for_logins = login.value.preserve_url_fragments_for_logins
          token_refresh_extension_time      = login.value.token_refresh_extension_time
          token_store_enabled               = login.value.token_store_enabled
          token_store_path                  = login.value.token_store_path
          token_store_sas_setting_name      = login.value.token_store_sas_setting_name
          validate_nonce                    = login.value.validate_nonce
        }
      }
      dynamic "active_directory_v2" {
        for_each = auth_settings_v2.value.active_directory_v2

        content {
          client_id                            = active_directory_v2.value.client_id
          tenant_auth_endpoint                 = active_directory_v2.value.tenant_auth_endpoint
          allowed_applications                 = active_directory_v2.value.allowed_applications
          allowed_audiences                    = active_directory_v2.value.allowed_audiences
          allowed_groups                       = active_directory_v2.value.allowed_groups
          allowed_identities                   = active_directory_v2.value.allowed_identities
          client_secret_certificate_thumbprint = active_directory_v2.value.client_secret_certificate_thumbprint
          client_secret_setting_name           = active_directory_v2.value.client_secret_setting_name
          jwt_allowed_client_applications      = active_directory_v2.value.jwt_allowed_client_applications
          jwt_allowed_groups                   = active_directory_v2.value.jwt_allowed_groups
          login_parameters                     = active_directory_v2.value.login_parameters
          www_authentication_disabled          = active_directory_v2.value.www_authentication_disabled
        }
      }
      dynamic "apple_v2" {
        for_each = auth_settings_v2.value.apple_v2

        content {
          client_id                  = apple_v2.value.client_id
          client_secret_setting_name = apple_v2.value.client_secret_setting_name
          login_scopes               = apple_v2.value.login_scopes
        }
      }
      dynamic "azure_static_web_app_v2" {
        for_each = auth_settings_v2.value.azure_static_web_app_v2

        content {
          client_id = azure_static_web_app_v2.value.client_id
        }
      }
      dynamic "custom_oidc_v2" {
        for_each = auth_settings_v2.value.custom_oidc_v2

        content {
          client_id                     = custom_oidc_v2.value.client_id
          name                          = custom_oidc_v2.value.name
          openid_configuration_endpoint = custom_oidc_v2.value.openid_configuration_endpoint
          authorisation_endpoint        = custom_oidc_v2.value.authorisation_endpoint
          certification_uri             = custom_oidc_v2.value.certification_uri
          client_credential_method      = custom_oidc_v2.value.client_credential_method
          # Removed `clent_secret_setting_name` as its value will be decided automatically based on the result of applying this configuration.
          # client_secret_setting_name    = coalesce(custom_oidc_v2.value.client_secret_setting_name, "${custom_oidc_v2.value.name}_PROVIDER_AUTHENTICATION_SECRET")
          issuer_endpoint = custom_oidc_v2.value.issuer_endpoint
          name_claim_type = custom_oidc_v2.value.name_claim_type
          scopes          = custom_oidc_v2.value.scopes
          token_endpoint  = custom_oidc_v2.value.token_endpoint
        }
      }
      dynamic "facebook_v2" {
        for_each = auth_settings_v2.value.facebook_v2

        content {
          app_id                  = facebook_v2.value.app_id
          app_secret_setting_name = facebook_v2.value.app_secret_setting_name
          graph_api_version       = facebook_v2.value.graph_api_version
          login_scopes            = facebook_v2.value.login_scopes
        }
      }
      dynamic "github_v2" {
        for_each = auth_settings_v2.value.github_v2

        content {
          client_id                  = github_v2.value.client_id
          client_secret_setting_name = github_v2.value.client_secret_setting_name
          login_scopes               = github_v2.value.login_scopes
        }
      }
      dynamic "google_v2" {
        for_each = auth_settings_v2.value.google_v2

        content {
          client_id                  = google_v2.value.client_id
          client_secret_setting_name = google_v2.value.client_secret_setting_name
          allowed_audiences          = google_v2.value.allowed_audiences
          login_scopes               = google_v2.value.login_scopes
        }
      }
      dynamic "microsoft_v2" {
        for_each = auth_settings_v2.value.microsoft_v2

        content {
          client_id                  = microsoft_v2.value.client_id
          client_secret_setting_name = microsoft_v2.value.client_secret_setting_name
          allowed_audiences          = microsoft_v2.value.allowed_audiences
          login_scopes               = microsoft_v2.value.login_scopes
        }
      }
      dynamic "twitter_v2" {
        for_each = auth_settings_v2.value.twitter_v2

        content {
          consumer_key                 = twitter_v2.value.consumer_key
          consumer_secret_setting_name = twitter_v2.value.consumer_secret_setting_name
        }
      }
    }
  }

  app_settings = var.app_settings

  dynamic "storage_account" {
    for_each = var.storage_shares_to_mount

    content {
      access_key   = storage_account.value.access_key
      account_name = storage_account.value.account_name
      name         = storage_account.value.name
      share_name   = storage_account.value.share_name
      type         = storage_account.value.type
      mount_path   = storage_account.value.mount_path
    }
  }

  logs {
    failed_request_tracing  = true
    detailed_error_messages = true
  }

  identity {
    type = "SystemAssigned"
  }

  lifecycle {
    ignore_changes = [
      site_config.0.application_stack
    ]
  }

  depends_on = [
    docker_registry_image.this
  ]

  tags = var.tags
}

resource "azurerm_role_assignment" "this" {
  scope                = var.resource_group_id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_linux_web_app.this.identity[0].principal_id
}

output "default_hostname" {
  description = "The default hostname of the deployed Azure Linux Web App."
  value       = azurerm_linux_web_app.this.default_hostname
}
