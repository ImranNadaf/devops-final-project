variable "resource_group_name" {
  type        = string
  description = "Name of the resource group"
}

variable "location" {
  type        = string
  description = "Azure region"
}

variable "vnet_address_space" {
  type        = list(string)
  description = "VNet address space"
}

variable "public_subnet_prefix" {
  type        = string
  description = "Public subnet CIDR"
}

variable "private_subnet_prefix" {
  type        = string
  description = "Private subnet CIDR"
}

variable "prefix" {
  type        = string
  description = "Name prefix"
}
