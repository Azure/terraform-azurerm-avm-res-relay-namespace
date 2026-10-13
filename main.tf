# Azure Relay Namespace
resource "azapi_resource" "relay_namespace" {
  location  = var.location
  name      = var.name
  parent_id = var.resource_group_id
  type      = var.resource_types.relay_namespaces
  body = {
    properties = {
      publicNetworkAccess = var.public_network_access
    }
    sku = {
      name = var.sku.name
      tier = var.sku.tier
    }
  }
  ignore_body_changes       = length(var.ignore_body_changes.relay_namespaces) > 0 ? var.ignore_body_changes.relay_namespaces : null
  response_export_values    = ["*"]
  retry                     = var.retry
  schema_validation_enabled = true
  tags                      = var.tags

  dynamic "timeouts" {
    for_each = var.timeouts == null ? [] : [var.timeouts]
    content {
      create = timeouts.value.create
      read   = timeouts.value.read
      update = timeouts.value.update
      delete = timeouts.value.delete
    }
  }
}

# required AVM resources interfaces
resource "azapi_resource" "management_lock" {
  count = var.lock != null ? 1 : 0

  name      = coalesce(var.lock.name, "lock-${var.lock.kind}")
  parent_id = azapi_resource.relay_namespace.id
  type      = var.resource_types.authorization_locks
  body = {
    properties = {
      level = var.lock.kind
      notes = coalesce(var.lock.notes, var.lock.kind == "CanNotDelete" ? "Cannot delete the resource or its child resources." : "Cannot delete or modify the resource or its child resources.")
    }
  }
  ignore_body_changes    = length(var.ignore_body_changes.authorization_locks) > 0 ? var.ignore_body_changes.authorization_locks : null
  response_export_values = []
  retry                  = var.retry

  dynamic "timeouts" {
    for_each = var.timeouts == null ? [] : [var.timeouts]
    content {
      create = timeouts.value.create
      read   = timeouts.value.read
      update = timeouts.value.update
      delete = timeouts.value.delete
    }
  }

  depends_on = [
    azapi_resource.diagnostic_setting,
    azapi_resource.role_assignment,
    azapi_resource.private_dns_zone_groups,
    azapi_resource.private_endpoint_role_assignments,
    azapi_resource.private_endpoint_locks,
  ]
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

  name      = uuidv5("url", "${azapi_resource.relay_namespace.id}-${each.key}")
  parent_id = azapi_resource.relay_namespace.id
  type      = var.resource_types.authorization_role_assignments
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
  ignore_body_changes    = length(var.ignore_body_changes.authorization_role_assignments) > 0 ? var.ignore_body_changes.authorization_role_assignments : null
  response_export_values = []
  retry                  = var.retry

  dynamic "timeouts" {
    for_each = var.timeouts == null ? [] : [var.timeouts]
    content {
      create = timeouts.value.create
      read   = timeouts.value.read
      update = timeouts.value.update
      delete = timeouts.value.delete
    }
  }
}

resource "azapi_resource" "diagnostic_setting" {
  for_each = var.diagnostic_settings

  name      = each.value.name != null ? each.value.name : "diag-${var.name}"
  parent_id = azapi_resource.relay_namespace.id
  type      = var.resource_types.insights_diagnostic_settings
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
  ignore_body_changes    = length(var.ignore_body_changes.insights_diagnostic_settings) > 0 ? var.ignore_body_changes.insights_diagnostic_settings : null
  response_export_values = []
  retry                  = var.retry

  dynamic "timeouts" {
    for_each = var.timeouts == null ? [] : [var.timeouts]
    content {
      create = timeouts.value.create
      read   = timeouts.value.read
      update = timeouts.value.update
      delete = timeouts.value.delete
    }
  }
}
