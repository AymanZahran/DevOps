output "Master01-IP" {
  value       = azurerm_public_ip.Master01_PublicIP.ip_address
  description = "Master01-IP"
}

output "Node01-IP" {
  value       = azurerm_public_ip.Node01_PublicIP.ip_address
  description = "Master01-IP"
}

output "Node02-IP" {
  value       = azurerm_public_ip.Node02_PublicIP.ip_address
  description = "Master01-IP"
}

