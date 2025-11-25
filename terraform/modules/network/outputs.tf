output "vnet_id" {
  value       = azurerm_virtual_network.vnet.id
  description = "ID of the VNet"
}

output "public_subnet_id" {
  value       = azurerm_subnet.public.id
  description = "ID of the public subnet"
}

output "private_subnet_id" {
  value       = azurerm_subnet.private.id
  description = "ID of the private subnet"
}
