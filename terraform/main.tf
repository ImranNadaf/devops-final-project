data "azurerm_client_config" "current" {}

# ----------------------------------------------------
# Resource Group
# ----------------------------------------------------
resource "azurerm_resource_group" "rg" {
  name     = "${var.prefix}-rg"
  location = var.location
}

# ----------------------------------------------------
# Network Module
# ----------------------------------------------------
module "network" {
  source               = "./modules/network"
  resource_group_name  = azurerm_resource_group.rg.name
  location             = azurerm_resource_group.rg.location
  vnet_address_space   = var.vnet_address_space
  public_subnet_prefix = var.public_subnet_prefix
  private_subnet_prefix = var.private_subnet_prefix
  prefix               = var.prefix
}

# ----------------------------------------------------
# AKS Cluster
# ----------------------------------------------------
resource "azurerm_kubernetes_cluster" "aks" {
  name                = "${var.prefix}-aks"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "${var.prefix}-dns"

  # Node Pool
  default_node_pool {
    name                = "system"
    vm_size             = var.aks_node_size
    node_count          = var.aks_node_count
    vnet_subnet_id      = module.network.private_subnet_id
    type                = "VirtualMachineScaleSets"
  }

  identity {
    type = "SystemAssigned"
  }

  # FIXED: Service CIDR conflict
  network_profile {
    network_plugin     = "azure"
    load_balancer_sku  = "standard"

    service_cidr       = "10.1.0.0/16"
    dns_service_ip     = "10.1.0.10"
  }

  role_based_access_control_enabled = true
}