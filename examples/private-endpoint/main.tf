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
      version = ">=3.5.0"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = "bfafcd7f-e975-442d-bb77-1a727f794e23"
  tenant_id       = "8f27ba4c-fd5c-428a-8080-8b720b54e659"
}

provider "azapi" {
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

# Create a virtual network for the private endpoint
resource "azurerm_virtual_network" "this" {
  location            = azurerm_resource_group.this.location
  name                = module.naming.virtual_network.name_unique
  resource_group_name = azurerm_resource_group.this.name
  address_space       = ["10.0.0.0/16"]
}

# Create a subnet for the private endpoint
resource "azurerm_subnet" "endpoint" {
  address_prefixes     = ["10.0.1.0/24"]
  name                 = "endpoint-subnet"
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name
  # Private endpoints configuration
  private_link_service_network_policies_enabled = false
}

# Create a private DNS zone for Azure Relay
resource "azurerm_private_dns_zone" "relay" {
  name                = "privatelink.servicebus.windows.net"
  resource_group_name = azurerm_resource_group.this.name
}

# Link the private DNS zone to the virtual network
resource "azurerm_private_dns_zone_virtual_network_link" "relay" {
  name                  = "relay-zone-link"
  private_dns_zone_name = azurerm_private_dns_zone.relay.name
  resource_group_name   = azurerm_resource_group.this.name
  virtual_network_id    = azurerm_virtual_network.this.id
  registration_enabled  = false
}

# This is the module call with private endpoint configuration
module "relay_namespace" {
  source = "../../"

  # source             = "Azure/avm-res-relay-namespace/azurerm"
  location            = azurerm_resource_group.this.location
  name                = module.naming.relay_namespace.name_unique
  resource_group_name = azurerm_resource_group.this.name
  disable_local_auth  = false
  enable_telemetry    = var.enable_telemetry
  # Private endpoint configuration
  private_endpoints = {
    primary = {
      name               = "pe-relay-namespace"
      subnet_resource_id = azurerm_subnet.endpoint.id
      private_dns_zone_resource_ids = [
        azurerm_private_dns_zone.relay.id
      ]
      private_dns_zone_group_name = "privatednszonegroup"
      subresource_names           = ["namespace"] # Required for Azure Relay
      # If you need specific IP configurations
      # ip_configurations = {
      #   primary = {
      #     name               = "primary"
      #     private_ip_address = "10.0.1.10"
      #   }
      # }
    }
  }
  sku_name = "Standard"
  tags = {
    environment = "development"
    workload    = "example-private-endpoint"
  }
}

