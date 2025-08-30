resource "azapi_resource" "relay_namespace" {
  location  = var.location
  name      = var.name
  parent_id = data.azurerm_resource_group.this.id
  type      = "Microsoft.Relay/namespaces@2021-11-01"
  body = {
    properties = {
      disableLocalAuth = var.disable_local_auth
    }
    sku = {
      name = var.sku_name
      tier = var.sku_name
    }
  }
  create_headers            = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  delete_headers            = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  ignore_missing_property   = true
  locks                     = var.lock != null ? [var.lock.kind] : []
  read_headers              = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  response_export_values    = ["*"]
  schema_validation_enabled = false
  tags                      = var.tags
  update_headers            = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null

  // Only include identity if it's being used
  identity {
    type         = local.managed_identity_type
    identity_ids = local.managed_identity_ids
  }
}

resource "azapi_resource" "diagnostic_settings" {
  for_each = var.diagnostic_settings

  name      = each.value.name != null ? each.value.name : each.key
  parent_id = azapi_resource.relay_namespace.id
  type      = "Microsoft.Insights/diagnosticSettings@2021-05-01-preview"
  body = {
    properties = {
      workspaceId                 = each.value.workspace_resource_id
      storageAccountId            = each.value.storage_account_resource_id
      eventHubAuthorizationRuleId = each.value.event_hub_authorization_rule_resource_id
      eventHubName                = each.value.event_hub_name
      marketplacePartnerId        = each.value.marketplace_partner_resource_id
      logs = [
        for log in each.value.log_categories : {
          category = log
          enabled  = true
        }
      ]
      logAnalyticsDestinationType = each.value.log_analytics_destination_type
      metrics = [
        for metric in each.value.metric_categories : {
          category = metric
          enabled  = true
        }
      ]
    }
  }
  create_headers            = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  delete_headers            = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  read_headers              = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  schema_validation_enabled = false
  update_headers            = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
}

resource "azapi_resource_action" "customer_managed_key" {
  count = var.customer_managed_key != null ? 1 : 0

  action      = "encryptionConfig"
  resource_id = azapi_resource.relay_namespace.id
  type        = "Microsoft.Relay/namespaces@2021-11-01"
  body = {
    keyVaultProperties = {
      keyId    = "${var.customer_managed_key.key_vault_resource_id}/keys/${var.customer_managed_key.key_name}${var.customer_managed_key.key_version != null ? "/${var.customer_managed_key.key_version}" : ""}"
      identity = var.customer_managed_key.user_assigned_identity != null ? var.customer_managed_key.user_assigned_identity.resource_id : null
    }
  }
}

data "azurerm_resource_group" "this" {
  name = var.resource_group_name
}

resource "azapi_resource_action" "role_assignment" {
  for_each = var.role_assignments

  method      = "PUT"
  resource_id = "${azapi_resource.relay_namespace.id}/providers/Microsoft.Authorization/roleAssignments/${random_uuid.role_assignment_name[each.key].result}"
  type        = "Microsoft.Authorization/roleAssignments@2022-04-01"
  body = {
    properties = {
      roleDefinitionId                   = contains(each.value.role_definition_id_or_name, local.role_definition_resource_substring) ? each.value.role_definition_id_or_name : "${local.subscription_resource_id}/providers/Microsoft.Authorization/roleDefinitions/${each.value.role_definition_id_or_name}"
      principalId                        = each.value.principal_id
      description                        = each.value.description
      principalType                      = each.value.principal_type
      condition                          = each.value.condition
      conditionVersion                   = each.value.condition != null ? each.value.condition_version : null
      delegatedManagedIdentityResourceId = each.value.delegated_managed_identity_resource_id
    }
  }
}

data "azurerm_subscription" "current" {}

locals {
  # For the body property (deprecated approach)
  managed_identity = {
    type                   = var.managed_identities.system_assigned && length(var.managed_identities.user_assigned_resource_ids) > 0 ? "SystemAssigned,UserAssigned" : var.managed_identities.system_assigned ? "SystemAssigned" : length(var.managed_identities.user_assigned_resource_ids) > 0 ? "UserAssigned" : null
    userAssignedIdentities = length(var.managed_identities.user_assigned_resource_ids) > 0 ? { for id in var.managed_identities.user_assigned_resource_ids : id => {} } : null
  }
  managed_identity_ids = length(var.managed_identities.user_assigned_resource_ids) > 0 ? var.managed_identities.user_assigned_resource_ids : null
  # For the identity block (preferred approach)
  managed_identity_type    = var.managed_identities.system_assigned && length(var.managed_identities.user_assigned_resource_ids) > 0 ? "SystemAssigned,UserAssigned" : var.managed_identities.system_assigned ? "SystemAssigned" : length(var.managed_identities.user_assigned_resource_ids) > 0 ? "UserAssigned" : "None"
  subscription_resource_id = "/subscriptions/${data.azurerm_subscription.current.subscription_id}"
}

resource "random_uuid" "role_assignment_name" {
  for_each = var.role_assignments

  keepers = {
    name = each.key
  }
}
