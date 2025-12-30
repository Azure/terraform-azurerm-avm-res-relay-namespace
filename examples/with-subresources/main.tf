terraform {
  required_version = "~> 1.5"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.21"
    }
    modtm = {
      source  = "azure/modtm"
      version = "~> 0.3"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
  }
}

provider "azurerm" {
  features {}
}


## Section to provide a random Azure region for the resource group
# This allows us to randomize the region for the resource group.
module "regions" {
  source  = "Azure/avm-utl-regions/azurerm"
  version = "~> 0.1"
}

# This allows us to randomize the region for the resource group.
resource "random_integer" "region_index" {
  max = length(module.regions.regions) - 1
  min = 0
}
## End of section to provide a random Azure region for the resource group

# This ensures we have unique CAF compliant names for our resources.
module "naming" {
  source  = "Azure/naming/azurerm"
  version = "~> 0.3"
}

# This is required for resource modules
resource "azurerm_resource_group" "this" {
  location = module.regions.regions[random_integer.region_index.result].name
  name     = module.naming.resource_group.name_unique
}

# This is the module call for the Relay namespace
module "relay_namespace" {
  source = "../../"

  location          = azurerm_resource_group.this.location
  name              = module.naming.relay_namespace.name_unique
  resource_group_id = azurerm_resource_group.this.id
  enable_telemetry  = var.enable_telemetry

  public_network_access = "Enabled"

  sku = {
    name = "Standard"
    tier = "Standard"
  }
}

# Authorization Rule
module "auth_rule" {
  source = "../../modules/authorization-rule"

  name               = "RootManageSharedAccessKey"
  relay_namespace_id = module.relay_namespace.resource_id
  rights             = ["Listen", "Send", "Manage"]
}

# Hybrid Connection
module "hybrid_connection" {
  source = "../../modules/hybrid-connection"

  name                          = "my-hybrid-connection"
  relay_namespace_id            = module.relay_namespace.resource_id
  requires_client_authorization = true
  user_metadata                 = "Example hybrid connection"
}

# WCF Relay
module "wcf_relay" {
  source = "../../modules/wcf-relay"

  name                          = "my-wcf-relay"
  relay_namespace_id            = module.relay_namespace.resource_id
  relay_type                    = "NetTcp"
  requires_client_authorization = true
  requires_transport_security   = true
  user_metadata                 = "Example WCF relay"
}

# Network Rule Set
module "network_rule_set" {
  source = "../../modules/network-rule-set"

  relay_namespace_id             = module.relay_namespace.resource_id
  default_action                 = "Deny"
  public_network_access          = "Enabled"
  trusted_service_access_enabled = true

  ip_rules = [
    {
      ipMask = "10.0.0.0/24"
      action = "Allow"
    }
  ]
}
