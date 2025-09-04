terraform {
  required_version = "~> 1.5"

  required_providers {
    azapi = {
      source  = "Azure/azapi"
      version = ">= 2.4"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.21"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.5.0"
    }
  }
}

provider "azurerm" {
  features {}
}

provider "azapi" {
}

# Get the current client configuration from Azure
data "azurerm_client_config" "current" {}

# Create a Log Analytics Workspace for diagnostic settings
resource "azurerm_log_analytics_workspace" "this" {
  location            = azurerm_resource_group.this.location
  name                = module.naming.log_analytics_workspace.name_unique
  resource_group_name = azurerm_resource_group.this.name
  retention_in_days   = 30
  sku                 = "PerGB2018"
}

## Section to provide a random Azure region for the resource group
# This allows us to randomize the region for the resource group.
module "regions" {
  source  = "Azure/avm-utl-regions/azurerm"
  version = "0.7.0"
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
  version = "0.4.2"
}

# This is required for resource modules
resource "azurerm_resource_group" "this" {
  location = module.regions.regions[random_integer.region_index.result].name
  name     = module.naming.resource_group.name_unique
}

# This is the module call
module "relay_namespace" {
  source = "../../"

  # source                = "Azure/avm-res-relay-namespace/azurerm"
  location            = azurerm_resource_group.this.location
  name                = module.naming.relay_namespace.name_unique
  resource_group_name = azurerm_resource_group.this.name
  # Add diagnostic settings for the resource
  diagnostic_settings = {
    to_log_analytics = {
      name                  = "to-log-analytics"
      log_categories        = []
      log_groups            = ["allLogs"] # Empty to avoid conflict with log_categories
      metric_categories     = ["AllMetrics"]
      workspace_resource_id = azurerm_log_analytics_workspace.this.id
    }
  }
  disable_local_auth = false
  enable_telemetry   = var.enable_telemetry # see variables.tf
  # Add lock to the resource
  lock = {
    kind = "CanNotDelete"
    name = "lock-${module.naming.relay_namespace.name_unique}"
  }
  public_network_access = "SecuredByPerimeter" # Enable public network access
  # Add role assignments for the resource
  role_assignments = {
    example_role = {
      principal_id               = data.azurerm_client_config.current.object_id
      role_definition_id_or_name = "Azure Relay Sender"
      description                = "Example role assignment for the relay namespace"
      principal_type             = "User"
    }
  }
  sku_name = "Standard"
  tags = {
    environment = "development"
    workload    = "example"
  }
}
