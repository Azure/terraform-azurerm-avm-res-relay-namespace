# Data source for current client config
data "azapi_client_config" "current" {}

# Azure Relay Namespace
resource "azapi_resource" "relay_namespace" {
  type      = "Microsoft.Relay/namespaces@2024-01-01"
  name      = var.name
  location  = var.location
  parent_id = var.resource_group_id

  body = {
    properties = {
      publicNetworkAccess = var.public_network_access
    }
    sku = {
      name = var.sku.name
      tier = var.sku.tier
    }
  }

  tags = var.tags

  response_export_values = ["*"]

  # Disable schema validation to allow identity block outside of body
  # The identity configuration is handled via dynamic blocks below
  schema_validation_enabled = false

  dynamic "identity" {
    for_each = local.managed_identities.system_assigned_user_assigned

    content {
      type         = identity.value.type
      identity_ids = identity.value.user_assigned_resource_ids
    }
  }

  dynamic "identity" {
    for_each = local.managed_identities.system_assigned

    content {
      type = identity.value.type
    }
  }

  dynamic "identity" {
    for_each = local.managed_identities.user_assigned

    content {
      type         = identity.value.type
      identity_ids = identity.value.user_assigned_resource_ids
    }
  }
  create_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  delete_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  read_headers   = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  update_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
}

# required AVM resources interfaces
resource "azapi_resource" "management_lock" {
  count = var.lock != null ? 1 : 0

  type      = "Microsoft.Authorization/locks@2020-05-01"
  name      = coalesce(var.lock.name, "lock-${var.lock.kind}")
  parent_id = azapi_resource.relay_namespace.id

  body = {
    properties = {
      level = var.lock.kind
      notes = var.lock.kind == "CanNotDelete" ? "Cannot delete the resource or its child resources." : "Cannot delete or modify the resource or its child resources."
    }
  }

  create_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  delete_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  read_headers   = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  update_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
}

# Data source to resolve role definition names to IDs
data "azurerm_role_definition" "this" {
  for_each = {
    for k, v in var.role_assignments : k => v
    if !strcontains(lower(v.role_definition_id_or_name), lower(local.role_definition_resource_substring))
  }

  name  = each.value.role_definition_id_or_name
  scope = azapi_resource.relay_namespace.id
}

resource "azapi_resource" "role_assignment" {
  for_each = var.role_assignments

  type      = "Microsoft.Authorization/roleAssignments@2022-04-01"
  name      = uuidv5("url", "${azapi_resource.relay_namespace.id}-${each.key}")
  parent_id = azapi_resource.relay_namespace.id

  body = {
    properties = merge(
      {
        principalId      = each.value.principal_id
        roleDefinitionId = strcontains(lower(each.value.role_definition_id_or_name), lower(local.role_definition_resource_substring)) ? each.value.role_definition_id_or_name : data.azurerm_role_definition.this[each.key].id
      },
      each.value.description != null ? { description = each.value.description } : {},
      each.value.principal_type != null ? { principalType = each.value.principal_type } : {},
      each.value.condition != null ? { condition = each.value.condition } : {},
      each.value.condition_version != null ? { conditionVersion = each.value.condition_version } : {},
      each.value.delegated_managed_identity_resource_id != null ? { delegatedManagedIdentityResourceId = each.value.delegated_managed_identity_resource_id } : {}
    )
  }

  create_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  delete_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  read_headers   = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  update_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
}

resource "azapi_resource" "diagnostic_setting" {
  for_each = var.diagnostic_settings

  type      = "Microsoft.Insights/diagnosticSettings@2021-05-01-preview"
  name      = each.value.name != null ? each.value.name : "diag-${var.name}"
  parent_id = azapi_resource.relay_namespace.id

  body = {
    properties = merge(
      {
        logs = concat(
          [
            for category in each.value.log_categories : {
              category = category
              enabled  = true
            }
          ],
          [
            for group in each.value.log_groups : {
              categoryGroup = group
              enabled       = true
            }
          ]
        )
        metrics = [
          for category in each.value.metric_categories : {
            category = category
            enabled  = true
          }
        ]
      },
      each.value.workspace_resource_id != null ? { workspaceId = each.value.workspace_resource_id } : {},
      each.value.storage_account_resource_id != null ? { storageAccountId = each.value.storage_account_resource_id } : {},
      each.value.event_hub_authorization_rule_resource_id != null ? { eventHubAuthorizationRuleId = each.value.event_hub_authorization_rule_resource_id } : {},
      each.value.event_hub_name != null ? { eventHubName = each.value.event_hub_name } : {},
      each.value.marketplace_partner_resource_id != null ? { marketplacePartnerId = each.value.marketplace_partner_resource_id } : {},
      each.value.log_analytics_destination_type != null ? { logAnalyticsDestinationType = each.value.log_analytics_destination_type } : {}
    )
  }

  create_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  delete_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  read_headers   = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  update_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
}
