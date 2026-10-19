mock_provider "azapi" {
  alias = "mock"

  mock_resource "azapi_resource" {
    defaults = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-endpoints/providers/Microsoft.Network/privateEndpoints/pe-test"
      output = {
        properties = {
          networkInterfaces = [
            {
              id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-endpoints/providers/Microsoft.Network/networkInterfaces/nic-test"
            }
          ]
        }
      }
    }
  }

  mock_data "azapi_client_config" {
    defaults = {
      subscription_id          = "00000000-0000-0000-0000-000000000000"
      subscription_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000"
      tenant_id                = "00000000-0000-0000-0000-000000000000"
    }
  }

  mock_data "azapi_resource_list" {
    defaults = {
      output = {
        results = [
          {
            id        = "/subscriptions/00000000-0000-0000-0000-000000000000/providers/Microsoft.Authorization/roleDefinitions/a638d3c7-ab3a-418d-83e6-5f17a39d4fde"
            role_name = "Azure Relay Receiver"
          }
        ]
      }
    }
  }
}

mock_provider "azurerm" {
  mock_data "azurerm_role_definition" {
    defaults = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/providers/Microsoft.Authorization/roleDefinitions/a638d3c7-ab3a-418d-83e6-5f17a39d4fde"
    }
  }
}

mock_provider "azapi" {
  mock_data "azapi_client_config" {
    defaults = {
      subscription_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000"
    }
  }
}

mock_provider "random" {
  mock_resource "random_uuid" {
    defaults = {
      result = "11111111-1111-1111-1111-111111111111"
    }
  }
}

override_resource {
  target = azapi_resource.relay_namespace
  values = {
    id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-relay/providers/Microsoft.Relay/namespaces/relay-test"
  }
}

variables {
  location          = "eastus"
  name              = "relay-test"
  resource_group_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-relay"
  enable_telemetry  = false
}

run "empty_defaults" {
  command = apply

  providers = {
    azapi   = azapi.mock
    azurerm = azurerm

    random = random
  }

  assert {
    condition     = length(azapi_resource.private_endpoints) == 0 && length(azapi_resource.private_dns_zone_groups) == 0 && length(azapi_resource.private_endpoint_locks) == 0 && length(azapi_resource.private_endpoint_role_assignments) == 0
    error_message = "An empty endpoint map must create no endpoint or satellite resources."
  }
  assert {
    condition     = output.resource_id == azapi_resource.relay_namespace.id
    error_message = "The existing namespace resource ID output must be preserved."
  }
}

run "legacy_endpoint_names_and_scope" {
  command = apply

  providers = {
    azapi   = azapi.mock
    azurerm = azurerm

    random = random
  }

  variables {
    private_endpoints = {
      legacy = {
        subnet_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-network/providers/Microsoft.Network/virtualNetworks/vnet/subnets/endpoints"
        subresource_name   = "namespace"
      }
    }
  }

  assert {
    condition     = azapi_resource.private_endpoints["legacy"].name == "pe-relay-test-legacy" && azapi_resource.private_endpoints["legacy"].parent_id == var.resource_group_id && azapi_resource.private_endpoints["legacy"].location == "eastus"
    error_message = "The existing endpoint default name, resource group and location must remain unchanged."
  }
  assert {
    condition     = azapi_resource.private_endpoints["legacy"].body.properties.customNetworkInterfaceName == "nic-pep-${uuidv5("url", azapi_resource.relay_namespace.id)}" && azapi_resource.private_endpoints["legacy"].body.properties.privateLinkServiceConnections[0].name == "pcon-pep-${uuidv5("url", azapi_resource.relay_namespace.id)}"
    error_message = "A single endpoint must keep its legacy NIC and connection default names even when namespace is supplied explicitly."
  }
  assert {
    condition     = azapi_resource.private_endpoints["legacy"].body.properties.privateLinkServiceConnections[0].properties.groupIds[0] == "namespace" && azapi_resource.private_endpoints["legacy"].body.properties.privateLinkServiceConnections[0].properties.privateLinkServiceId == azapi_resource.relay_namespace.id
    error_message = "The endpoint must still connect to the same namespace with the namespace group ID."
  }
  assert {
    condition     = length(azapi_resource.private_dns_zone_groups) == 0
    error_message = "No empty DNS zone group may be created when zone IDs are omitted."
  }
}

run "all_endpoint_settings" {
  command = apply

  providers = {
    azapi   = azapi.mock
    azurerm = azurerm

    random = random
  }

  variables {
    tags = {
      environment = "test"
    }
    private_endpoints = {
      configured = {
        name                            = "pe-configured"
        location                        = "westus2"
        resource_group_name             = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-endpoints"
        subnet_resource_id              = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-network/providers/Microsoft.Network/virtualNetworks/vnet/subnets/endpoints"
        subresource_name                = "namespace"
        network_interface_name          = "nic-configured"
        private_service_connection_name = "connection-configured"
        private_dns_zone_group_name     = "dns-configured"
        private_dns_zone_resource_ids = [
          "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-dns/providers/Microsoft.Network/privateDnsZones/privatelink.servicebus.windows.net"
        ]
        application_security_group_associations = {
          application = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-network/providers/Microsoft.Network/applicationSecurityGroups/application"
        }
        tags = {
          endpoint = "configured"
        }
        ip_configurations = {
          primary = {
            name               = "ip-primary"
            private_ip_address = "10.0.0.4"
            member_name        = "namespace"
          }
        }
        lock = {
          kind  = "CanNotDelete"
          name  = "lock-configured"
          notes = "Protect the endpoint."
        }
        role_assignments = {
          reader = {
            name                                   = "22222222-2222-2222-2222-222222222222"
            role_definition_id_or_name             = "Azure Relay Receiver"
            principal_id                           = "33333333-3333-3333-3333-333333333333"
            description                            = "Endpoint reader."
            principal_type                         = "ServicePrincipal"
            condition                              = "true"
            condition_version                      = "2.0"
            skip_service_principal_aad_check       = true
            delegated_managed_identity_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-identities/providers/Microsoft.ManagedIdentity/userAssignedIdentities/delegated"
          }
        }
      }
    }
  }

  assert {
    condition     = azapi_resource.private_endpoints["configured"].name == "pe-configured" && azapi_resource.private_endpoints["configured"].parent_id == var.private_endpoints["configured"].resource_group_name && azapi_resource.private_endpoints["configured"].location == "westus2"
    error_message = "Explicit endpoint names, resource groups and locations must be honored."
  }
  assert {
    condition     = azapi_resource.private_endpoints["configured"].body.properties.customNetworkInterfaceName == "nic-configured" && azapi_resource.private_endpoints["configured"].body.properties.privateLinkServiceConnections[0].name == "connection-configured" && azapi_resource.private_endpoints["configured"].body.properties.subnet.id == var.private_endpoints["configured"].subnet_resource_id
    error_message = "NIC, connection and subnet settings must reach the endpoint body."
  }
  assert {
    condition     = azapi_resource.private_endpoints["configured"].body.properties.applicationSecurityGroups[0].id == var.private_endpoints["configured"].application_security_group_associations.application && azapi_resource.private_endpoints["configured"].body.properties.ipConfigurations[0].name == "ip-primary" && azapi_resource.private_endpoints["configured"].body.properties.ipConfigurations[0].properties.privateIPAddress == "10.0.0.4" && azapi_resource.private_endpoints["configured"].body.properties.ipConfigurations[0].properties.groupId == "namespace" && azapi_resource.private_endpoints["configured"].body.properties.ipConfigurations[0].properties.memberName == "namespace"
    error_message = "Application security groups and every static IP setting must be retained."
  }
  assert {
    condition     = azapi_resource.private_endpoints["configured"].tags.endpoint == "configured" && !contains(keys(azapi_resource.private_endpoints["configured"].tags), "environment")
    error_message = "An explicit endpoint tag map must replace, not merge, the namespace tags."
  }
  assert {
    condition     = azapi_resource.private_dns_zone_groups["configured"].name == "dns-configured" && azapi_resource.private_dns_zone_groups["configured"].parent_id == azapi_resource.private_endpoints["configured"].id && azapi_resource.private_dns_zone_groups["configured"].body.properties.privateDnsZoneConfigs[0].properties.privateDnsZoneId == one(var.private_endpoints["configured"].private_dns_zone_resource_ids)
    error_message = "DNS zone group name, endpoint parent and zone IDs must be honored."
  }
  assert {
    condition     = azapi_resource.private_endpoint_locks["configured"].name == "lock-configured" && azapi_resource.private_endpoint_locks["configured"].parent_id == azapi_resource.private_endpoints["configured"].id && azapi_resource.private_endpoint_locks["configured"].body.properties.level == "CanNotDelete" && azapi_resource.private_endpoint_locks["configured"].body.properties.notes == "Protect the endpoint."
    error_message = "Explicit endpoint lock names, levels and notes must be applied to the endpoint."
  }
  assert {
    condition     = azapi_resource.private_endpoint_role_assignments["configured-reader"].name == "22222222-2222-2222-2222-222222222222" && azapi_resource.private_endpoint_role_assignments["configured-reader"].parent_id == azapi_resource.private_endpoints["configured"].id && azapi_resource.private_endpoint_role_assignments["configured-reader"].body.properties.roleDefinitionId == "/subscriptions/00000000-0000-0000-0000-000000000000/providers/Microsoft.Authorization/roleDefinitions/a638d3c7-ab3a-418d-83e6-5f17a39d4fde"
    error_message = "Role assignment names and named role definitions must be resolved and scoped to the endpoint."
  }
  assert {
    condition     = azapi_resource.private_endpoint_role_assignments["configured-reader"].body.properties.principalId == "33333333-3333-3333-3333-333333333333" && azapi_resource.private_endpoint_role_assignments["configured-reader"].body.properties.description == "Endpoint reader." && azapi_resource.private_endpoint_role_assignments["configured-reader"].body.properties.principalType == "ServicePrincipal" && azapi_resource.private_endpoint_role_assignments["configured-reader"].body.properties.condition == "true" && azapi_resource.private_endpoint_role_assignments["configured-reader"].body.properties.conditionVersion == "2.0" && azapi_resource.private_endpoint_role_assignments["configured-reader"].body.properties.delegatedManagedIdentityResourceId == var.private_endpoints["configured"].role_assignments.reader.delegated_managed_identity_resource_id
    error_message = "All supported role assignment fields must reach the assignment body."
  }
}

run "static_ip_default_member" {
  command = apply

  providers = {
    azapi   = azapi.mock
    azurerm = azurerm

    random = random
  }

  variables {
    private_endpoints = {
      static = {
        subnet_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-network/providers/Microsoft.Network/virtualNetworks/vnet/subnets/endpoints"
        ip_configurations = {
          primary = {
            name               = "ip-primary"
            private_ip_address = "10.0.0.5"
          }
        }
      }
    }
  }

  assert {
    condition     = azapi_resource.private_endpoints["static"].body.properties.ipConfigurations[0].properties.memberName == "namespace" && azapi_resource.private_endpoints["static"].body.properties.ipConfigurations[0].properties.groupId == "namespace"
    error_message = "Omitted static IP member and group names must use the Relay namespace member, not the generic default."
  }
}

run "multiple_endpoints_and_dns_zones" {
  command = apply

  providers = {
    azapi   = azapi.mock
    azurerm = azurerm

    random = random
  }

  variables {
    private_endpoints = {
      first = {
        name               = "pe-first"
        subnet_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-network/providers/Microsoft.Network/virtualNetworks/vnet/subnets/endpoints"
        private_dns_zone_resource_ids = [
          "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-dns/providers/Microsoft.Network/privateDnsZones/privatelink.servicebus.windows.net",
          "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-dns/providers/Microsoft.Network/privateDnsZones/secondary.example"
        ]
      }
      second = {
        name               = "pe-second"
        subnet_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-network/providers/Microsoft.Network/virtualNetworks/vnet/subnets/endpoints"
      }
    }
  }

  assert {
    condition     = length(azapi_resource.private_endpoints) == 2 && length(azapi_resource.private_dns_zone_groups) == 1 && length(azapi_resource.private_dns_zone_groups["first"].body.properties.privateDnsZoneConfigs) == 2
    error_message = "Every endpoint must be created, with DNS groups only for endpoints having zone IDs."
  }
  assert {
    condition     = length(distinct([for configuration in azapi_resource.private_dns_zone_groups["first"].body.properties.privateDnsZoneConfigs : configuration.name])) == 2
    error_message = "Multiple DNS zone configurations must have distinct stable names."
  }
}

run "externally_managed_dns" {
  command = apply

  providers = {
    azapi   = azapi.mock
    azurerm = azurerm

    random = random
  }

  variables {
    private_endpoints_manage_dns_zone_group = false
    private_endpoints = {
      external = {
        subnet_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-network/providers/Microsoft.Network/virtualNetworks/vnet/subnets/endpoints"
        private_dns_zone_resource_ids = [
          "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-dns/providers/Microsoft.Network/privateDnsZones/privatelink.servicebus.windows.net"
        ]
      }
    }
  }

  assert {
    condition     = length(azapi_resource.private_endpoints) == 1 && length(azapi_resource.private_dns_zone_groups) == 0
    error_message = "Disabling DNS management must retain the endpoint and omit all DNS zone groups."
  }
}

run "default_and_explicit_nic_names" {
  command = apply

  providers = {
    azapi   = azapi.mock
    azurerm = azurerm

    random = random
  }

  variables {
    private_endpoints = {
      existing = {
        subnet_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-network/providers/Microsoft.Network/virtualNetworks/vnet/subnets/endpoints"
      }
      additional = {
        subnet_resource_id     = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-network/providers/Microsoft.Network/virtualNetworks/vnet/subnets/endpoints"
        network_interface_name = "nic-additional"
      }
    }
  }

  assert {
    condition     = azapi_resource.private_endpoints["existing"].body.properties.customNetworkInterfaceName == "nic-pep-${uuidv5("url", azapi_resource.relay_namespace.id)}" && azapi_resource.private_endpoints["additional"].body.properties.customNetworkInterfaceName == "nic-additional"
    error_message = "Adding an endpoint with a unique explicit NIC name must not rename the existing default NIC."
  }
}

run "same_nic_name_in_different_resource_groups" {
  command = apply

  providers = {
    azapi   = azapi.mock
    azurerm = azurerm

    random = random
  }

  variables {
    private_endpoints = {
      first = {
        subnet_resource_id     = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-network/providers/Microsoft.Network/virtualNetworks/vnet/subnets/endpoints"
        network_interface_name = "nic-shared"
      }
      second = {
        subnet_resource_id     = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-network/providers/Microsoft.Network/virtualNetworks/vnet/subnets/endpoints"
        network_interface_name = "nic-shared"
        resource_group_name    = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-other"
      }
    }
  }

  assert {
    condition     = length(azapi_resource.private_endpoints) == 2
    error_message = "Identical NIC names in different resource groups must remain valid."
  }
}

run "reject_duplicate_generated_nic_names" {
  command = plan

  providers = {
    azapi   = azapi.mock
    azurerm = azurerm

    random = random
  }

  variables {
    private_endpoints = {
      first = {
        subnet_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-network/providers/Microsoft.Network/virtualNetworks/vnet/subnets/endpoints"
      }
      second = {
        subnet_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-network/providers/Microsoft.Network/virtualNetworks/vnet/subnets/endpoints"
      }
    }
  }

  expect_failures = [azapi_resource.private_endpoints]
}

run "reject_custom_and_default_nic_collision" {
  command = plan

  providers = {
    azapi   = azapi.mock
    azurerm = azurerm

    random = random
  }

  variables {
    private_endpoints = {
      generated = {
        subnet_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-network/providers/Microsoft.Network/virtualNetworks/vnet/subnets/endpoints"
      }
      explicit = {
        subnet_resource_id     = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-network/providers/Microsoft.Network/virtualNetworks/vnet/subnets/endpoints"
        network_interface_name = "nic-pep-${uuidv5("url", "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-relay/providers/Microsoft.Relay/namespaces/relay-test")}"
      }
    }
  }

  expect_failures = [azapi_resource.private_endpoints]
}

run "reject_case_insensitive_custom_nic_collision" {
  command = plan

  providers = {
    azapi   = azapi.mock
    azurerm = azurerm

    random = random
  }

  variables {
    private_endpoints = {
      first = {
        subnet_resource_id     = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-network/providers/Microsoft.Network/virtualNetworks/vnet/subnets/endpoints"
        network_interface_name = "NIC-SHARED"
      }
      second = {
        subnet_resource_id     = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-network/providers/Microsoft.Network/virtualNetworks/vnet/subnets/endpoints"
        network_interface_name = "nic-shared"
        resource_group_name    = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/RG-RELAY"
      }
    }
  }

  expect_failures = [azapi_resource.private_endpoints]
}

run "lock_inheritance_and_opt_out" {
  command = apply

  providers = {
    azapi   = azapi.mock
    azurerm = azurerm

    random = random
  }

  variables {
    lock = {
      kind  = "ReadOnly"
      notes = "Namespace protection."
    }
    private_endpoints_inherit_lock = {
      unlocked = false
    }
    private_endpoints = {
      inherited = {
        name               = "pe-inherited"
        subnet_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-network/providers/Microsoft.Network/virtualNetworks/vnet/subnets/endpoints"
      }
      unlocked = {
        name               = "pe-unlocked"
        subnet_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-network/providers/Microsoft.Network/virtualNetworks/vnet/subnets/endpoints"
      }
      overridden = {
        name               = "pe-overridden"
        subnet_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-network/providers/Microsoft.Network/virtualNetworks/vnet/subnets/endpoints"
        lock = {
          kind  = "CanNotDelete"
          notes = "Endpoint override."
        }
      }
    }
  }

  assert {
    condition     = length(azapi_resource.private_endpoint_locks) == 2 && !contains(keys(azapi_resource.private_endpoint_locks), "unlocked")
    error_message = "Lock inheritance must apply by default and honor the per-endpoint opt-out."
  }
  assert {
    condition     = azapi_resource.private_endpoint_locks["inherited"].name == "lock-ReadOnly" && azapi_resource.private_endpoint_locks["inherited"].body.properties.notes == "Namespace protection." && azapi_resource.private_endpoint_locks["overridden"].name == "lock-CanNotDelete" && azapi_resource.private_endpoint_locks["overridden"].body.properties.notes == "Endpoint override."
    error_message = "Inherited and explicit locks must retain their levels, generated names and notes."
  }
  assert {
    condition     = azapi_resource.management_lock[0].name == "lock-ReadOnly" && azapi_resource.management_lock[0].body.properties.notes == "Namespace protection."
    error_message = "The existing namespace lock address and generated name must be preserved."
  }
}

run "tag_inheritance_and_empty_override" {
  command = apply

  providers = {
    azapi   = azapi.mock
    azurerm = azurerm

    random = random
  }

  variables {
    tags = {
      environment = "test"
    }
    private_endpoints = {
      inherited = {
        name               = "pe-inherited"
        subnet_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-network/providers/Microsoft.Network/virtualNetworks/vnet/subnets/endpoints"
      }
      empty = {
        name               = "pe-empty"
        subnet_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-network/providers/Microsoft.Network/virtualNetworks/vnet/subnets/endpoints"
        tags               = {}
      }
    }
  }

  assert {
    condition     = azapi_resource.private_endpoints["inherited"].tags.environment == "test" && length(azapi_resource.private_endpoints["empty"].tags) == 0
    error_message = "Omitted tags must inherit, while an explicit empty map must clear all endpoint tags."
  }
}

run "generated_endpoint_role_name" {
  command = apply

  providers = {
    azapi   = azapi.mock
    azurerm = azurerm

    random = random
  }

  variables {
    private_endpoints = {
      role = {
        subnet_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-network/providers/Microsoft.Network/virtualNetworks/vnet/subnets/endpoints"
        role_assignments = {
          reader = {
            role_definition_id_or_name = "/subscriptions/00000000-0000-0000-0000-000000000000/providers/Microsoft.Authorization/roleDefinitions/a638d3c7-ab3a-418d-83e6-5f17a39d4fde"
            principal_id               = "33333333-3333-3333-3333-333333333333"
          }
        }
      }
    }
  }

  assert {
    condition     = azapi_resource.private_endpoint_role_assignments["role-reader"].name == "11111111-1111-1111-1111-111111111111" && azapi_resource.private_endpoint_role_assignments["role-reader"].body.properties.roleDefinitionId == var.private_endpoints["role"].role_assignments.reader.role_definition_id_or_name
    error_message = "An omitted role assignment name must use the helper UUID and a supplied role ID must remain unchanged."
  }
}

run "azapi_controls" {
  command = apply

  providers = {
    azapi   = azapi.mock
    azurerm = azurerm

    random = random
  }

  variables {
    retry = {
      error_message_regex  = ["ScopeLocked"]
      interval_seconds     = 5
      max_interval_seconds = 30
    }
    timeouts = {
      create = "20m"
      read   = "2m"
      update = "15m"
      delete = "10m"
    }
    private_endpoints = {
      controlled = {
        subnet_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-network/providers/Microsoft.Network/virtualNetworks/vnet/subnets/endpoints"
        lock = {
          kind = "CanNotDelete"
        }
        private_dns_zone_resource_ids = [
          "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-dns/providers/Microsoft.Network/privateDnsZones/privatelink.servicebus.windows.net"
        ]
        role_assignments = {
          reader = {
            role_definition_id_or_name = "Azure Relay Receiver"
            principal_id               = "33333333-3333-3333-3333-333333333333"
          }
        }
      }
    }
  }

  assert {
    condition     = azapi_resource.private_endpoints["controlled"].retry.interval_seconds == 5 && azapi_resource.private_dns_zone_groups["controlled"].retry.max_interval_seconds == 30 && azapi_resource.private_endpoint_locks["controlled"].retry.error_message_regex[0] == "ScopeLocked" && azapi_resource.private_endpoint_role_assignments["controlled-reader"].retry.interval_seconds == 5
    error_message = "Retry controls must reach every endpoint and satellite resource."
  }
  assert {
    condition     = azapi_resource.private_endpoints["controlled"].timeouts.create == "20m" && azapi_resource.private_dns_zone_groups["controlled"].timeouts.delete == "10m" && azapi_resource.private_endpoint_locks["controlled"].timeouts.read == "2m" && azapi_resource.private_endpoint_role_assignments["controlled-reader"].timeouts.update == "15m"
    error_message = "Timeout controls must reach every endpoint and satellite resource."
  }
  assert {
    condition     = azapi_resource.private_endpoints["controlled"].type == var.resource_types.network_private_endpoints && azapi_resource.private_dns_zone_groups["controlled"].type == var.resource_types.network_private_endpoints_private_dns_zone_groups && azapi_resource.private_endpoint_locks["controlled"].type == var.resource_types.authorization_locks && azapi_resource.private_endpoint_role_assignments["controlled-reader"].type == var.resource_types.authorization_role_assignments
    error_message = "Every endpoint resource must use its resource_types input."
  }
}

run "telemetry_enabled_with_mocks" {
  command = apply

  providers = {
    azapi   = azapi.mock
    azurerm = azurerm

    random = random
  }

  variables {
    enable_telemetry = true
  }

  assert {
    condition     = output.resource_id == azapi_resource.relay_namespace.id && module.avm_interfaces.private_endpoints_azapi == {}
    error_message = "Enabled root and transitive helper telemetry must remain safe under the explicit provider mocks."
  }
}

run "invalid_subnet_id" {
  command = plan

  providers = {
    azapi   = azapi.mock
    azurerm = azurerm

    random = random
  }

  variables {
    private_endpoints = {
      invalid = {
        subnet_resource_id = "not-a-subnet-id"
      }
    }
  }

  expect_failures = [var.private_endpoints]
}

run "invalid_dns_zone_id" {
  command = plan

  providers = {
    azapi   = azapi.mock
    azurerm = azurerm

    random = random
  }

  variables {
    private_endpoints = {
      invalid = {
        subnet_resource_id            = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-network/providers/Microsoft.Network/virtualNetworks/vnet/subnets/endpoints"
        private_dns_zone_resource_ids = ["not-a-zone-id"]
      }
    }
  }

  expect_failures = [var.private_endpoints]
}

run "invalid_application_security_group_id" {
  command = plan

  providers = {
    azapi   = azapi.mock
    azurerm = azurerm

    random = random
  }

  variables {
    private_endpoints = {
      invalid = {
        subnet_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-network/providers/Microsoft.Network/virtualNetworks/vnet/subnets/endpoints"
        application_security_group_associations = {
          invalid = "not-an-application-security-group-id"
        }
      }
    }
  }

  expect_failures = [var.private_endpoints]
}

run "invalid_delegated_identity_id" {
  command = plan

  providers = {
    azapi   = azapi.mock
    azurerm = azurerm

    random = random
  }

  variables {
    private_endpoints = {
      invalid = {
        subnet_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-network/providers/Microsoft.Network/virtualNetworks/vnet/subnets/endpoints"
        role_assignments = {
          invalid = {
            role_definition_id_or_name             = "Azure Relay Receiver"
            principal_id                           = "33333333-3333-3333-3333-333333333333"
            delegated_managed_identity_resource_id = "not-an-identity-id"
          }
        }
      }
    }
  }

  expect_failures = [var.private_endpoints]
}

run "invalid_endpoint_resource_group_id" {
  command = plan

  providers = {
    azapi   = azapi.mock
    azurerm = azurerm

    random = random
  }

  variables {
    private_endpoints = {
      invalid = {
        subnet_resource_id  = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-network/providers/Microsoft.Network/virtualNetworks/vnet/subnets/endpoints"
        resource_group_name = "rg-name-without-resource-id"
      }
    }
  }

  expect_failures = [azapi_resource.private_endpoints]
}

run "invalid_endpoint_subresource" {
  command = plan

  providers = {
    azapi   = azapi.mock
    azurerm = azurerm

    random = random
  }

  variables {
    private_endpoints = {
      invalid = {
        subnet_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-network/providers/Microsoft.Network/virtualNetworks/vnet/subnets/endpoints"
        subresource_name   = "vault"
      }
    }
  }

  expect_failures = [azapi_resource.private_endpoints]
}

run "invalid_lock_inheritance_key" {
  command = plan

  providers = {
    azapi   = azapi.mock
    azurerm = azurerm

    random = random
  }

  variables {
    private_endpoints_inherit_lock = {
      missing = false
    }
  }

  expect_failures = [var.private_endpoints_inherit_lock]
}
